#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys


def launch_program(command_args):
    """Starts a process in a new session, detached from the parent."""
    try:
        subprocess.Popen(
            command_args,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
            env=os.environ,
        )
    except Exception as error:
        print(f"Error: Failed to start the process. {error}", file=sys.stderr)


def get_best_launcher():
    """Selects the appropriate launcher based on the display server."""
    is_wayland = os.environ.get("WAYLAND_DISPLAY") is not None

    # Priority: Fuzzel for Wayland, Rofi for X11 (or as a fallback)
    if is_wayland and shutil.which("fuzzel"):
        return [shutil.which("fuzzel")]

    rofi_path = shutil.which("rofi")
    if rofi_path:
        return [rofi_path, "-show", "drun"]

    return None


def main():
    command = get_best_launcher()

    if not command:
        print(
            "Error: No compatible launcher found (check Fuzzel or Rofi).",
            file=sys.stderr,
        )
        sys.exit(1)

    launch_program(command)


if __name__ == "__main__":
    main()
