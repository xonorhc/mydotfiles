#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# zshrc loader
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/zshrc
# or by creating a folder ~/.config/zshrc/custom
# with copies of files from ~/.config/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configuration
# -----------------------------------------------------

for f in "$HOME"/.config/zshrc/*; do
    if [ -f "$f" ]; then
        source "$f"
    fi
done

if [ -d "$HOME"/.config/zshrc/custom ]; then
    for f in "$HOME"/.config/zshrc/custom/*; do
        if [ -f "$f" ]; then
            source "$f"
        fi
    done
fi

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f "$HOME"/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi
