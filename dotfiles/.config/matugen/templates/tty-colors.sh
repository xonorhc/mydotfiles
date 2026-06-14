#!/bin/sh

if [ "$TERM" = "linux" ]; then
  echo -en "\e]P0{{colors.background.default.hex_stripped}}"    # Black
  echo -en "\e]P1{{base16.base08.default.hex_stripped}}"        # Red
  echo -en "\e]P2{{base16.base0b.default.hex_stripped}}"        # Green
  echo -en "\e]P3{{base16.base0a.default.hex_stripped}}"        # Yellow
  echo -en "\e]P4{{base16.base0d.default.hex_stripped}}"        # Blue
  echo -en "\e]P5{{base16.base0e.default.hex_stripped}}"        # Magenta
  echo -en "\e]P6{{base16.base0c.default.hex_stripped}}"        # Cyan
  echo -en "\e]P7{{colors.on_background.default.hex_stripped}}" # White

  clear
fi
