"""Archive transfer utilities for syncing files via SSH."""

import shutil
import subprocess
import tarfile
import tempfile
from pathlib import Path


def sync_archive(
    host: str,
    ssh_cmd: str,
    local_paths: list[tuple[Path, Path]],
    remote_extract_dir: str = "~",
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
) -> int:
    """Create tar archive from local paths, transfer via scp, and extract on remote.

    Args:
        host: SSH host string
        ssh_cmd: Full ssh command (e.g., "ssh user@host")
        local_paths: List of (absolute_src_path, relative_dest_path) tuples
        remote_extract_dir: Directory to extract archive on remote
        proxy: Whether to use proxy for remote commands
        proxy_mode: "http" or "socks"
        proxy_port: Proxy port number

    Returns:
        Number of items transferred
    """
    from ssh_utils import exec_remote

    if not local_paths:
        return 0

    with tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False) as tmp:
        tmp_path = Path(tmp.name)
    try:
        with tarfile.open(tmp_path, "w:gz") as tar:
            for src, rel in local_paths:
                tar.add(str(src), arcname=str(rel))

        archive_size = tmp_path.stat().st_size / 1024 / 1024
        print(f"  Transferring archive ({archive_size:.2f} MB)...")
        subprocess.run(
            f"scp {tmp_path} {host}:/tmp/sync_archive.tar.gz",
            shell=True,
            check=True,
        )

        exec_remote(
            ssh_cmd,
            f"tar -xzf /tmp/sync_archive.tar.gz -C {remote_extract_dir} && rm /tmp/sync_archive.tar.gz",
            proxy=proxy,
            proxy_mode=proxy_mode,
            proxy_port=proxy_port,
        )
        return len(local_paths)
    finally:
        tmp_path.unlink(missing_ok=True)


def collect_config_paths(apps: dict) -> list[tuple[Path, Path]]:
    """Collect config file paths from apps dict.

    Returns list of (absolute_path, relative_to_home) tuples.
    """
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
                    if f.is_dir():
                        for child in sorted(f.rglob("*")):
                            if child.is_file() or child.is_dir():
                                real_child = child.resolve()
                                if real_child.is_file():
                                    all_paths.append(
                                        (real_child, child.relative_to(Path.home()))
                                    )
                    else:
                        rel_path = f.relative_to(Path.home())
                        all_paths.append((f.resolve(), rel_path))
    return all_paths


def sync_configs(
    host: str,
    ssh_cmd: str,
    apps: dict,
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
) -> None:
    """Sync config files from apps dict to remote host."""
    from ssh_utils import exec_remote

    local_paths = collect_config_paths(apps)
    if not local_paths:
        print("  No config files to sync")
        return

    # Remove existing files on remote
    rm_paths = " ".join(f"~/{rp}" for _, rp in local_paths)
    print("  Removing existing files on remote...")
    exec_remote(
        ssh_cmd,
        f"rm -rf {rm_paths}",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )

    count = sync_archive(
        host,
        ssh_cmd,
        local_paths,
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    print(f"  Extracted {count} items")


def sync_scripts(
    host: str,
    ssh_cmd: str,
    bin_scripts: set[str],
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
) -> None:
    """Sync .local/bin scripts and shell config to remote host."""
    from ssh_utils import exec_remote

    this_dir = Path(__file__).parent
    archive_paths = []

    # Collect .local/bin scripts
    local_bin = this_dir.parent.parent / ".local" / "bin"
    for name in sorted(bin_scripts):
        src = local_bin / name
        if src.exists():
            rel = Path(".local/bin") / name
            archive_paths.append((src, rel))
            print(f"  Adding {rel}")
        else:
            print(f"  Skip {name} (not found)")

    # Collect bashrc and common shell scripts
    shell_dir = this_dir.parent.parent / "shell"
    bashrc_local = shell_dir / "bash/.bashrc"
    common_dir = shell_dir / "common"
    if bashrc_local.exists():
        archive_paths.append((bashrc_local, Path("._bashrc")))
        print(f"  Adding ._bashrc")
        if common_dir.exists():
            for sh in sorted(common_dir.glob("*.sh")):
                rel = Path("._shell/common") / sh.name
                archive_paths.append((sh, rel))
                print(f"  Adding {rel}")

    if not archive_paths:
        print("  No scripts to sync")
        return

    exec_remote(
        ssh_cmd,
        "mkdir -p ~/.local/bin ~/._shell/common",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )

    # Build tar from staging dir
    with tempfile.TemporaryDirectory() as td:
        staging = Path(td)
        for src, rel in archive_paths:
            dest = staging / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(str(src), str(dest))

        tmp_tar = staging / "_archive.tar.gz"
        with tarfile.open(tmp_tar, "w:gz") as tar:
            for _, rel in archive_paths:
                tar.add(str(staging / rel), arcname=str(rel))

        archive_size = tmp_tar.stat().st_size / 1024 / 1024
        print(f"  Transferring ({archive_size:.2f} MB)...")
        subprocess.run(
            f"scp {tmp_tar} {host}:/tmp/scripts_sync.tar.gz",
            shell=True,
            check=True,
        )

    exec_remote(
        ssh_cmd,
        "tar -xzf /tmp/scripts_sync.tar.gz -C ~ && rm /tmp/scripts_sync.tar.gz",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    exec_remote(
        ssh_cmd,
        "chmod +x ~/.local/bin/* 2>/dev/null || true",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )

    # Fix SHELL_DIR in remote ._bashrc
    if bashrc_local.exists() and common_dir.exists():
        exec_remote(
            ssh_cmd,
            """sed -i 's|^SHELL_DIR=.*|SHELL_DIR="$HOME/._shell"|' ~/._bashrc""",
            proxy=proxy,
            proxy_mode=proxy_mode,
            proxy_port=proxy_port,
        )
    # Source it in remote .bashrc
    exec_remote(
        ssh_cmd,
        r"""grep -q 'source.*\._bashrc' ~/.bashrc 2>/dev/null || echo 'source $HOME/._bashrc' >> ~/.bashrc""",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    print(f"  Copied {len(archive_paths)} items")


def sync_vibe(
    host: str,
    ssh_cmd: str,
    proxy: bool = False,
    proxy_mode: str = "http",
    proxy_port: int = 7890,
) -> None:
    """Sync vibe directory to remote host."""
    from ssh_utils import exec_remote

    this_dir = Path(__file__).parent
    vibe_dir = this_dir.parent.parent / "vibe"
    if not vibe_dir.exists():
        print(f"  vibe/ not found at {vibe_dir}")
        return

    local_paths = []
    for item in sorted(vibe_dir.iterdir()):
        if item.name == ".git":
            continue
        local_paths.append((item, Path(f"vibe/{item.name}")))

    count = sync_archive(
        host,
        ssh_cmd,
        local_paths,
        remote_extract_dir="~/workspace",
        proxy=proxy,
        proxy_mode=proxy_mode,
        proxy_port=proxy_port,
    )
    print(f"  vibe/ uploaded to ~/workspace/vibe/")
