#!/usr/bin/env bash
#  _      __     ____
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/
#                /_/       /_/

# Notifications
source "$HOME/.config/hypr/scripts/notification-handler"
APP_NAME="Waypaper"
NOTIFICATION_ICON="preferences-desktop-wallpaper-symbolic"

# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

if [ -f ~/.config/hypr/settings/wallpaper_cache ]; then
    use_cache=1
    _writeLog "Using Wallpaper Cache"
else
    use_cache=0
    _writeLog "Wallpaper Cache disabled"
fi

# -----------------------------------------------------
# Create cache folder
# -----------------------------------------------------
cache_folder="$HOME/.cache/hyprland-dotfiles"

if [ ! -d $cache_folder ]; then
    mkdir -p $cache_folder
fi

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0

# Cache for generated wallpapers with effects
generatedversions="$cache_folder/wallpaper-generated"
if [ ! -d $generatedversions ]; then
    mkdir -p $generatedversions
fi

# Will be set when waypaper is running
waypaperrunning=$cache_folder/waypaper-running
if [ -f $waypaperrunning ]; then
    rm $waypaperrunning
    exit
fi

cachefile="$cache_folder/current_wallpaper"
blurredwallpaper="$cache_folder/blurred_wallpaper.png"
squarewallpaper="$cache_folder/square_wallpaper.png"
rasifile="$cache_folder/current_wallpaper.rasi"
defaultwallpaper="$HOME/Dropbox/wallpaper/TokyoNight/skeleton.png"
wallpapereffect="$HOME/.config/hypr/settings/wallpaper-effect"
blur="50x30"

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z "$1" ]; then
    if [ -f "$cachefile" ]; then
        wallpaper=$(cat "$cachefile")
        # Remove escaped backslashes from the path (convert "\ " to " ")
        wallpaper=$(echo "$wallpaper" | sed 's/\\ / /g')
    else
        wallpaper="$defaultwallpaper"
    fi
else
    wallpaper="$1"
    # Remove escaped backslashes from the path (convert "\ " to " ")
    wallpaper=$(echo "$wallpaper" | sed 's/\\ / /g')
fi
used_wallpaper="$wallpaper"
_writeLog "Setting wallpaper with source image $wallpaper"
tmpwallpaper=$wallpaper

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cachefile ]; then
    touch $cachefile
fi
echo "$wallpaper" >$cachefile
_writeLog "Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------

wallpaperfilename=$(basename "$wallpaper")
_writeLog "Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

if [ -f "$wallpapereffect" ]; then
    effect=$(cat "$wallpapereffect")
    if [ ! "$effect" == "off" ]; then
        used_wallpaper="$generatedversions/$effect-$wallpaperfilename"
        if [ -f "$generatedversions/$effect-$wallpaperfilename" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
            _writeLog "Use cached wallpaper $effect-$wallpaperfilename"
        else
            _writeLog "Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"

            notify_user \
                --a "${APP_NAME}" \
                --i "${NOTIFICATION_ICON}" \
                --s "Wallpaper" \
                --m "Using wallpaper effect $effect\n with image $wallpaperfilename"

            source $HOME/.config/hypr/effects/wallpaper/$effect
        fi
        _writeLog "Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
        _writeLog "Setting wallpaper with $used_wallpaper"
        touch "$waypaperrunning"
        waypaper --wallpaper "$used_wallpaper"
    else
        _writeLog "Wallpaper effect is set to off"
    fi
else
    effect="off"
fi

# -----------------------------------------------------
# Detect Theme
# -----------------------------------------------------

SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"
THEME_PREF=$(grep -E '^gtk-application-prefer-dark-theme=' "$SETTINGS_FILE" | awk -F'=' '{print $2}')

# -----------------------------------------------------
# Execute matugen
# -----------------------------------------------------

_writeLog "Execute matugen with $used_wallpaper"
if [ "$THEME_PREF" -eq 1 ]; then
    $HOME/.local/bin/matugen image "$used_wallpaper" -m "dark" \
        --type scheme-fidelity --contrast 0.3
else
    $HOME/.local/bin/matugen image "$used_wallpaper" -m "light"
fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------

sleep 1
$HOME/.config/waybar/launch.sh

# -----------------------------------------------------
# Update SwayNC
# -----------------------------------------------------

sleep 0.1
swaync-client -rs

# -----------------------------------------------------
# Created blurred wallpaper
# -----------------------------------------------------

if [ -f "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
    _writeLog "Use cached wallpaper blur-$blur-$effect-$wallpaperfilename"
else
    _writeLog "Generate new cached wallpaper blur-$blur-$effect-$wallpaperfilename with blur $blur"
    magick "$used_wallpaper" -resize 75% "$blurredwallpaper"
    _writeLog "Resized to 75%"
    if [ ! "$blur" == "0x0" ]; then
        magick "$blurredwallpaper" -blur $blur "$blurredwallpaper"
        cp "$blurredwallpaper" "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png"
        _writeLog "Blurred"
    fi
fi
cp "$generatedversions/blur-$blur-$effect-$wallpaperfilename.png" "$blurredwallpaper"

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
    touch $rasifile
fi
echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

# -----------------------------------------------------
# Created square wallpaper
# -----------------------------------------------------

_writeLog "Generate new cached wallpaper square-$wallpaperfilename"
magick "$tmpwallpaper" -gravity Center -extent 1:1 "$squarewallpaper"
cp "$squarewallpaper" "$generatedversions/square-$wallpaperfilename.png"
