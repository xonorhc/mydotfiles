--   _____         __
--  / ___/_ _____ / /____  __ _
-- / /__/ // (_-</ __/ _ \/  ' \
-- \___/\_,_/___/\__/\___/_/_/_/
--
-- Add your additional Hyprland configurations here

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
end)
