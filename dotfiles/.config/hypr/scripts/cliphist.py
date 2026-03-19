#!/usr/bin/env python

import os
import subprocess
import sys


def run_command(args, input_str=None):
    """Helper to run shell commands and return output."""
    try:
        result = subprocess.run(
            args, input=input_str, capture_output=True, text=True, check=True
        )
        return result.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def main():
    rofi_config = os.path.expanduser("~/.config/rofi/config-cliphist.rasi")
    rofi_base = ["rofi", "-dmenu", "-replace", "-config", rofi_config]

    # Get the argument (like 'd' or 'w')
    arg = sys.argv[1] if len(sys.argv) > 1 else None

    if arg == "w":
        subprocess.run(["cliphist", "wipe"])

    elif arg == "d":
        history = run_command(["cliphist", "list"])
        if history:
            selected = run_command(rofi_base, input_str=history)
            if selected:
                subprocess.run(["cliphist", "delete"], input=selected, text=True)

    else:
        history = run_command(["cliphist", "list"])
        if history:
            selected = run_command(rofi_base, input_str=history)
            if selected:
                decoded = run_command(["cliphist", "decode"], input_str=selected)
                if decoded:
                    subprocess.run(["wl-copy"], input=decoded, text=True)


if __name__ == "__main__":
    main()
