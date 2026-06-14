--    ____               __
--   /  _/__  ___  __ __/ /_
--  _/ // _ \/ _ \/ // / __/
-- /___/_//_/ .__/\_,_/\__/
--         /_/

hl.config({
	input = {
		kb_layout = "us,br",
		kb_variant = ",abnt2",
		kb_model = "",
		kb_options = "grp:win_space_toggle",
		kb_rules = "",

		resolve_binds_by_sym = false,
		numlock_by_default = true,
		repeat_rate = 50,
		repeat_delay = 250,

		follow_mouse = 1,
		sensitivity = 1, -- -1.0 - 1.0, 0 means no modification.
		accel_profile = "adaptive",
		force_no_accel = false,
		left_handed = false,
		mouse_refocus = false,

		scroll_method = "2fg",

		touchpad = {
			natural_scroll = false,
			disable_while_typing = true,
			tap_to_click = true,
			clickfinger_behavior = true,
			drag_lock = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
