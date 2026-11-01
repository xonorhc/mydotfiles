--    __ __         __   _         ___
--   / //_/__ __ __/ /  (_)__  ___/ (_)__  ___ ____
--  / ,< / -_) // / _ \/ / _ \/ _  / / _ \/ _ `(_-<
-- /_/|_|\__/\_, /_.__/_/_//_/\_,_/_/_//_/\_, /___/
--          /___/                        /___/

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Default apps
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(Run .. Terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(Run .. Terminal .. "-e yazi"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(Run .. Terminal .. "-e nvim"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(Run .. Terminal .. "-e jrnl study"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(Run .. Terminal .. "-e nb shell"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(Run .. Browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(Run .. Browser .. "--private-window"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(Run .. Browser .. "--private-window https://chatgpt.com/"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(Run .. FileManager))

-- Float apps
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(Run .. Terminal, { tag = "+float_term" }))
hl.bind(mainMod .. " + ALT + D", hl.dsp.exec_cmd(Run .. Terminal .. "-e " .. ScriptsDir .. "nb_daily", { tag = "+float_term" }))
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd( Run .. Terminal .. "-e jrnl --config-override editor 'nvim -c \"startinsert\"'", { tag = "+float_term" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(Run .. Terminal .. "-e lazydocker", { tag = "+float_term" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(Run .. Terminal .. "-e lazysql", { tag = "+float_term" }))

-- Menus & Tools
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill " .. Menu .. " || " .. Run .. Menu))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | " .. Run .. Menu .. " --dmenu --with-nth 2 " .. " | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-websearch"))
hl.bind(mainMod .. " + ALT + T", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-translate"))
hl.bind(mainMod .. " + SHIFT + SLASH", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-colorselector"))
hl.bind(mainMod .. " + SLASH", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-themeselector"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(Run .. "hyprpicker -a"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-emojipicker"))

-- System & Power
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(ScriptsDir .. "fuzzel-powermenu"))
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("systemctl --user restart 'app-*.service' && hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(Run .. "~/.config/waybar/launch"))
hl.bind("CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind("CTRL + ALT_R", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- Screenshots
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("grimblast save active - | swappy -f -"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("grimblast save output - | swappy -f -"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("grimblast save screen - | swappy -f -"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("grimblast save area - | swappy -f -"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.workspace.toggle_special("btop"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(ScriptsDir .. "minimize"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- To switch between windows in a floating workspace:
hl.bind("ALT + TAB", function()
    local window = hl.get_active_window()
    if not window then return end
    hl.dispatch(hl.dsp.window.cycle_next({
        floating = not window.floating,
        tiled = window.floating,
    }))
end, { description = "Switch focus between tiled and floating windows" })

-- Window actions
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow -j | jq '.pid' | xargs kill -9"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))

-- Per-layout binds
local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

		if not workspace then
			return
		end

		local layout = workspace.tiled_layout

		if bind_table[layout] then
			hl.dispatch(bind_table[layout])
		end
	end
end

hl.bind(mainMod .. "+ COMMA", layout_bind({
    scrolling = hl.dsp.layout("swapcol l"),  -- Scrolling: swap column with left one
    dwindle   = hl.dsp.layout("swapsplit"),  -- Dwindle: swap window split
    monocle   = hl.dsp.layout("cycleprev"),  -- Monocle and master: cycle prev window
    master    = hl.dsp.layout("swapprev"),
}))

hl.bind(mainMod .. "+ PERIOD", layout_bind({
    scrolling = hl.dsp.layout("swapcol r"),   -- Scrolling: swap column with right one
    dwindle   = hl.dsp.layout("togglesplit"), -- Dwindle: toggle window split
    monocle   = hl.dsp.layout("cyclenext"),   -- Monocle and master: cycle next window
    master    = hl.dsp.layout("swapnext"),
}))

-- Minimize windows using special workspaces
hl.bind("SUPER + X", function ()
    if hl.get_workspace("special:minimized") then
        hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
        hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
    else
        hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
        hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
    end
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Switch to a submap called `resize`.
hl.bind("ALT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Windows Magnifier-like cursor zoom
local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
    local current = hl.get_config("cursor.zoom_factor")
    if offset ~= nil then
        current = current + offset
    elseif current ~= MIN_ZOOM then
        current = MIN_ZOOM
    else
        current = ZOOM_TOGGLE_FACTOR
    end
    current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
    hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + Z", zoom)
hl.bind("SUPER + KP_ADD", function() zoom(0.5) end)
hl.bind("SUPER + minus", function() zoom(-0.5) end)

-- Close All Windows At Once
local function closeAllWindows()
    local windows = hl.get_windows()

    for _,w in pairs(windows) do
        hl.dispatch(hl.dsp.window.close({ window = w }))
    end
end

local function closeAllWindowsCurrentWorkspace()
    local cws = hl.get_active_workspace()
    local windows = hl.get_windows({ workspace = cws })

    for _,w in pairs(windows) do
        hl.dispatch(hl.dsp.window.close({ window = w }))
    end
end

hl.bind(mainMod .. "+BackSpace", closeAllWindowsCurrentWorkspace )
hl.bind(mainMod .. "+Delete", closeAllWindows )

-- Cycle layout for current workspace
hl.bind(mainMod .. "+ BACKSLASH", function ()
    local layouts   = { "scrolling", "dwindle", "master", "monocle" }
    local workspace = hl.get_active_workspace()
    if hl.get_active_special_workspace() then
        workspace = hl.get_active_special_workspace()
    end

    local next_layout = "dwindle"

    if not workspace then
        return
    end

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            local next_layout_idx = (i % #layouts) + 1
            next_layout = layouts[next_layout_idx]
            break
        end
    end

    if workspace then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
    else
        hl.workspace_rule({ workspace = "name:" .. tostring(workspace.name), layout = next_layout })
    end
end)
