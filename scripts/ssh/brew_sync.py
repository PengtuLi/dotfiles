"""SSH forward Homebrew install and config sync."""

import json
import os
import subprocess
import sys
import time
from pathlib import Path
from threading import Thread
from queue import Queue, Empty

import yaml
from colorama import Fore, Style, init

init(autoreset=True)

THIS_DIR = Path(__file__).parent
SOCKS_PORT = 1080
TUNNEL_PORT = 22222  # Use different port to avoid conflicts


def get_ssh_cmd(host: str) -> str:
    """Get SSH command."""
    return f"ssh {host}"


def remote_exec(ssh_cmd: str, cmd: str, proxy: bool = False) -> str:
    """Execute command on remote server with streaming output."""
    if proxy:
        cmd = f"export ALL_PROXY=socks5h://127.0.0.1:{SOCKS_PORT} && {cmd}"
    # Use double quotes to avoid # being interpreted as comment
    # Escape $ and " inside the command
    cmd_escaped = cmd.replace("$", "\\$").replace('"', '\\"')
    full = f'{ssh_cmd} "{cmd_escaped}"'
    print(f"{Fore.CYAN}[cmd] {Style.DIM}{full}{Style.RESET_ALL}")
    process = subprocess.Popen(
        full, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    stdout_lines = []
    for line in process.stdout:
        print(line, end="", flush=True)
        stdout_lines.append(line)
    process.wait()
    stderr = process.stderr.read()
    if stderr:
        print(f"{Fore.RED}[stderr] {stderr}{Style.RESET_ALL}", end="", flush=True)
    return "".join(stdout_lines)


def get_ssh_hosts() -> list[str]:
    """Get all SSH hosts from config."""
    cfg_file = Path.home() / ".ssh/config"
    if not cfg_file.exists():
        return []
    hosts = []
    for line in cfg_file.read_text().splitlines():
        line = line.strip()
        if line.lower().startswith("host "):
            host = line.split(maxsplit=1)[1]
            if "*" not in host:
                hosts.append(host)
    return hosts


def fzf_select(hosts: list[str]) -> str:
    """Use fzf to select host."""
    cmd = ["fzf", "--prompt=Select SSH host> ", "--height=40%"]
    result = subprocess.run(cmd, input="\n".join(hosts), capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(1)
    return result.stdout.strip()


def setup_socks_proxy(
    host: str, local_user: str, tunnel_port: int = TUNNEL_PORT
) -> Queue:
    """Set up SOCKS5 proxy via reverse SSH tunnel using agent forwarding."""
    result_queue = Queue()

    def _run_tunnel():
        try:
            # Ensure ssh-agent is running
            auth_sock = os.environ.get("SSH_AUTH_SOCK", "")
            if not auth_sock or not Path(auth_sock).exists():
                print(f"{Fore.YELLOW}[agent] Starting ssh-agent...{Style.RESET_ALL}")
                agent_output = subprocess.run(
                    "ssh-agent -s", shell=True, capture_output=True, text=True
                ).stdout
                for line in agent_output.splitlines():
                    if "SSH_AUTH_SOCK=" in line:
                        os.environ["SSH_AUTH_SOCK"] = line.split("=")[1].split(";")[0]
                    if "SSH_AGENT_PID=" in line:
                        os.environ["SSH_AGENT_PID"] = line.split("=")[1].split(";")[0]
                auth_sock = os.environ.get("SSH_AUTH_SOCK", "")
                if not auth_sock or not Path(auth_sock).exists():
                    result_queue.put((False, "Failed to start ssh-agent."))
                    return

            # Add key to agent if not present
            if (
                subprocess.run("ssh-add -l", shell=True, capture_output=True).returncode
                != 0
            ):
                print(f"{Fore.YELLOW}[agent] Adding SSH key...{Style.RESET_ALL}")
                if subprocess.run("ssh-add", shell=True).returncode != 0:
                    result_queue.put(
                        (False, "Failed to add SSH key. Run 'ssh-add' first.")
                    )
                    return

            # Clean up existing SOCKS processes
            subprocess.run(
                f'ssh {host} "pkill -f \\"ssh.*-D {SOCKS_PORT}\\" 2>/dev/null || true"',
                shell=True,
                capture_output=True,
            )

            # Ensure AllowAgentForwarding on remote
            fwd_check = subprocess.run(
                f'ssh {host} "grep -i AllowAgentForwarding /etc/ssh/sshd_config"',
                shell=True,
                capture_output=True,
                text=True,
            )
            if (
                "#AllowAgentForwarding" in fwd_check.stdout
                or "AllowAgentForwarding" not in fwd_check.stdout
            ):
                print(
                    f"{Fore.CYAN}[config] Enabling AllowAgentForwarding...{Style.RESET_ALL}"
                )
                subprocess.run(
                    f"ssh -t {host} \"sudo sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/' /etc/ssh/sshd_config; "
                    f'sudo grep -q \\"^AllowAgentForwarding yes\\" /etc/ssh/sshd_config || '
                    f"sudo bash -c 'echo AllowAgentForwarding yes >> /etc/ssh/sshd_config'; "
                    f'sudo systemctl restart sshd"',
                    shell=True,
                )
                time.sleep(1)

            # Kill existing control master to ensure fresh connection with agent forwarding
            subprocess.run(
                f"ssh -O exit {host} 2>/dev/null || true",
                shell=True,
                capture_output=True,
            )

            # Kill any existing processes using tunnel port on remote
            print(
                f"{Fore.CYAN}[tunnel] Cleaning up old tunnel processes...{Style.RESET_ALL}"
            )
            # First, kill any ssh processes that might be using the port
            cleanup_result = subprocess.run(
                f'''ssh -S none -A {host} "
                    # Kill ssh processes connected to tunnel port
                    pkill -9 -f 'ssh.*-R.*{tunnel_port}' 2>/dev/null || true
                    # Kill any process listening on the tunnel port
                    ss -tlpn 2>/dev/null | grep ':{tunnel_port}' | awk '{{print \\$6}}' | xargs -r kill -9 2>/dev/null || true
                    # Also try with lsof
                    lsof -ti :{tunnel_port} | xargs -r kill -9 2>/dev/null || true
                    # Force release the port
                    fuser -k -9 {tunnel_port}/tcp 2>/dev/null || true
                    # Wait a moment for port to be released
                    sleep 1
                "''',
                shell=True,
                capture_output=True,
                text=True,
            )
            if cleanup_result.stderr:
                print(
                    f"{Fore.YELLOW}[cleanup] {cleanup_result.stderr.strip()}{Style.RESET_ALL}"
                )
            time.sleep(1)

            print(
                f"{Fore.CYAN}[tunnel] Setting up reverse SSH tunnel...{Style.RESET_ALL}"
            )

            # Create reverse tunnel
            tunnel_proc = subprocess.Popen(
                f"ssh -S none -A -N -R {tunnel_port}:127.0.0.1:22 {host}",
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
            )
            time.sleep(2)

            # Check for tunnel errors
            import select

            stderr_lines = []
            while (
                tunnel_proc.stderr
                in select.select([tunnel_proc.stderr], [], [], 0.1)[0]
            ):
                line = tunnel_proc.stderr.readline()
                if line:
                    stderr_lines.append(line)
                else:
                    break

            if tunnel_proc.poll() is not None:
                result_queue.put(
                    (False, f"Tunnel failed to start: {''.join(stderr_lines)}")
                )
                return

            # Check if port forwarding actually worked
            if any("failed" in line.lower() for line in stderr_lines):
                result_queue.put(
                    (False, f"Port forwarding failed: {''.join(stderr_lines)}")
                )
                tunnel_proc.terminate()
                return

            # Add host key
            subprocess.run(
                f'ssh -S none -A {host} "ssh-keyscan -p {tunnel_port} localhost >> ~/.ssh/known_hosts 2>/dev/null"',
                shell=True,
                capture_output=True,
            )

            # Test tunnel connection
            test = subprocess.run(
                f'ssh -S none -A {host} "ssh -A -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -p {tunnel_port} {local_user}@localhost echo OK 2>&1"',
                shell=True,
                capture_output=True,
                text=True,
                timeout=15,
            )
            if "OK" not in test.stdout:
                result_queue.put((False, f"Tunnel test failed: {test.stdout.strip()}"))
                tunnel_proc.terminate()
                return

            # Start SOCKS proxy
            print(f"{Fore.CYAN}[socks] Setting up SOCKS5 proxy...{Style.RESET_ALL}")
            subprocess.run(
                f'ssh -S none -A {host} "ssh -A -f -N -D {SOCKS_PORT} -p {tunnel_port} -o StrictHostKeyChecking=accept-new {local_user}@localhost"',
                shell=True,
                capture_output=True,
                text=True,
            )
            time.sleep(1)

            # Verify
            print(f"{Fore.CYAN}[socks] Verifying SOCKS port...{Style.RESET_ALL}")
            verify_result = subprocess.run(
                f'ssh -S none -A {host} "nc -z 127.0.0.1 {SOCKS_PORT} && echo OK"',
                shell=True,
                capture_output=True,
                text=True,
            )
            print(
                f"{Fore.CYAN}[debug] verify stdout: '{verify_result.stdout.strip()}'{Style.RESET_ALL}"
            )
            if "OK" not in verify_result.stdout:
                result_queue.put((False, "SOCKS port not available."))
                tunnel_proc.terminate()
                return

            result_queue.put((True, f"SOCKS5 proxy ready on 127.0.0.1:{SOCKS_PORT}"))
            result_queue.put(("tunnel_proc", tunnel_proc))
            result_queue.put(("host", host))

        except Exception as e:
            result_queue.put((False, str(e)))

    Thread(target=_run_tunnel, daemon=True).start()
    return result_queue


def main():
    # Load brew.yaml
    brew_file = THIS_DIR / "brew.yaml"
    if not brew_file.exists():
        print(f"{Fore.RED}Error: {brew_file} not found{Style.RESET_ALL}")
        sys.exit(1)

    apps = yaml.safe_load(brew_file.read_text())

    # Select host via fzf
    hosts = get_ssh_hosts()
    if not hosts:
        print(f"{Fore.RED}No SSH hosts found in ~/.ssh/config{Style.RESET_ALL}")
        sys.exit(1)
    host = fzf_select(hosts)
    ssh_cmd = get_ssh_cmd(host)

    # Ask if using proxy for remote commands
    use_proxy = (
        input(f"{Fore.YELLOW}Use proxy for remote commands? [y/N] {Style.RESET_ALL}")
        .strip()
        .lower()
        == "y"
    )

    # Initialize cleanup variables before try block
    tunnel_proc = None
    remote_ssh_cmd = None

    try:
        print(f"""{Fore.YELLOW}set socks5{Style.RESET_ALL}
{Style.DIM}# 本地机器（A）执行：
ssh -R 2222:127.0.0.1:22 user@remote_server
# 保持这个连接不断开

# 然后登录到 remote_server（B），执行：
ssh -D 1080 -p 2222 -N localuser@localhost
# -N 表示不执行远程命令，只做端口转发{Style.RESET_ALL}
""")

        if use_proxy:
            auto_setup = (
                input(f"{Fore.YELLOW}Auto setup SOCKS proxy? [y/N] {Style.RESET_ALL}")
                .strip()
                .lower()
                == "y"
            )
            if auto_setup:
                local_user = input(
                    f"{Fore.YELLOW}Enter local username for SOCKS tunnel: {Style.RESET_ALL}"
                ).strip() or os.environ.get("USER", "")
                if not local_user:
                    print(f"{Fore.RED}Error: Local username required{Style.RESET_ALL}")
                    use_proxy = False
                else:
                    print(f"{Fore.GREEN}Setting up SOCKS5 proxy...{Style.RESET_ALL}")
                    result_queue = setup_socks_proxy(host, local_user)

                    try:
                        while True:
                            result = result_queue.get(timeout=30)
                            if isinstance(result, tuple):
                                if result[0] == "tunnel_proc":
                                    tunnel_proc = result[1]
                                elif result[0] == "host":
                                    remote_ssh_cmd = f"ssh -A {result[1]}"
                                elif result[0] is True:
                                    print(f"{Fore.GREEN}{result[1]}{Style.RESET_ALL}")
                                    break
                                elif result[0] is False:
                                    print(
                                        f"{Fore.RED}Error: {result[1]}{Style.RESET_ALL}"
                                    )
                                    use_proxy = False
                                    break
                    except Empty:
                        print(
                            f"{Fore.RED}Timeout waiting for SOCKS proxy{Style.RESET_ALL}"
                        )
                        use_proxy = False

        # Setup SSH server on remote
        print(f"{Fore.WHITE}Setting up SSH server...{Style.RESET_ALL}")
        print(f"""{Style.DIM}# 在 remote_server（B）上执行：
# Install openssh-server if not present
if ! command -v sshd &>/dev/null; then
    apt-get update
    apt-get install -y openssh-server
fi
# Ensure root password is set (change '1234' to your desired password)
echo 'root:1234' | chpasswd
# Enable root login with password
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Start SSH service
service ssh start{Style.RESET_ALL}
""")

        # Setup locales
        print(f"{Fore.WHITE}Setting up locales...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Setup locales? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            remote_exec(
                ssh_cmd,
                r"""apt-get install -y locales
locale-gen en_US.UTF-8
locale-gen en_SG.UTF-8""",
                proxy=use_proxy,
            )

        # Setup Docker environment export if in container
        print(f"{Fore.WHITE}Checking Docker environment...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Setup Docker environment? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            docker_check = remote_exec(
                ssh_cmd,
                "test -f /.dockerenv && echo 'docker' || echo 'not_docker'",
                proxy=use_proxy,
            )
            if "docker" in docker_check:
                remote_exec(
                    ssh_cmd,
                    r"""grep -q 'DOCKER_ENV_EXPORTED' ~/.bashrc 2>/dev/null || cat >> ~/.bashrc <<'EOF'
[ -n "$DOCKER_ENV_EXPORTED" ] || {
    export $(cat /proc/1/environ | tr '\0' '\n' | grep -vE '^(HOME|USER|PWD|TERM|SHLVL)=') 2>/dev/null
    export DOCKER_ENV_EXPORTED=1
}
EOF""",
                    proxy=use_proxy,
                )

        # Install Homebrew through local network
        print(f"{Fore.WHITE}Installing Homebrew...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Install Homebrew? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            remote_exec(
                ssh_cmd,
                r"""if [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ] &>/dev/null; then
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Add to ~/.bashrc if not already present
grep -q 'linuxbrew/.linuxbrew/bin/brew shellenv' ~/.bashrc 2>/dev/null || \
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc""",
                proxy=use_proxy,
            )

        # Install UV if not present
        print(f"{Fore.WHITE}Checking UV installation...{Style.RESET_ALL}")
        uv_check = remote_exec(
            ssh_cmd,
            "command -v uv &>/dev/null && echo 'installed' || echo 'not_found'",
            proxy=use_proxy,
        )
        if "not_found" in uv_check:
            response = (
                input(
                    f"{Fore.YELLOW}UV is not installed. Install UV? [y/N] {Style.RESET_ALL}"
                )
                .strip()
                .lower()
            )
            if response == "y":
                remote_exec(
                    ssh_cmd,
                    "wget -qO- https://astral.sh/uv/install.sh | sh",
                    proxy=use_proxy,
                )

        # Install packages
        to_install = [
            k for k, v in apps.items() if str(v.get("install", False)).lower() == "true"
        ]
        if to_install:
            print(
                f"{Fore.BLUE}Installing: {Fore.CYAN}{', '.join(to_install)}{Style.RESET_ALL}"
            )
            if (
                input(f"{Fore.YELLOW}Install packages? [y/N] {Style.RESET_ALL}")
                .strip()
                .lower()
                == "y"
            ):
                brew_names = [apps[app].get("brew", app) for app in to_install]
                remote_exec(
                    ssh_cmd,
                    f"/home/linuxbrew/.linuxbrew/bin/brew install {' '.join(brew_names)}",
                    proxy=use_proxy,
                )

        # Copy configs via archive (compress, transfer, extract)
        print(f"{Fore.GREEN}{Fore.WHITE}Copying config files...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Copy config files? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            import tempfile

            # Collect all files to transfer
            all_paths = []
            for app, info in apps.items():
                configs = info.get("config", [])
                if not configs:
                    continue
                if isinstance(configs, str):
                    configs = [configs]
                for cfg in configs:
                    cfg_path = Path(cfg).expanduser()
                    files = (
                        list(cfg_path.parent.glob(cfg_path.name))
                        if "*" in cfg_path.name
                        else [cfg_path]
                    )
                    for f in files:
                        if f.exists():
                            rel_path = f.relative_to(Path.home())
                            all_paths.append((f, rel_path))
                            print(
                                f"  {Fore.CYAN}Adding {Fore.WHITE}{rel_path}{Style.RESET_ALL}"
                            )

            if all_paths:
                # Remove existing files/dirs/symlinks on remote first (one command)
                rm_paths = " ".join(f"~/{rp}" for _, rp in all_paths)
                print(
                    f"  {Fore.YELLOW}Removing existing files on remote...{Style.RESET_ALL}"
                )
                remote_exec(ssh_cmd, f"rm -rf {rm_paths}")

                # Create tar archive
                with tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False) as tmp:
                    tmp_path = Path(tmp.name)
                try:
                    tar_cmd = ["tar", "-czhf", str(tmp_path), "-C", str(Path.home())]
                    for f, _ in all_paths:
                        tar_cmd.append(str(f.relative_to(Path.home())))
                    subprocess.run(tar_cmd, check=True)

                    # Transfer archive
                    archive_size = tmp_path.stat().st_size / 1024 / 1024
                    print(
                        f"  {Fore.GREEN}Transferring archive ({archive_size:.2f} MB)...{Style.RESET_ALL}"
                    )
                    subprocess.run(
                        f"scp {tmp_path} {host}:/tmp/config_sync.tar.gz",
                        shell=True,
                        check=True,
                    )

                    # Extract on remote
                    remote_exec(
                        ssh_cmd,
                        "tar -xzf /tmp/config_sync.tar.gz -C ~ && rm /tmp/config_sync.tar.gz",
                    )
                    print(
                        f"  {Fore.GREEN}Extracted {len(all_paths)} items{Style.RESET_ALL}"
                    )
                finally:
                    tmp_path.unlink(missing_ok=True)

        # Copy bashrc and common shell scripts to remote
        print(f"{Fore.WHITE}Copying .bashrc and shell scripts...{Style.RESET_ALL}")
        shell_dir = THIS_DIR.parent.parent / "shell"
        bashrc_local = shell_dir / "bash/.bashrc"
        common_dir = shell_dir / "common"
        if bashrc_local.exists():
            if (
                input(f"{Fore.YELLOW}Copy .bashrc? [y/N] {Style.RESET_ALL}")
                .strip()
                .lower()
                == "y"
            ):
                print(f"  {Fore.CYAN}Syncing {Fore.WHITE}.bashrc{Style.RESET_ALL}")
                subprocess.run(f"scp {bashrc_local} {host}:~/._bashrc", shell=True)
                # Copy common shell scripts
                if common_dir.exists():
                    print(
                        f"  {Fore.CYAN}Syncing {Fore.WHITE}common shell scripts{Style.RESET_ALL}"
                    )
                    subprocess.run(
                        f"ssh {host} 'mkdir -p ~/._shell/common'", shell=True
                    )
                    subprocess.run(
                        f"scp {common_dir}/*.sh {host}:~/._shell/common/", shell=True
                    )
                    # Fix SHELL_DIR in remote ._bashrc to use absolute path
                    # remote_exec escapes $ to \$, so $HOME becomes \$HOME
                    # on remote: \$HOME in double quotes → literal $HOME
                    remote_exec(
                        ssh_cmd,
                        """sed -i 's|^SHELL_DIR=.*|SHELL_DIR="$HOME/._shell"|' ~/._bashrc""",
                    )
                # Source it in remote .bashrc (if not already exists)
                remote_exec(
                    ssh_cmd,
                    r"""grep -q 'source.*\._bashrc' ~/.bashrc 2>/dev/null || echo 'source $HOME/._bashrc' >> ~/.bashrc""",
                )

        # Copy secret environment variables
        print(f"{Fore.WHITE}Copying environment variables...{Style.RESET_ALL}")
        secret_env_file = THIS_DIR / "secret_env.json"
        if (
            secret_env_file.exists()
            and input(
                f"{Fore.YELLOW}Copy environment variables? [y/N] {Style.RESET_ALL}"
            )
            .strip()
            .lower()
            == "y"
        ):
            env_vars = json.loads(secret_env_file.read_text()).get("env_vars", [])
            exports = [
                f'export {var}="{os.environ.get(var, "")}"'
                for var in env_vars
                if os.environ.get(var)
            ]
            if exports:
                marker_start = "# SECRET_ENV_START"
                marker_end = "# SECRET_ENV_END"
                block = f"{marker_start}\n" + "\n".join(exports) + f"\n{marker_end}\n"
                remote_exec(
                    ssh_cmd,
                    f"sed -i '/{marker_start}/,/{marker_end}/d' ~/.bashrc 2>/dev/null; echo '{block}' >> ~/.bashrc",
                )
                print(f"  {Fore.CYAN}Copied {len(exports)} variables{Style.RESET_ALL}")

        print(f"{Fore.GREEN}Done!{Style.RESET_ALL}")

    finally:
        if tunnel_proc:
            print(f"{Fore.YELLOW}Cleaning up tunnel...{Style.RESET_ALL}")
            tunnel_proc.terminate()
            tunnel_proc.wait()
        # Always clean up remote SOCKS processes
        print(f"{Fore.YELLOW}Cleaning up remote SOCKS process...{Style.RESET_ALL}")
        if remote_ssh_cmd:
            subprocess.run(
                f'{remote_ssh_cmd} "pkill -f \\"ssh.*-D {SOCKS_PORT}\\""',
                shell=True,
                capture_output=True,
            )
        else:
            # If remote_ssh_cmd wasn't set, use direct ssh
            subprocess.run(
                f'ssh {host} "pkill -f \\"ssh.*-D {SOCKS_PORT}\\""',
                shell=True,
                capture_output=True,
            )
        print(f"{Fore.MAGENTA}{Style.BRIGHT}** Done ! **{Style.RESET_ALL}")


if __name__ == "__main__":
    main()
