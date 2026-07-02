"""Sync dotfile configs, shell config and bin scripts into a remote Docker container."""

import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

import yaml
from colorama import Fore, Style, init

from archive_utils import collect_config_paths
from prompt_utils import confirm
from ssh_utils import exec_remote, get_ssh_cmd, get_ssh_hosts

init(autoreset=True)

THIS_DIR = Path(__file__).parent
REPO_ROOT = THIS_DIR.parent.parent


def fzf_select(options: list[str], prompt: str = "> ") -> str:
    """Use fzf to select an option."""
    cmd = ["fzf", f"--prompt={prompt}", "--height=40%"]
    result = subprocess.run(
        cmd, input="\n".join(options), capture_output=True, text=True
    )
    if result.returncode != 0:
        sys.exit(1)
    return result.stdout.strip()


def list_remote_containers(ssh_cmd: str) -> list[tuple[str, str]]:
    """Return list of (container_id, name) for running containers on remote host."""
    output = exec_remote(
        ssh_cmd, "docker ps --format '{{.ID}}\\t{{.Names}}\\t{{.Image}}'"
    )
    containers = []
    for line in output.strip().splitlines():
        parts = line.split("\t")
        if len(parts) >= 2:
            containers.append((parts[0], parts[1]))
    return containers


def select_container(containers: list[tuple[str, str]]) -> str:
    """Select container and return its ID."""
    if not containers:
        print(
            f"{Fore.RED}No running Docker containers found on remote host{Style.RESET_ALL}"
        )
        sys.exit(1)
    options = [f"{cid[:12]}  {name}" for cid, name in containers]
    selected = fzf_select(options, "Select container> ")
    idx = options.index(selected)
    return containers[idx][0]


def collect_bin_scripts(bin_scripts: dict) -> list[tuple[Path, Path]]:
    """Collect .local/bin scripts selected in bin.yaml."""
    paths = []
    local_bin = REPO_ROOT / ".local" / "bin"
    for name, enabled in bin_scripts.items():
        if str(enabled).lower() != "true":
            continue
        src = local_bin / name
        if src.exists():
            paths.append((src, Path(".local/bin") / name))
        else:
            print(f"  {Fore.YELLOW}Skip {name} (not found){Style.RESET_ALL}")
    return paths


def collect_shell_config() -> list[tuple[Path, Path]]:
    """Collect bashrc and common shell scripts."""
    paths = []
    shell_dir = REPO_ROOT / "shell"
    bashrc = shell_dir / "bash" / ".bashrc"
    common_dir = shell_dir / "common"
    if bashrc.exists():
        paths.append((bashrc, Path("._bashrc")))
        if common_dir.exists():
            for sh in sorted(common_dir.glob("*.sh")):
                paths.append((sh, Path("._shell/common") / sh.name))
    return paths


def create_archive(items: list[tuple[Path, Path]]) -> Path:
    """Create a local tar.gz archive from (src, rel_path) items."""
    with tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False) as tmp:
        tmp_path = Path(tmp.name)
    with tarfile.open(tmp_path, "w:gz") as tar:
        for src, rel in items:
            tar.add(str(src), arcname=str(rel))
    return tmp_path


def main():
    # Load brew.yaml and collect config paths
    brew_file = THIS_DIR / "brew.yaml"
    if not brew_file.exists():
        print(f"{Fore.RED}Error: {brew_file} not found{Style.RESET_ALL}")
        sys.exit(1)

    apps = yaml.safe_load(brew_file.read_text())
    local_paths = collect_config_paths(apps)

    # Load bin.yaml and collect bin scripts
    bin_file = THIS_DIR / "bin.yaml"
    bin_scripts = {}
    if bin_file.exists():
        bin_scripts = yaml.safe_load(bin_file.read_text()) or {}
    local_paths.extend(collect_bin_scripts(bin_scripts))

    # Collect shell config (bashrc etc.)
    local_paths.extend(collect_shell_config())

    if not local_paths:
        print(f"{Fore.YELLOW}No files to sync{Style.RESET_ALL}")
        sys.exit(0)

    print(f"{Fore.CYAN}Files to sync:{Style.RESET_ALL}")
    for _, rel in local_paths:
        print(f"  {rel}")

    # Select SSH host
    hosts = get_ssh_hosts()
    if not hosts:
        print(f"{Fore.RED}No SSH hosts found in ~/.ssh/config{Style.RESET_ALL}")
        sys.exit(1)

    host = fzf_select(hosts, "Select SSH host> ")
    ssh_cmd = get_ssh_cmd(host)

    # Select container
    print(f"{Fore.WHITE}Listing remote Docker containers...{Style.RESET_ALL}")
    containers = list_remote_containers(ssh_cmd)
    container_id = select_container(containers)
    print(f"  {Fore.GREEN}Selected container: {container_id[:12]}{Style.RESET_ALL}")

    # Target path in container
    target = input(
        f"{Fore.YELLOW}Target path in container [default: /root]: {Style.RESET_ALL}"
    ).strip()
    if not target:
        target = "/root"

    if not confirm(f"Copy all files to {target} in container {container_id[:12]}?"):
        sys.exit(0)

    archive = create_archive(local_paths)
    remote_tmp = f"/tmp/docker_config_sync_{archive.stem}"
    try:
        print(f"{Fore.WHITE}Transferring archive to remote host...{Style.RESET_ALL}")
        subprocess.run(
            f"scp {archive} {host}:{remote_tmp}.tar.gz",
            shell=True,
            check=True,
        )

        print(f"{Fore.WHITE}Extracting archive on remote host...{Style.RESET_ALL}")
        exec_remote(
            ssh_cmd,
            f"mkdir -p {remote_tmp} && tar -xzf {remote_tmp}.tar.gz -C {remote_tmp}",
        )

        print(f"{Fore.WHITE}Copying into container via docker cp...{Style.RESET_ALL}")
        exec_remote(ssh_cmd, f"docker cp {remote_tmp}/. {container_id}:{target}")

        # Set up shell config inside the container if bashrc was synced
        bashrc_synced = any(rel == Path("._bashrc") for _, rel in local_paths)
        if bashrc_synced:
            print(f"{Fore.WHITE}Configuring shell inside container...{Style.RESET_ALL}")
            exec_remote(
                ssh_cmd,
                f"docker exec {container_id} sed -i 's|^SHELL_DIR=.*|SHELL_DIR=\"$HOME/._shell\"|' {target}/._bashrc",
            )
            exec_remote(
                ssh_cmd,
                f"docker exec {container_id} bash -c \"grep -q 'source .*\\\\._bashrc' {target}/.bashrc 2>/dev/null || echo 'source {target}/._bashrc' >> {target}/.bashrc\"",
            )
            exec_remote(
                ssh_cmd,
                f"docker exec {container_id} chmod +x {target}/.local/bin/* 2>/dev/null || true",
            )

        print(
            f"{Fore.GREEN}Copied {len(local_paths)} items to {target}{Style.RESET_ALL}"
        )
    finally:
        exec_remote(ssh_cmd, f"rm -rf {remote_tmp} {remote_tmp}.tar.gz")
        archive.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
