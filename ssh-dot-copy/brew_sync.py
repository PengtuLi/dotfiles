#!/usr/bin/env python3
"""SSH forward Homebrew install and config sync."""

import json
import socket
import subprocess
import sys
import time
from pathlib import Path

THIS_DIR = Path(__file__).parent
SOCKS_PORT = 1080


def get_ssh_cmd(host: str) -> str:
    """Get SSH command."""
    return f"ssh {host}"


def remote_exec(ssh_cmd: str, cmd: str, proxy: bool = False) -> str:
    """Execute command on remote server with streaming output."""
    if proxy:
        cmd = f"export ALL_PROXY=socks5h://127.0.0.1:{SOCKS_PORT} && {cmd}"
    full = f"{ssh_cmd} '{cmd}'"
    print(f"[cmd] {full}")
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
        print(f"[stderr] {stderr}", end="", flush=True)
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
        print(f"Error: {brew_file} not found")
        sys.exit(1)

    apps = json.loads(brew_file.read_text())

    # Select host via fzf
    hosts = get_ssh_hosts()
    if not hosts:
        print("No SSH hosts found in ~/.ssh/config")
        sys.exit(1)
    host = fzf_select(hosts)
    ssh_cmd = get_ssh_cmd(host)

    # Start SOCKS proxy tunnel with remote port forwarding
    # -D: local SOCKS proxy | -R: forward local 1080 to remote 1080
    tunnel_cmd = f"{ssh_cmd} -D {SOCKS_PORT} -R {SOCKS_PORT}:127.0.0.1:{SOCKS_PORT} -N"
    print(f"[step 1] Starting SOCKS proxy tunnel: {tunnel_cmd}")
    # Kill existing tunnel first
    subprocess.run(f"lsof -ti :{SOCKS_PORT} | xargs -r kill -9", shell=True)
    tunnel = subprocess.Popen(tunnel_cmd.split())
    wait_for_port(SOCKS_PORT)

    try:
        # Install Homebrew through local network
        print("[step 2] Installing Homebrew...")
        remote_exec(
            ssh_cmd,
            r"""if [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ] &>/dev/null; then
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Add to ~/.bashrc if not already present
grep -q 'linuxbrew/.linuxbrew/bin/brew shellenv' ~/.bashrc 2>/dev/null || \
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc""",
            proxy=True,
        )

        # Install packages
        to_install = [
            k for k, v in apps.items() if v.get("install", "False").lower() == "true"
        ]
        if to_install:
            print(f"Installing: {', '.join(to_install)}")
            for app in to_install:
                brew_name = apps[app].get("brew", app)
                remote_exec(
                    ssh_cmd,
                    f"/home/linuxbrew/.linuxbrew/bin/brew install {brew_name} ",
                    proxy=True,
                )

        # Copy configs via rsync
        print("[step 3] Copying config files...")
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
                files = list(cfg_path.parent.glob(cfg_path.name)) if '*' in cfg_path.name else [cfg_path]
                for f in files:
                    if not f.exists():
                        continue
                    # Keep directory structure, e.g. ~/.config/nvim -> ~/.config/nvim
                    rel_path = f.relative_to(Path.home())
                    print(f"  Syncing {rel_path}...")
                    # For directories, remove remote first to avoid nested copying
                    if f.is_dir():
                        remote_exec(ssh_cmd, f"rm -rf ~/{rel_path}")
                    subprocess.run(f"scp {'-r ' if f.is_dir() else ''}{f} {host}:~/{rel_path}", shell=True)

        # Copy bashrc to remote
        print("[step 4] Copying config files...")
        bashrc_local = THIS_DIR.parent / "shell/bash/.bashrc"
        if bashrc_local.exists():
            print("  Syncing .bashrc")
            subprocess.run(f"scp {bashrc_local} {host}:~/._bashrc", shell=True)
            # Source it in remote .bashrc (if not already exists)
            remote_exec(
                ssh_cmd,
                r"""grep -q 'source.*\._bashrc' ~/.bashrc 2>/dev/null || echo 'source \$HOME/._bashrc' >> ~/.bashrc""",
            )

        print("Done!")

    finally:
        tunnel.terminate()


if __name__ == "__main__":
    main()
