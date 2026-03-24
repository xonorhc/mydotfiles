#!/usr/bin/env python3

import os
import subprocess
import sys


def run_rofi(prompt, config_path, dmenu=True):
    """Helper to run Rofi and return the user's input."""
    cmd = ["rofi", "-config", config_path, "-p", prompt]
    if dmenu:
        cmd.append("-dmenu")

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def main():
    config_path = os.path.expanduser("~/.config/rofi/config-translate.rasi")

    # 1. Ask for the TEXT
    text_to_translate = run_rofi("Translate:", config_path)
    if not text_to_translate:
        sys.exit(0)

    # 2. Ask for the LANGUAGE (Defaults to English if empty)
    target_lang = run_rofi("To Language (e.g. pt, en, ja):", config_path)

    # Prepare the language argument for 'trans'
    lang_arg = f":{target_lang}" if target_lang else ":en"

    # 3. Run the translation
    translate_cmd = ["trans", "-brief", lang_arg, text_to_translate]

    try:
        result = subprocess.run(
            translate_cmd, capture_output=True, text=True, check=True
        )
        translation = result.stdout.strip()
    except subprocess.CalledProcessError:
        subprocess.run(["notify-send", "Error", "Translation failed."])
        sys.exit(1)

    if not translation:
        sys.exit(0)

    # 4. Copy to clipboard (Wayland)
    subprocess.run(["wl-copy"], input=translation, text=True)

    # 5. Notify and Show Result
    summary = (translation[:50] + "...") if len(translation) > 50 else translation
    subprocess.run(["notify-send", f"Translated to {target_lang or 'en'}", summary])

    # Show full text in Rofi -e (echo mode)
    subprocess.run(["rofi", "-config", config_path, "-e", translation])


if __name__ == "__main__":
    main()
