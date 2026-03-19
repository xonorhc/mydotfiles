#!/usr/bin/env python3

import os
import subprocess


def open_kitty_fixed():
    commands = (
        "clear; "
        'figlet -f smslant "Systeminfo" || echo "Instale o figlet"; '
        "echo; "
        "hyprctl systeminfo; "
        "echo; "
        'echo "Press Enter to close..."; '
        "read"
    )

    args = ["kitty", "sh", "-c", commands]

    try:
        subprocess.Popen(args, env=os.environ.copy(), start_new_session=True)
    except FileNotFoundError:
        print("Error: The command 'kitty' was not found in your PATH.")
    except Exception as e:
        print(f"Error when trying to open the terminal: {e}")


if __name__ == "__main__":
    open_kitty_fixed()
