"""Homebrew Linux ELF interpreter fix utilities.

When Homebrew's patchelf cannot run due to system glibc/libstdc++ being too old,
bottle-installed binaries have @@HOMEBREW_PREFIX@@ placeholder in their ELF interpreter
path. This module provides fallback mechanisms to fix those binaries.
"""

import subprocess
import sys
from pathlib import Path

from colorama import Fore, Style


def _exec_ssh(ssh_cmd: str, cmd: str) -> subprocess.CompletedProcess:
    """Execute command on remote server, matching brew_sync.py's quoting logic."""
    cmd_escaped = cmd.replace("$", "\\$").replace('"', '\\"')
    full = f'{ssh_cmd} "{cmd_escaped}"'
    return subprocess.run(full, shell=True, capture_output=True, text=True)


def check_patchelf_runs(ssh_cmd: str) -> bool:
    """Check if Homebrew's patchelf can actually execute."""
    result = _exec_ssh(ssh_cmd, "/home/linuxbrew/.linuxbrew/bin/patchelf --version")
    return result.returncode == 0 and "patchelf" in result.stdout


def build_static_patchelf(ssh_cmd: str) -> str:
    """Build a statically-linked patchelf from source on the remote.

    Returns the path to the compiled patchelf binary.
    """
    print(
        f"{Fore.YELLOW}[patchelf] Homebrew patchelf cannot run, building from source...{Style.RESET_ALL}"
    )
    # Build patchelf from source without static linking (system libstdc++ is old enough)
    build_cmd = r"""cd /tmp && \
if [ ! -f /tmp/patchelf-dynamic ]; then \
    wget -q https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0.tar.bz2 && \
    tar xf patchelf-0.18.0.tar.bz2 && \
    cd patchelf-0.18.0 && \
    ./configure && \
    make -j$(nproc) && \
    cp src/patchelf /tmp/patchelf-dynamic && \
    echo "built"; \
else \
    echo "exists"; \
fi"""
    result = _exec_ssh(ssh_cmd, build_cmd)
    if result.returncode != 0:
        print(f"{Fore.RED}[patchelf] Build failed: {result.stderr}{Style.RESET_ALL}")
        sys.exit(1)
    print(f"{Fore.GREEN}[patchelf] Built at /tmp/patchelf-dynamic{Style.RESET_ALL}")
    return "/tmp/patchelf-dynamic"


def fix_elf_interpreter(ssh_cmd: str, patchelf_path: str, binary_path: str) -> bool:
    """Fix ELF interpreter and RPATH for a single binary using the given patchelf."""
    needs_fix = False
    has_interpreter = False

    # Check interpreter (only for executables, not .so files)
    result = _exec_ssh(ssh_cmd, f"readelf -l {binary_path} | grep interpreter")
    if "interpreter" in result.stdout:
        has_interpreter = True
        if "@@HOMEBREW_PREFIX@@" in result.stdout:
            needs_fix = True

    # Check RPATH - always ensure it points to linuxbrew lib
    rpath_result = _exec_ssh(ssh_cmd, f"{patchelf_path} --print-rpath {binary_path}")
    if "/home/linuxbrew/.linuxbrew/lib" not in rpath_result.stdout:
        needs_fix = True

    if not needs_fix:
        return True

    # Build fix command: only set interpreter for executables
    fix_cmd = f"chmod +w {binary_path}"
    if has_interpreter:
        fix_cmd += f" && {patchelf_path} --set-interpreter /home/linuxbrew/.linuxbrew/lib/ld.so {binary_path}"
    fix_cmd += (
        f" && {patchelf_path} --set-rpath /home/linuxbrew/.linuxbrew/lib {binary_path}"
    )
    fix_cmd += f" && chmod -w {binary_path}"

    result = _exec_ssh(ssh_cmd, fix_cmd)
    if result.returncode != 0:
        # Filter out known harmless errors
        err = result.stderr.strip()
        if "Text file busy" in err:
            print(
                f"{Fore.YELLOW}[patchelf] Skipping {binary_path} (file in use){Style.RESET_ALL}"
            )
        elif "wrong ELF type" in err or "not an ELF executable" in err:
            print(
                f"{Fore.YELLOW}[patchelf] Skipping {binary_path} (not a dynamic binary){Style.RESET_ALL}"
            )
        elif "cannot find section '.dynamic'" in err:
            print(
                f"{Fore.YELLOW}[patchelf] Skipping {binary_path} (statically linked){Style.RESET_ALL}"
            )
        else:
            print(
                f"{Fore.RED}[patchelf] Failed to fix {binary_path}: {err}{Style.RESET_ALL}"
            )
        return False
    return True


def find_broken_binaries(ssh_cmd: str) -> list[str]:
    """Find all Homebrew binaries with broken ELF interpreter or missing RPATH."""
    # Find ELF binaries with broken interpreter or missing RPATH
    find_cmd = r"""find /home/linuxbrew/.linuxbrew/Cellar -type f \( -executable -o -name '*.so*' \) 2>/dev/null | while read f; do \
    if ! file -b "$f" 2>/dev/null | grep -q 'ELF'; then \
        continue; \
    fi; \
    case "$f" in \
        *.o|*.a) continue ;; \
    esac; \
    if ! readelf -d "$f" 2>/dev/null | grep -q 'DYNAMIC'; then \
        continue; \
    fi; \
    if readelf -l "$f" 2>/dev/null | grep -q 'interpreter.*@@HOMEBREW_PREFIX@@'; then \
        echo "$f"; \
        continue; \
    fi; \
    if readelf -d "$f" 2>/dev/null | grep -qE 'RPATH|RUNPATH'; then \
        rpath=$(readelf -d "$f" 2>/dev/null | grep -E 'RPATH|RUNPATH' | sed 's/.*\[\(.*\)\].*/\1/'); \
        if [ -z "$rpath" ] || ! echo "$rpath" | grep -q 'linuxbrew'; then \
            echo "$f"; \
        fi; \
    else \
        echo "$f"; \
    fi; \
done"""
    result = _exec_ssh(ssh_cmd, find_cmd)
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def fix_all_broken_binaries(ssh_cmd: str) -> tuple[int, int]:
    """Fix all Homebrew binaries with broken ELF interpreter or RPATH.

    Returns (fixed_count, total_count).
    """
    from prompt_utils import confirm

    if not confirm("Check and fix broken ELF binaries?"):
        return 0, 0

    broken = find_broken_binaries(ssh_cmd)
    if not broken:
        print(f"{Fore.GREEN}[patchelf] No broken binaries found{Style.RESET_ALL}")
        return 0, 0

    print(
        f"{Fore.YELLOW}[patchelf] Found {len(broken)} broken binaries{Style.RESET_ALL}"
    )
    if not confirm("Fix broken ELF binaries?"):
        return 0, len(broken)

    # Determine which patchelf to use
    if check_patchelf_runs(ssh_cmd):
        print(f"{Fore.GREEN}[patchelf] Homebrew patchelf works{Style.RESET_ALL}")
        patchelf_path = "/home/linuxbrew/.linuxbrew/bin/patchelf"
    else:
        patchelf_path = build_static_patchelf(ssh_cmd)

    fixed = 0
    for binary in broken:
        if fix_elf_interpreter(ssh_cmd, patchelf_path, binary):
            fixed += 1

    print(
        f"{Fore.GREEN}[patchelf] Fixed {fixed}/{len(broken)} binaries{Style.RESET_ALL}"
    )
    return fixed, len(broken)
