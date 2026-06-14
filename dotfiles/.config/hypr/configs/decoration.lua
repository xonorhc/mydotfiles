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
			active_border = { colors = { primary, "rgba(00000020)" }, angle = 90 },
			inactive_border = "rgba(00000000)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},

	decoration = {
		rounding = 12,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 0.9,

		shadow = {
			enabled = true,
			range = 30,
			render_power = 5,
			color = "rgba(00000070)",
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
