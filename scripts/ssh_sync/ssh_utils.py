"""SSH utilities for remote command execution."""

import re
import subprocess
from pathlib import Path

from proxy_utils import get_local_proxy_host


_CONNECTION_CLOSED_RE = re.compile(r"^Shared connection to .+ closed\.\s*$")


def get_ssh_cmd(host: str) -> str:
    """Get SSH command with TTY allocation for proper signal propagation."""
    return f"ssh -t {host}"


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


def _strip_connection_closed(output: str) -> str:
    """Drop the 'Shared connection to ... closed.' noise from ssh stderr."""
    return "".join(
        line
        for line in output.splitlines(keepends=True)
        if not _CONNECTION_CLOSED_RE.match(line.rstrip("\n"))
    )


def exec_remote(
    ssh_cmd: str,
    cmd: str,
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
    capture: bool = False,
) -> str | None:
    """Execute command on remote server.

    By default the ssh process is attached directly to the local terminal so
    progress bars, colors, and carriage returns work exactly as they do when
    running ssh manually. Use capture=True for short commands whose output is
    inspected by the caller (e.g. 'command -v ...').
    """
    if proxy:
        proxy_host = get_local_proxy_host()
        if proxy_mode == "socks":
            proxy_url = f"socks5h://{proxy_host}:{proxy_port}"
            env_block = (
                f"export ALL_PROXY={proxy_url} "
                f"export all_proxy={proxy_url} "
                f"export NO_PROXY=localhost,127.0.0.1,::1 "
                f"export no_proxy=localhost,127.0.0.1,::1 "
            )
        else:
            proxy_url = f"http://{proxy_host}:{proxy_port}"
            env_block = (
                f"export http_proxy={proxy_url} "
                f"export https_proxy={proxy_url} "
                f"export ftp_proxy={proxy_url} "
                f"export all_proxy={proxy_url} "
                f"export HTTP_PROXY={proxy_url} "
                f"export HTTPS_PROXY={proxy_url} "
                f"export FTP_PROXY={proxy_url} "
                f"export ALL_PROXY={proxy_url} "
                f"export NO_PROXY=localhost,127.0.0.1,::1 "
                f"export no_proxy=localhost,127.0.0.1,::1 "
            )
        cmd = f"{env_block}&& {cmd}"

    cmd_escaped = cmd.replace("$", "\\$").replace('"', '\\"')
    full = f'{ssh_cmd} "{cmd_escaped}"'

    if capture:
        result = subprocess.run(full, shell=True, capture_output=True, text=True)
        return _strip_connection_closed(result.stdout + result.stderr).strip()

    subprocess.run(full, shell=True)
    return None
