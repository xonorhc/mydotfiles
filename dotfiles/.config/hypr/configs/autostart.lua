--    ___       __           __           __
--   / _ |__ __/ /____  ___ / /____ _____/ /_
--  / __ / // / __/ _ \(_-</ __/ _ `/ __/ __/
-- /_/ |_\_,_/\__/\___/___/\__/\_,_/_/  \__/
--

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	--  Core Components
	hl.exec_cmd(Run .. "noctalia")
	--  Clipboard Manager
	hl.exec_cmd(Run .. "wl-paste --type text --watch cliphist store")
	hl.exec_cmd(Run .. "wl-paste --type image --watch cliphist store")
	--  Optional / Utilities
	hl.exec_cmd("sleep 2 && " .. Run .. Terminal .. " -e btop", {
		workspace = "special:btop silent",
	})
	-- Portals launch after this gets executed
	hl.exec_cmd(ScriptsDir .. "xdph.sh")
	--  Finalize Session
	hl.exec_cmd("uwsm finalize")
end)
