-- __      __       _                           ___      _
-- \ \    / /__ _ _| |__ ____ __  __ _ __ ___  | _ \_  _| |___ ___
--  \ \/\/ / _ \ '_| / /(_-< '_ \/ _` / _/ -_) |   / || | / -_|_-<
--   \_/\_/\___/_| |_\_\/__/ .__/\__,_\__\___| |_|_\\_,_|_\___/__/
--                         |_|

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({ workspace = "m[eDP-1]", layout = "master", layout_opts = { orientation = "left" } })
hl.workspace_rule({ workspace = "m[HDMI-A-1]", layout = "scrolling" })

-----------------------------------------------------------------------------
-- SPECIAL WORKSPACES
-----------------------------------------------------------------------------
hl.workspace_rule({ workspace = "special:magic", on_created_empty = "kitty" })

hl.workspace_rule({
	workspace = "special:btop",
	on_created_empty = "kitty -e btop",
	no_rounding = true,
	gaps_out = 20,
	border_size = 3,
})
