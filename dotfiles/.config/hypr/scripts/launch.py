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


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <program_name> [arguments]", file=sys.stderr)
        sys.exit(1)

    program_name = sys.argv[1]
    program_path = shutil.which(program_name)

    if not program_path:
        print(f"Error: Program '{program_name}' not found in PATH.", file=sys.stderr)
        sys.exit(1)

    arguments = sys.argv[1:]

    launch_program(arguments)


if __name__ == "__main__":
    main()
