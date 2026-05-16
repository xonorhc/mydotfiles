local M = {}

M.base_30 = {
	white = "{{ colors.on_background.default.hex }}",
	black = "{{ colors.background.default.hex }}",
	darker_black = "{{ colors.background.default.hex | lighten: -10.0 }}",
	black2 = "{{ colors.background.default.hex | lighten: 5.0 }}",
	one_bg = "{{ colors.background.default.hex | lighten: 10.0 }}",
	one_bg2 = "{{ colors.background.default.hex | lighten: 15.0 }}",
	one_bg3 = "{{ colors.background.default.hex | lighten: 20.0 }}",
	grey = "{{ colors.surface_variant.default.hex }}",
	grey_fg = "{{ colors.on_surface_variant.default.hex }}",
	grey_fg2 = "{{ colors.on_surface_variant.default.hex | lighten: 5.0 }}",
	light_grey = "{{ colors.surface_variant.default.hex | lighten: 20.0 }}",
	red = "{{ base16.base08.default.hex }}",
	baby_pink = "{{ base16.base08.default.hex | lighten: 20.0 }}",
	pink = "{{ base16.base08.default.hex | lighten: 10.0 }}",
	line = "{{ colors.surface.default.hex | lighten: 0.12 }}",
	green = "{{ base16.base0b.default.hex }}",
	vibrant_green = "{{ base16.base0b.default.hex | lighten: 20.0 }}",
	nord_blue = "{{ base16.base0d.default.hex | lighten: -15.0 }}",
	blue = "{{ base16.base0d.default.hex }}",
	seablue = "{{ base16.base0d.default.hex | lighten: 15.0 }}",
	yellow = "{{ base16.base0a.default.hex }}",
	sun = "{{  base16.base0a.default.hex | lighten: 10.0 }}",
	purple = "{{ base16.base0e.default.hex }}",
	dark_purple = "{{ base16.base0e.default.hex | lighten: -15.0 }}",
	teal = "{{ base16.base0f.default.hex }}",
	orange = "{{ base16.base09.default.hex }}",
	cyan = "{{ base16.base0c.default.hex }}",
	statusline_bg = "{{ colors.surface_container_low.default.hex }}",
	lightbg = "{{ colors.surface_container_highest.default.hex }}",
	pmenu_bg = "{{ colors.surface_container_high.default.hex }}",
	folder_bg = "{{ colors.primary.default.hex }}",
}

M.base_16 = {
  <* for name, value in base16 *>
    {{ name | camel_case }} = "{{ value.default.hex | to_color | auto_lightness: 10 | to_color | lighten: 10 | to_color | saturate: 20, "hsl" }}",
  <* endfor *>
}

M.type = "dark"

M.polish_hl = {
	defaults = {
		Pmenu = {
			bg = "{{ colors.surface_container_high.default.hex }}",
			fg = "{{ colors.on_surface.default.hex }}",
		},
		PmenuSel = {
			bg = "{{ colors.primary.default.hex }}",
			fg = "{{ colors.on_primary.default.hex }}",
			bold = true,
		},
		FloatBorder = {
			fg = "{{ colors.primary.default.hex }}",
			bg = "{{ colors.surface.default.hex }}",
		},
		PmenuSbar = { bg = "{{ colors.surface_container_low.default.hex }}" },
		PmenuThumb = { bg = "{{ colors.outline.default.hex }}" },

		Search = {
			bg = "{{ colors.secondary_container.default.hex }}",
			fg = "{{ colors.on_secondary_container.default.hex }}",
		},
	},
}

M = require("base46").override_theme(M, "matugen")

return M
