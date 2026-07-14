--    __  ___          _ __
--   /  |/  /__  ___  (_) /____  _______
--  / /|_/ / _ \/ _ \/ / __/ _ \/ __(_-<
-- /_/  /_/\___/_//_/_/\__/\___/_/ /___/
--
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({ output = "eDP-1", mode = "1920x1080", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "-1920x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto-left", scale = 1 })
