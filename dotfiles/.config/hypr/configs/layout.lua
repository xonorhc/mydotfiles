--    __                       __
--   / /  ___ ___ _____  __ __/ /____
--  / /__/ _ `/ // / _ \/ // / __(_-<
-- /____/\_,_/\_, /\___/\_,_/\__/___/
--           /___/

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		force_split = 0,
		preserve_split = false,
		smart_split = false,
		smart_resizing = true,
		permanent_direction_override = false,
		special_scale_factor = 1,
		split_width_multiplier = 1.0,
		use_active_for_splits = true,
		default_split_ratio = 1.0,
		split_bias = 0,
		precise_mouse_move = false,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_on_top = true,
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.95,
		follow_min_visible = 0.5,
		direction = "down",
		explicit_column_widths = "0.1, 0.333, 0.5, 0.667, 0.9, 0.95, 1.0",
	},
})
