--    __             __                  __  ____    ____
--   / /  ___  ___  / /__  ___ ____  ___/ / / __/__ / / /
--  / /__/ _ \/ _ \/  '_/ / _ `/ _ \/ _  / / _// -_) / /
-- /____/\___/\___/_/\_\  \_,_/_//_/\_,_/ /_/  \__/_/_/
--
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,

		col = {
			active_border = { colors = { source_color, source_color..20 }, angle = 90 },
			inactive_border = source_color..10,
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 15,
		rounding_power = 6,

		active_opacity = 1.0,
		inactive_opacity = 0.9,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(00000050)",
		},

		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})
