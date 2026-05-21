"""SSH utilities for remote command execution."""

import subprocess
from pathlib import Path


def get_ssh_cmd(host: str) -> str:
    """Get SSH command."""
    return f"ssh {host}"


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


def exec_remote(
    ssh_cmd: str,
    cmd: str,
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
) -> str:
    """Execute command on remote server with streaming output."""
    if proxy:
        if proxy_mode == "socks":
            cmd = f"export ALL_PROXY=socks5h://127.0.0.1:{proxy_port} && {cmd}"
        else:
            cmd = f"export http_proxy=http://127.0.0.1:{proxy_port} https_proxy=http://127.0.0.1:{proxy_port} && {cmd}"
    cmd_escaped = cmd.replace("$", "\\$").replace('"', '\\"')
    full = f'{ssh_cmd} "{cmd_escaped}"'
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
