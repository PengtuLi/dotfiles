"""SSH forward Homebrew install and config sync."""

import base64
import json
import os
import subprocess
import sys
from pathlib import Path
from queue import Empty

import yaml
from colorama import Fore, Style, init

from archive_utils import sync_configs, sync_scripts, sync_vibe
from brew_patchelf_fix import fix_all_broken_binaries
from prompt_utils import confirm, select_option
from proxy_utils import setup_simple_proxy, setup_socks_proxy_legacy
from ssh_utils import exec_remote, get_ssh_cmd, get_ssh_hosts

init(autoreset=True)

THIS_DIR = Path(__file__).parent
CLASH_PORT = 7890
TUNNEL_PORT = 22222
SOCKS_PORT = 1080


def install_homebrew_remote(
    ssh_cmd: str, host: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Install Homebrew on remote host using shared install script."""
    print(f"{Fore.WHITE}Installing Homebrew...{Style.RESET_ALL}")
    if not confirm("Install Homebrew?"):
        return

    install_script = THIS_DIR.parent / "lib" / "install_homebrew.sh"
    subprocess.run(
        f"scp {install_script} {host}:/tmp/install_homebrew.sh",
        shell=True,
        check=True,
    )
    exec_remote(
        ssh_cmd,
        "bash /tmp/install_homebrew.sh && rm /tmp/install_homebrew.sh",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )


def install_herdr_remote(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Install Herdr on remote host if not present."""
    print(f"{Fore.WHITE}Checking Herdr installation...{Style.RESET_ALL}")
    herdr_check = exec_remote(
        ssh_cmd,
        "command -v herdr &>/dev/null && echo 'installed' || echo 'not_found'",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    if "not_found" not in herdr_check:
        print(f"  {Fore.GREEN}Herdr is already installed{Style.RESET_ALL}")
        return
    if confirm("Herdr is not installed. Install Herdr?"):
        exec_remote(
            ssh_cmd,
            "curl -fsSL https://herdr.dev/install.sh | sh",
            proxy=proxy,
            proxy_mode=proxy_mode,
            proxy_port=proxy_port,
        )


def install_uv_remote(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Install UV on remote host if not present."""
    print(f"{Fore.WHITE}Checking UV installation...{Style.RESET_ALL}")
    uv_check = exec_remote(
        ssh_cmd,
        "command -v uv &>/dev/null && echo 'installed' || echo 'not_found'",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    if "not_found" not in uv_check:
        return
    if confirm("UV is not installed. Install UV?"):
        exec_remote(
            ssh_cmd,
            "wget -qO- https://astral.sh/uv/install.sh | sh",
            proxy=proxy,
            proxy_mode=proxy_mode,
            proxy_port=proxy_port,
        )


def install_packages_remote(
    ssh_cmd: str, apps: dict, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Install Homebrew packages on remote host."""
    to_install = [
        k for k, v in apps.items() if str(v.get("install", False)).lower() == "true"
    ]
    if not to_install:
        return

    print(f"{Fore.BLUE}Installing: {Fore.CYAN}{', '.join(to_install)}{Style.RESET_ALL}")
    if not confirm("Install packages?"):
        return

    brew_names = [apps[app].get("brew", app) for app in to_install]
    exec_remote(
        ssh_cmd,
        f"/home/linuxbrew/.linuxbrew/bin/brew install {' '.join(brew_names)}",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )


def setup_locales_remote(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Setup locales on remote host."""
    print(f"{Fore.WHITE}Setting up locales...{Style.RESET_ALL}")
    if not confirm("Setup locales?"):
        return
    exec_remote(
        ssh_cmd,
        "apt-get install -y locales && locale-gen en_US.UTF-8 && locale-gen en_SG.UTF-8",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )


def setup_docker_env_remote(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Setup Docker environment export on remote host if in container."""
    print(f"{Fore.WHITE}Checking Docker environment...{Style.RESET_ALL}")
    if not confirm("Setup Docker environment?"):
        return

    docker_check = exec_remote(
        ssh_cmd,
        "test -f /.dockerenv && echo 'docker' || echo 'not_docker'",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    if "docker" not in docker_check:
        return

    exec_remote(
        ssh_cmd,
        r"""grep -q 'DOCKER_ENV_EXPORTED' ~/.bashrc 2>/dev/null || cat >> ~/.bashrc <<'EOF'
[ -n "$DOCKER_ENV_EXPORTED" ] || {
    export $(cat /proc/1/environ | tr '\0' '\n' | grep -vE '^(HOME|USER|PWD|TERM|SHLVL)=') 2>/dev/null
    export DOCKER_ENV_EXPORTED=1
}
EOF""",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )


def ensure_git_remote(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Ensure git is installed on remote host."""
    git_check = exec_remote(
        ssh_cmd,
        "command -v git &>/dev/null && echo 'ok' || echo 'missing'",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    if "missing" not in git_check:
        return

    print(f"{Fore.YELLOW}[git] git not found, installing...{Style.RESET_ALL}")
    exec_remote(
        ssh_cmd,
        "apt-get install -y git || yum install -y git",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )


def copy_secret_env(
    ssh_cmd: str, proxy: bool, proxy_mode: str, proxy_port: int
) -> None:
    """Copy secret environment variables to remote host."""
    print(f"{Fore.WHITE}Copying environment variables...{Style.RESET_ALL}")
    secret_env_file = THIS_DIR / "secret_env.json"
    if not secret_env_file.exists() or not confirm("Copy environment variables?"):
        return

    env_vars = json.loads(secret_env_file.read_text()).get("env_vars", [])
    exports = [
        f'export {var}="{os.environ.get(var, "")}"'
        for var in env_vars
        if os.environ.get(var)
    ]
    if not exports:
        return

    marker_start = "# SECRET_ENV_START"
    marker_end = "# SECRET_ENV_END"
    block = f"{marker_start}\n" + "\n".join(exports) + f"\n{marker_end}\n"
    encoded = base64.b64encode(block.encode()).decode()
    exec_remote(
        ssh_cmd,
        f"sed -i '/{marker_start}/,/{marker_end}/d' ~/.bashrc 2>/dev/null; echo '{encoded}' | base64 -d >> ~/.bashrc",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    print(f"  Copied {len(exports)} variables")


def fzf_select(hosts: list[str]) -> str:
    """Use fzf to select host."""
    cmd = ["fzf", "--prompt=Select SSH host> ", "--height=40%"]
    result = subprocess.run(cmd, input="\n".join(hosts), capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(1)
    return result.stdout.strip()


def setup_proxy(host: str) -> tuple[bool, str, subprocess.Popen | None, int]:
    """Setup proxy and return configuration.

    Returns:
        (use_proxy, proxy_mode, tunnel_proc, active_proxy_port)
    """
    if not confirm("Use proxy for remote commands?"):
        return False, "http", None, CLASH_PORT

    print(f"{Fore.YELLOW}Proxy setup method:{Style.RESET_ALL}")
    print(f"  {Fore.CYAN}1.{Style.RESET_ALL} Simple (SSH -R, forwards local clash)")
    print(
        f"  {Fore.CYAN}2.{Style.RESET_ALL} Legacy (double SSH tunnel, no local proxy needed)"
    )
    choice = select_option("Select:", ["Simple", "Legacy"])

    if choice == "2":
        proxy_mode = "socks"
        print(f"""{Fore.YELLOW}Legacy SOCKS proxy setup{Style.RESET_ALL}
{Style.DIM}# Local machine (A):
ssh -R 2222:127.0.0.1:22 user@remote_server

# Then on remote_server (B):
ssh -D 1080 -p 2222 -N localuser@localhost{Style.RESET_ALL}
""")
        local_user = input(
            f"{Fore.YELLOW}Enter local username for SOCKS tunnel: {Style.RESET_ALL}"
        ).strip() or os.environ.get("USER", "")
        if not local_user:
            print(f"{Fore.RED}Error: Local username required{Style.RESET_ALL}")
            return False, "http", None, CLASH_PORT

        print(f"{Fore.GREEN}Setting up SOCKS5 proxy (legacy)...{Style.RESET_ALL}")
        result_queue = setup_socks_proxy_legacy(host, local_user)
        tunnel_proc = None
        actual_socks_port = SOCKS_PORT
        try:
            while True:
                result = result_queue.get(timeout=30)
                if isinstance(result, tuple):
                    if result[0] == "tunnel_proc":
                        tunnel_proc = result[1]
                    elif result[0] == "socks_port":
                        actual_socks_port = result[1]
                    elif result[0] is True:
                        print(f"{Fore.GREEN}{result[1]}{Style.RESET_ALL}")
                        return True, "socks", tunnel_proc, actual_socks_port
                    elif result[0] is False:
                        print(f"{Fore.RED}Error: {result[1]}{Style.RESET_ALL}")
                        return False, "http", None, CLASH_PORT
        except Empty:
            print(f"{Fore.RED}Timeout waiting for SOCKS proxy{Style.RESET_ALL}")
            return False, "http", None, CLASH_PORT
    else:
        proxy_mode = "http"
        try:
            tunnel_proc, remote_proxy_port = setup_simple_proxy(host)
            return True, "http", tunnel_proc, remote_proxy_port
        except RuntimeError as e:
            print(f"{Fore.RED}Error: {e}{Style.RESET_ALL}")
            return False, "http", None, CLASH_PORT


def main():
    # Load brew.yaml
    brew_file = THIS_DIR / "brew.yaml"
    if not brew_file.exists():
        print(f"{Fore.RED}Error: {brew_file} not found{Style.RESET_ALL}")
        sys.exit(1)

    apps = yaml.safe_load(brew_file.read_text())

    # Load bin.yaml
    bin_file = THIS_DIR / "bin.yaml"
    bin_scripts = {}
    if bin_file.exists():
        bin_scripts = {
            k
            for k, v in (yaml.safe_load(bin_file.read_text()) or {}).items()
            if str(v).lower() == "true"
        }

    # Select host via fzf
    hosts = get_ssh_hosts()
    if not hosts:
        print(f"{Fore.RED}No SSH hosts found in ~/.ssh/config{Style.RESET_ALL}")
        sys.exit(1)

    host = fzf_select(hosts)
    ssh_cmd = get_ssh_cmd(host)

    # Setup proxy
    use_proxy, proxy_mode, tunnel_proc, active_proxy_port = setup_proxy(host)

    try:
        # Setup locales
        setup_locales_remote(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Setup Docker environment
        setup_docker_env_remote(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Ensure git is installed
        ensure_git_remote(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Install Homebrew
        install_homebrew_remote(ssh_cmd, host, use_proxy, proxy_mode, active_proxy_port)

        # Install UV
        install_uv_remote(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Install Herdr
        install_herdr_remote(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Install packages
        install_packages_remote(ssh_cmd, apps, use_proxy, proxy_mode, active_proxy_port)

        # Fix broken ELF interpreters (after all installations)
        fix_all_broken_binaries(ssh_cmd)

        # Copy configs
        print(f"{Fore.WHITE}Copying config files...{Style.RESET_ALL}")
        if confirm("Copy config files?"):
            sync_configs(host, ssh_cmd, apps, use_proxy, proxy_mode, active_proxy_port)

        # Copy scripts
        print(f"{Fore.WHITE}Copying scripts and shell config...{Style.RESET_ALL}")
        if confirm("Copy bin scripts and .bashrc?"):
            sync_scripts(
                host, ssh_cmd, bin_scripts, use_proxy, proxy_mode, active_proxy_port
            )

        # Copy secret env
        copy_secret_env(ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        # Upload vibe
        print(f"{Fore.WHITE}Uploading vibe directory...{Style.RESET_ALL}")
        if confirm("Upload vibe/ to server?"):
            sync_vibe(host, ssh_cmd, use_proxy, proxy_mode, active_proxy_port)

        print(f"{Fore.GREEN}Done!{Style.RESET_ALL}")

    finally:
        if tunnel_proc:
            print(f"{Fore.YELLOW}Cleaning up tunnel...{Style.RESET_ALL}")
            tunnel_proc.terminate()
            tunnel_proc.wait()
        if proxy_mode == "socks" and use_proxy:
            print(f"{Fore.YELLOW}Cleaning up remote SOCKS process...{Style.RESET_ALL}")
            subprocess.run(
                f'ssh {host} "pkill -f \\"ssh.*-D {active_proxy_port}\\""',
                shell=True,
                capture_output=True,
            )
        print(f"{Fore.MAGENTA}{Style.BRIGHT}** Done ! **{Style.RESET_ALL}")


if __name__ == "__main__":
    main()
