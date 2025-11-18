"""SSH forward zerobrew install and config sync."""

import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

from colorama import Fore, Style, init

init(autoreset=True)

THIS_DIR = Path(__file__).parent
SOCKS_PORT = 1080


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


def wait_for_port(port: int, timeout: int = 5):
    """Wait for port to be available."""
    for _ in range(timeout * 5):
        try:
            socket.create_connection(("127.0.0.1", port), timeout=0.1)
            return
        except Exception:
            time.sleep(0.2)
    raise TimeoutError(f"Port {port} not available")


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


def main():
    # Load brew.json
    brew_file = THIS_DIR / "brew.json"
    if not brew_file.exists():
        print(f"{Fore.RED}Error: {brew_file} not found{Style.RESET_ALL}")
        sys.exit(1)

    apps = json.loads(brew_file.read_text())

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

    try:
        print(f"""{Fore.MAGENTA}{Fore.YELLOW}set socks5{Style.RESET_ALL}
{Style.DIM}# 本地机器（A）执行：
ssh -R 2222:127.0.0.1:22 user@remote_server
# 保持这个连接不断开

# 然后登录到 remote_server（B），执行：
ssh -D 1080 -p 2222 -N localuser@localhost
# -N 表示不执行远程命令，只做端口转发{Style.RESET_ALL}
""")

        # Setup SSH server on remote
        print(f"{Fore.GREEN}{Fore.WHITE}Setting up SSH server...{Style.RESET_ALL}")
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
        print(f"{Fore.GREEN}{Fore.WHITE}Setting up locales...{Style.RESET_ALL}")
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
        print(
            f"{Fore.GREEN}{Fore.WHITE}Checking Docker environment...{Style.RESET_ALL}"
        )
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

        # Install zerobrew
        print(f"{Fore.GREEN}{Fore.WHITE}Installing zerobrew...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Install zerobrew? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            remote_exec(
                ssh_cmd,
                r"""if ! command -v zb &>/dev/null; then
curl -sSL https://raw.githubusercontent.com/lucasgelfond/zerobrew/main/install.sh | bash
fi""",
                proxy=use_proxy,
            )

        # Install UV if not present
        print(f"{Fore.GREEN}{Fore.WHITE}Checking UV installation...{Style.RESET_ALL}")
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

        # Install packages all at once
        to_install = [
            v.get("brew", k)
            for k, v in apps.items()
            if v.get("install", "False").lower() == "true"
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
                packages_str = " ".join(to_install)
                remote_exec(
                    ssh_cmd,
                    f"zb install {packages_str}",
                    proxy=use_proxy,
                )

        # Copy configs via rsync
        print(f"{Fore.GREEN}{Fore.WHITE}Copying config files...{Style.RESET_ALL}")
        if (
            input(f"{Fore.YELLOW}Copy config files? [y/N] {Style.RESET_ALL}")
            .strip()
            .lower()
            == "y"
        ):
            for app, info in apps.items():
                configs = info.get("config", [])
                if not configs:
                    continue
                # Support both string and list
                if isinstance(configs, str):
                    configs = [configs]
                for cfg in configs:
                    cfg_path = Path(cfg).expanduser()
                    # Handle wildcards with glob
                    files = (
                        list(cfg_path.parent.glob(cfg_path.name))
                        if "*" in cfg_path.name
                        else [cfg_path]
                    )
                    for f in files:
                        if not f.exists():
                            continue
                        # Keep directory structure, e.g. ~/.config/nvim -> ~/.config/nvim
                        rel_path = f.relative_to(Path.home())
                        print(
                            f"  {Fore.CYAN}Syncing {Fore.WHITE}{rel_path}{Style.RESET_ALL}..."
                        )
                        # For directories, remove remote first to avoid nested copying
                        if f.is_dir():
                            remote_exec(ssh_cmd, f"rm -rf ~/{rel_path}")
                        # For files, create parent directory if it doesn't exist
                        if f.is_file():
                            remote_exec(ssh_cmd, f"mkdir -p ~/{rel_path.parent}")
                        subprocess.run(
                            f"scp {'-r ' if f.is_dir() else ''}{f} {host}:~/{rel_path}",
                            shell=True,
                        )

        # Copy bashrc to remote
        print(f"{Fore.GREEN}{Fore.WHITE}Copying .bashrc...{Style.RESET_ALL}")
        bashrc_local = THIS_DIR.parent / "shell/bash/.bashrc"
        if bashrc_local.exists():
            if (
                input(f"{Fore.YELLOW}Copy .bashrc? [y/N] {Style.RESET_ALL}")
                .strip()
                .lower()
                == "y"
            ):
                print(f"  {Fore.CYAN}Syncing {Fore.WHITE}.bashrc{Style.RESET_ALL}")
                subprocess.run(f"scp {bashrc_local} {host}:~/._bashrc", shell=True)
                # Source it in remote .bashrc (if not already exists)
                remote_exec(
                    ssh_cmd,
                    r"""grep -q 'source.*\._bashrc' ~/.bashrc 2>/dev/null || echo 'source $HOME/._bashrc' >> ~/.bashrc""",
                )

        # Install nvim plugins and tools
        print(f"{Fore.GREEN}{Fore.WHITE}Installing nvim plugins...{Style.RESET_ALL}")
        if (
            input(
                f"{Fore.YELLOW}Install nvim plugins and tools? [y/N] {Style.RESET_ALL}"
            )
            .strip()
            .lower()
            == "y"
        ):
            # Start nvim headless to let lazy install plugins
            print(f"  {Fore.CYAN}Running lazy sync...{Style.RESET_ALL}")
            remote_exec(
                ssh_cmd,
                "nvim --headless '+Lazy! sync' +qa",
                proxy=use_proxy,
            )
            # Install mason tools
            print(f"  {Fore.CYAN}Installing mason tools...{Style.RESET_ALL}")
            remote_exec(
                ssh_cmd,
                r"""nvim --headless -c "lua
local packages = {'bashls', 'ruff', 'pyright', 'beautysh'}
local mr = require('mason-registry')
local installed_count = 0
local total_count = 0
for _, pkg in ipairs(packages) do
  if not mr.is_installed(pkg) then
    total_count = total_count + 1
    local p = mr.get_package(pkg)
    p:once('install:success', function()
      installed_count = installed_count + 1
      print('Installed: ' .. pkg)
    end)
    p:install()
  end
end
-- Wait for installations to complete (with timeout)
local timeout = 300
local start = os.time()
while total_count > 0 and installed_count < total_count and os.time() - start < timeout do
  vim.loop.sleep(100)
end
" +qa""",
                proxy=use_proxy,
            )

        # Copy secret environment variables
        print(
            f"{Fore.GREEN}{Fore.WHITE}Copying environment variables...{Style.RESET_ALL}"
        )
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
                marker = "# SECRET_ENV_EXPORTED"
                block = marker + "\n" + "\n".join(exports) + "\n"
                remote_exec(
                    ssh_cmd,
                    f"sed -i '/{marker}/,/{{/{marker}/!d;}}' ~/.bashrc 2>/dev/null; echo '{block}' >> ~/.bashrc",
                )
                print(f"  {Fore.CYAN}Copied {len(exports)} variables{Style.RESET_ALL}")

        print(f"{Fore.GREEN}Done!{Style.RESET_ALL}")

    finally:
        print(f"{Fore.MAGENTA}{Style.BRIGHT}** Done ! **{Style.RESET_ALL}")


if __name__ == "__main__":
    main()
