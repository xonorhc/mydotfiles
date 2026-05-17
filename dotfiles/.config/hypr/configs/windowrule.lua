--  _      ___         __             ___       __
-- | | /| / (_)__  ___/ /__ _    __  / _ \__ __/ /__ ___
-- | |/ |/ / / _ \/ _  / _ \ |/|/ / / , _/ // / / -_|_-<
-- |__/|__/_/_//_/\_,_/\___/__,__/ /_/|_|\_,_/_/\__/___/
--

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-----------------------------------------------------------------------------
-- GENERAL / GLOBAL SETTINGS
-----------------------------------------------------------------------------

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class      = "^$",
		title      = "^$",
		xwayland   = true,
		float      = true,
		fullscreen = false,
		pin        = false,
	},

	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name  = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move  = "20 monitor_h-120",
	float = true,
})

-- Hyprland Share Picker
hl.window_rule({
	name   = "float-share-picker",
	match  = { class = "^(hyprland-share-picker)$" },
	float  = true,
	center = true,
	opaque = true,
	size   = "500 300",
})

-----------------------------------------------------------------------------
-- COMMON DIALOGS / FILE PICKERS
-----------------------------------------------------------------------------

hl.window_rule({
	name   = "float-dialogs-title",
	match  = { title = "^(Open|Open File|Select a File|Choose wallpaper|Open Folder|Save As|Library|File Upload|Authentication Required|Add Folder to Workspace|Choose Files|Confirm to replace files|File Operation Progress)(.*)$|^(.*dialog.*)$" },
	float  = true,
	center = true,
	size   = "800 600",
})

hl.window_rule({
	name   = "float-dialogs-class",
	match  = { class = "^(org.gnome.FileRoller|[Xx]dg-desktop-portal-gtk|.*dialog.*)$" },
	float  = true,
	center = true,
	size   = "800 600",
})

-----------------------------------------------------
-- IDLE INHIBIT (Media Consumption)
-----------------------------------------------------

hl.window_rule({
	name         = "idle_inhibit",
	match        = { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$|^(.*[Ss]potify.*)$|^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" },
	idle_inhibit = "fullscreen",
})

hl.window_rule({
	name         = "idle_media_players",
	match        = { class = "^(vlc|mpv)$" },
	idle_inhibit = "focus",
})

hl.window_rule({
	name         = "idle_youtube",
	match = {
		class      = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$",
		title      = ".*YouTube.*",
	},
	idle_inhibit = "focus",
})

-----------------------------------------------------------------------------
-- PICTURE-IN-PICTURE (PiP) & PINNED WINDOWS
-----------------------------------------------------------------------------

hl.window_rule({
	name   = "pip-global",
	match  = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] },
	float  = true,
	pin    = true,
	size   = "248 140",
	center = true,
	opaque = true,
	no_dim = true,
	move   = "(monitor_w-window_w-20) (monitor_h-window_h-20)",
})

hl.window_rule({
	name         = "style-pinned-windows",
	match        = { pin = true },
	no_dim       = true,
	border_color = secondary_fixed,
	border_size  = 2,
	animation    = "slide down",
})

-----------------------------------------------------------------------------
-- FULLSCREEN & VISUAL STYLING
-----------------------------------------------------------------------------

-- Set border color to red if window is fullscreen
hl.window_rule({
	match        = { fullscreen = true },
	border_color = secondary,
})

-- Set border color to yellow when title contains Hyprland
hl.window_rule({
	match        = { title = ".*Hyprland.*" },
	border_color = tertiary,
})

-- Fix pinentry losing focus
hl.window_rule({
	match        = { class = "(pinentry-)(.*)" },
	stay_focused = true,
})

-----------------------------------------------------------------------------
-- APPLICATION-SPECIFIC FLOATS & VISUALS
-----------------------------------------------------------------------------

-- Floating Terminal
hl.window_rule({
	name         = "float_term",
	match        = { tag = "float_term" },
	float        = true,
	center       = true,
	size         = "1024 768",
	border_color = { colors = {primary, on_primary}, angle = 45 },
})

-- MPV: Always Float & Small
hl.window_rule({
	name   = "float-mpv",
	match  = { class = "^(mpv)$" },
	float  = true,
	opaque = true,
	size   = "640 360",
	center = true,
})

