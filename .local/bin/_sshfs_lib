#!/usr/bin/env bash
# sshfs shared library

# Core mount function with common options
sshfs_mount() {
    sshfs \
        -o default_permissions \
        -o uid=$(id -u) \
        -o gid=$(id -g) \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3 \
        -o dir_cache=yes \
        -o dcache_max_size=100000 \
        -o dcache_timeout=1200 \
        -o max_conns=4 \
        -o compression=yes \
        "$@"
}

# Smart mount: detect and remount if mount point is dead
sshfs_smart_mount() {
    local mount_dir="$1"
    local remote_path="$2"

    mkdir -p "$mount_dir"

    # Check if mount point is dead (perms 000 or empty directory)
    local perms=$(stat -c %a "$mount_dir" 2>/dev/null)
    local file_count=$(ls -A "$mount_dir" 2>/dev/null | wc -l)

    if [ "$perms" = "000" ] || [ "$file_count" -eq 0 ]; then
        echo "[$mount_dir] Dead mount detected (perms=$perms, files=$file_count), remounting..."
        fusermount3 -u -z "$mount_dir" 2>/dev/null
        sshfs_mount "$remote_path" "$mount_dir"
        echo "[$mount_dir] Remount complete"
    else
        echo "[$mount_dir] Mount OK"
    fi
}

# Unmount helper
sshfs_umount() {
    local mount_dir="$1"
    fusermount3 -u -z "$mount_dir" 2>/dev/null || umount "$mount_dir" 2>/dev/null
}
