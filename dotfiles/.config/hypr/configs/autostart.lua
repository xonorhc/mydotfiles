--    ___       __           __           __
--   / _ |__ __/ /____  ___ / /____ _____/ /_
--  / __ / // / __/ _ \(_-</ __/ _ `/ __/ __/
-- /_/ |_\_,_/\__/\___/___/\__/\_,_/_/  \__/
--

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	--  Core Components
	hl.exec_cmd(Run .. "waybar")
	hl.exec_cmd(Run .. "swaync")
	hl.exec_cmd(Run .. "hyprpaper")
	--  Clipboard Manager
	hl.exec_cmd(Run .. "wl-paste --type text --watch cliphist store")
	hl.exec_cmd(Run .. "wl-paste --type image --watch cliphist store")
	--  Optional / Utilities
	hl.exec_cmd("[workspace special:btop silent] sleep 2 && uwsm app -- kitty --class btop-monitor -e btop")
	-- Portals launch after this gets executed
	hl.exec_cmd(ScriptsDir .. "xdph.sh")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	--  Finalize Session
	hl.exec_cmd("uwsm finalize")
end)
