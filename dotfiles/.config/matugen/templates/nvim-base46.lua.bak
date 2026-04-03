local M = {}

M.base_30 = {
	white = "{{ colors.on_surface.default.hex }}",
	black = "{{ colors.surface.default.hex }}",
	darker_black = "{{ colors.surface.default.hex | lighten: -0.05 }}",
	black2 = "{{ colors.surface.default.hex | lighten: 0.05 }}",
	one_bg = "{{ colors.surface.default.hex | lighten: 0.10 }}",
	one_bg2 = "{{ colors.surface.default.hex | lighten: 0.15 }}",
	one_bg3 = "{{ colors.surface.default.hex | lighten: 0.20 }}",
	grey = "{{ colors.surface_variant.default.hex }}",
	grey_fg = "{{ colors.on_surface_variant.default.hex }}",
	grey_fg2 = "{{ colors.on_surface_variant.default.hex | lighten: 0.05 }}",
	light_grey = "{{ colors.outline.default.hex }}",
	red = "{{ colors.error.default.hex | lighten: 0.15 }}",
	baby_pink = "{{ colors.tertiary.default.hex | lighten: 0.20 }}",
	pink = "{{ colors.tertiary.default.hex | lighten: 0.10 }}",
	line = "{{ colors.surface.default.hex | lighten: 0.12 }}",
	green = "{{ colors.primary.default.hex | lighten: 0.10 }}",
	vibrant_green = "{{ colors.primary.default.hex | lighten: 0.20 }}",
	nord_blue = "{{ colors.secondary.default.hex | lighten: 0.15 }}",
	blue = "{{ colors.secondary.default.hex | lighten: 0.05 }}",
	seablue = "{{ colors.secondary.default.hex }}",
	yellow = "{{ colors.primary.default.hex | lighten: 0.30 }}",
	sun = "{{ colors.primary.default.hex | lighten: 0.40 }}",
	purple = "{{ colors.tertiary.default.hex | lighten: 0.15 }}",
	dark_purple = "{{ colors.tertiary.default.hex }}",
	teal = "{{ colors.secondary.default.hex | lighten: 0.25 }}",
	orange = "{{ colors.error.default.hex | lighten: 0.25 }}",
	cyan = "{{ colors.primary.default.hex | lighten: 0.35 }}",
	statusline_bg = "{{ colors.surface_container_low.default.hex }}",
	lightbg = "{{ colors.surface_container_highest.default.hex }}",
	pmenu_bg = "{{ colors.surface_container_high.default.hex }}",
	folder_bg = "{{ colors.primary.default.hex }}",
}

M.base_16 = {
	base00 = "{{ colors.surface.default.hex }}",
	base01 = "{{ colors.surface_container_low.default.hex }}",
	base02 = "{{ colors.surface_container.default.hex }}",
	base03 = "{{ colors.outline.default.hex }}",
	base04 = "{{ colors.on_surface_variant.default.hex }}",
	base05 = "{{ colors.on_surface.default.hex }}",
	base06 = "{{ colors.on_surface.default.hex | lighten: 0.15 }}",
	base07 = "{{ colors.on_surface.default.hex | lighten: 0.25 }}",
	base08 = "{{ colors.error.default.hex | lighten: 0.10 }}",
	base09 = "{{ colors.tertiary.default.hex | lighten: 0.15 }}",
	base0A = "{{ colors.primary.default.hex | lighten: 0.30 }}",
	base0B = "{{ colors.primary.default.hex | lighten: 0.10 }}",
	base0C = "{{ colors.secondary.default.hex | lighten: 0.10 }}",
	base0D = "{{ colors.secondary.default.hex | lighten: 0.20 }}",
	base0E = "{{ colors.tertiary.default.hex | lighten: 0.20 }}",
	base0F = "{{ colors.error.default.hex | lighten: 0.20 }}",
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
