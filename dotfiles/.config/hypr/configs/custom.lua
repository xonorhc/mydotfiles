--   _____         __
--  / ___/_ _____ / /____  __ _
-- / /__/ // (_-</ __/ _ \/  ' \
-- \___/\_,_/___/\__/\___/_/_/_/
--
-- Add your additional Hyprland configurations here

hl.on("hyprland.start", function()
	hl.exec_cmd("sleep 300 && " .. Run .. "flatpak run org.qbittorrent.qBittorrent")
end)

hl.env("NVIM_APPNAME", "nvim-astro6")
