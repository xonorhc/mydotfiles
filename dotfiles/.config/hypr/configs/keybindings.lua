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
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(Run .. Browser .. "--private-window https://gemini.google.com/app"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(Run .. FileManager))

-- Float apps
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(Run .. Terminal, { tag = "+float_term" }))
hl.bind(mainMod .. " + ALT + D", hl.dsp.exec_cmd(Run .. Terminal .. "-e " .. ScriptsDir .. "nb_daily", { tag = "+float_term" }))
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd( Run .. Terminal .. "-e jrnl --config-override editor 'nvim -c \"startinsert\"'", { tag = "+float_term" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(Run .. Terminal .. "-e lazydocker", { tag = "+float_term" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(Run .. Terminal .. "-e lazysql", { tag = "+float_term" }))

-- Menus & Tools
local ipc = "dms ipc call" .. " "
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. "spotlight toggle"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "clipboard toggle"))
hl.bind(mainMod .. " + SLASH", hl.dsp.exec_cmd(ipc .. "settings focusOrToggle"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(ipc .. "dankdash wallpaper"))
hl.bind("SHIFT + Tab", hl.dsp.exec_cmd(ipc .. "hypr toggleOverview"))
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(ipc .. "powermenu toggle"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd(ipc .. "processlist focusOrToggle"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd("dms color pick"))

-- System & Power
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("systemctl --user restart 'app-*.service' && hyprctl reload"))

-- Screenshots
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("dms screenshot"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("dms screenshot full"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("dms screenshot window"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
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
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next()) -- Change focus to another window
	hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

-- Window actions
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow -j | jq '.pid' | xargs kill -9"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("orientationnext")) -- master only
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapwithmaster master")) -- master only
hl.bind(mainMod .. " + PERIOD", hl.dsp.layout("move +col")) -- scroll only
hl.bind(mainMod .. " + COMMA", hl.dsp.layout("swapcol l")) -- scroll only

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
