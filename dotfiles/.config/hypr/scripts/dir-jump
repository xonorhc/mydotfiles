#!/usr/bin/env bash
res=$(find $HOME -maxdepth 3 -type d 2>/dev/null | fuzzel --dmenu --placeholder "Go to...")
[ -n "$res" ] && nemo "$res"