-- Disable blur for web browser
hl.window_rule({ match = { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" }, no_blur = true })

-----------------------------------------------------------------------------
-- COMMON DESKTOP / GNOME / QT UTILITIES (calculator, viewers, managers)
-----------------------------------------------------------------------------

-- Blueman Manager
hl.window_rule({
	name   = "float-blueman",
	match  = { class = "^(blueman-manager)$" },
	float  = true,
	center = true,
	size   = "652 431",
})

-- Pavucontrol (Volume Control)
hl.window_rule({
	name   = "float-pavucontrol",
	match  = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
	float  = true,
	center = true,
	size   = "700 600",
})

--- Network Connection Editor ---
hl.window_rule({
	name   = "float-nmeditor",
	match  = { class = "^(nm-connection-editor)$" },
	float  = true,
	center = true,
	size   = "700 600",
})

-- Calculator
hl.window_rule({
	name   = "float-calculator",
	match  = { class = "^(org.gnome.Calculator)$" },
	float  = true,
	center = true,
	opaque = true,
	size   = "360 616",
})

-- Loupe (Image Viewer)
hl.window_rule({
	name   = "float-loupe",
	match  = { class = "^(org.gnome.Loupe)$" },
	float  = true,
	center = true,
	opaque = true,
	size   = "1024 768",
})

-- Gparted
hl.window_rule({
	name   = "float-gparted",
	match  = { class = "^(GParted)$" },
	float  = true,
	center = true,
	size   = "652 431",
})

-- Gnome Disks
hl.window_rule({
	name   = "float-disks",
	match  = { title = "^(Disks)$", class = "^(org.gnome.DiskUtility)$" },
	float  = true,
	center = true,
	size   = "890 512",
})

-- Zathura PDF Viewer
hl.window_rule({
	name   = "float-zathura",
	match  = { class = "^(org.pwmt.zathura)$" },
	float  = true,
	center = true,
	size   = "900 900",
})

-- NWG Look (GTK Theming)
hl.window_rule({
	name   = "float-nwg-look",
	match  = { class = "^(nwg-look)$" },
	float  = true,
	center = true,
	size   = "627 464",
})

-- Qt Configuration Tool
hl.window_rule({
	name   = "float-qt",
	match  = { class = "^(qt5ct)$|^(qt6ct)$" },
	float  = true,
	center = true,
	size   = "700 600",
})

-- Virt-Manager vm window
hl.window_rule({
	name   = "float-vmviewer",
	match  = { class = "^(virt-manager)$", title = "^(.* on QEMU/KVM)$" },
	float  = true,
	center = true,
	size   = "700 600",
})

-- Peaclock TUI Time
hl.window_rule({
	name   = "float-peaclock",
	match  = { class = "^(peaclock)$" },
	float  = true,
	center = true,
	size   = "406 179",
})

-- Cava Music Visualiser
hl.window_rule({
	name   = "float-cava",
	match  = { class = "^(cava)$" },
	float  = true,
	center = true,
	size   = "791 488",
})

-- Btop
hl.window_rule({
	name   = "float-btop",
	match  = { class = "^(btop-monitor)$" },
	float  = true,
	center = true,
	size   = "1600 900",
})

-- System Mission Center
hl.window_rule({
	name   = "float-missioncenter",
	match  = { class = "(io.missioncenter.MissionCenter)" },
	float  = true,
	center = true,
	pin    = true,
	size   = "1280 720",
})

-- Haruna
hl.window_rule({
	name   = "float-haruna",
	match  = { class = "(org.kde.haruna)" },
	float  = true,
	center = true,
	size   = "1600 900",
})

-- Newelle
hl.window_rule({
	name   = "float-newelle",
	match  = { class = "(io.github.qwersyk.Newelle)" },
	float  = true,
	center = true,
	size   = "1440 900",
})

-----------------------------------------------------------------------------
-- Layer Rules like rofi, swaync, awww, wlogout (check using `hyprctl layers`)
-----------------------------------------------------------------------------

-- Enable blur for waybar
local myLayerRule = hl.layer_rule({
  name  = "my-layer-rule",
  match = { namespace = "waybar" },
  blur  = true,
})
myLayerRule:set_enabled(false)

-- Named layer rule
local selectionRule = hl.layer_rule({
  name      = "no-anim-for-selection",
  match     = { namespace = "selection" },
  no_anim   = true,
})

-- Enable blur and ignore_alpha for rofi
hl.layer_rule({
  match        = { namespace = "rofi" },
  blur         = true,
  ignore_alpha = 0.5,
})

-- Swaync rule
hl.layer_rule({
	match        = { namespace = "swaync-control-center" },
	animation    = "slide left",
	dim_around   = true,
	blur         = true,
	ignore_alpha = 0.2,
})

hl.layer_rule({
	match        = { namespace = "swaync-notification-window" },
	blur         = true,
	ignore_alpha = 0.2,
})

-- Wlogout rule
hl.layer_rule({
	name         = "logout_dialog_style",
	match        = { namespace = "logout_dialog" },
	blur         = true,
	ignore_alpha = 0.0,
})
