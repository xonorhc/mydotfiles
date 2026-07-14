--  _  _               _              _
-- | || |_  _ _ __ _ _| |__ _ _ _  __| |
-- | __ | || | '_ \ '_| / _` | ' \/ _` |
-- |_||_|\_, | .__/_| |_\__,_|_||_\__,_|
--       |__/|_|
-- Advanced configuration for Hyprland

---- MONITORS ----
require("configs.monitors")

---- MY PROGRAMS ----
Run         = "uwsm app -- "
Terminal    = "foot" .. " "
FileManager = "thunar" .. " "
Browser     = "flatpak run app.zen_browser.zen" .. " "
ScriptsDir  = os.getenv("HOME") .. "/.config/hypr/scripts/"

---- AUTOSTART ----
require("configs.autostart")

---- ENVIRONMENT VARIABLES ----
require("configs.environment")

----- PERMISSIONS -----
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/wf-recorder", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "^(io.github.seadve.Kooha)$" , type = "screencopy", mode = "allow" })

---- LOOK AND FEEL ----
require("colors")
require("configs.decoration")
require("configs.animation")
require("configs.layout")
require("configs.cursor")

----  MISC  ----
require("configs.misc")

---- INPUT ----
require("configs.input")

---- KEYBINDINGS ----
require("configs.keybindings")

---- WINDOWS AND WORKSPACES ----
require("configs.windowrule")
require("configs.workspace")

---- CUSTOM ----
require("configs.custom")
