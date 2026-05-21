#!/usr/bin/env python3
"""Idle inhibitor for waybar. One-shot mode: outputs state and exits."""

import json, os, subprocess, sys

SERVICE = "swayidle.service"
STATE_FILE = os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-idle-inhibit"
)


def is_inhibited():
    return os.path.exists(STATE_FILE)


def toggle():
    if is_inhibited():
        os.remove(STATE_FILE)
        subprocess.run(
            ["systemctl", "--user", "start", SERVICE],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    else:
        open(STATE_FILE, "w").close()
        subprocess.run(
            ["systemctl", "--user", "stop", SERVICE],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def emit():
    active = is_inhibited()
    print(
        json.dumps(
            {
                "text": "activated" if active else "deactivated",
                "alt": "activated" if active else "deactivated",
                "class": "activated" if active else "deactivated",
            }
        ),
        flush=True,
    )


if "--toggle" in sys.argv:
    toggle()

emit()
