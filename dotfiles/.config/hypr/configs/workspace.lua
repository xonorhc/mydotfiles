-- __      __       _                           ___      _
-- \ \    / /__ _ _| |__ ____ __  __ _ __ ___  | _ \_  _| |___ ___
--  \ \/\/ / _ \ '_| / /(_-< '_ \/ _` / _/ -_) |   / || | / -_|_-<
--   \_/\_/\___/_| |_\_\/__/ .__/\__,_\__\___| |_|_\\_,_|_\___/__/
--                         |_|

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })

hl.workspace_rule({ workspace = "m[HDMI-A-1]", layout = "monocle" })

-----------------------------------------------------------------------------
-- SPECIAL WORKSPACES
-----------------------------------------------------------------------------

-- Launching programs on workspace creation
local workspace_programs = {
	["special:scratchpad"] = { Run .. Terminal, {} },
	["special:btop"] = { Run .. Terminal .. " -e btop", {} },
}

hl.on("workspace.created", function(ws)
	if not ws.is_empty then
		return
	end

	local program = workspace_programs[ws.name]
	if not program then
		return
	end

	local cmd, rules = table.unpack(program)

	local rules2 = {}
	for k, v in pairs(rules) do
		rules2[k] = v
	end

	rules2.workspace = ws.name .. " silent"

	hl.exec_cmd(cmd, rules2)
end)

hl.workspace_rule({
	workspace = "special:scratchpad",
	gaps_out = 30,
	gaps_in = 15,
})

hl.workspace_rule({
	workspace = "special:btop",
	no_rounding = true,
	gaps_out = 20,
	border_size = 3,
})
