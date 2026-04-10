local M = {}

M.base_30 = {
	red = "{{ colors.red.default.hex }}",
	baby_pink = "{{ colors.baby_pink.default.hex }}",
	pink = "{{ colors.pink.default.hex }}",
	green = "{{ colors.green.default.hex }}",
	vibrant_green = "{{ colors.vibrant_green.default.hex }}",
	nord_blue = "{{ colors.nord_blue.default.hex }}",
	blue = "{{ colors.blue.default.hex }}",
	yellow = "{{ colors.yellow.default.hex }}",
	sun = "{{ colors.sun.default.hex }}",
	purple = "{{ colors.purple.default.hex }}",
	dark_purple = "{{ colors.dark_purple.default.hex }}",
	teal = "{{ colors.teal.default.hex }}",
	orange = "{{ colors.orange.default.hex }}",
	cyan = "{{ colors.cyan.default.hex }}",
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
	line = "{{ colors.surface.default.hex | lighten: 0.12 }}",
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
	base08 = "{{ colors.purple_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base09 = "{{ colors.orange_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0A = "{{ colors.cyan_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0B = "{{ colors.yellow_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0C = "{{ colors.cyan_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0D = "{{ colors.green_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0E = "{{ colors.pink_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
	base0F = "{{ colors.red_source.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 }}",
}

M.type = "dark"

M.polish_hl = {
	defaults = {
		Pmenu = { bg = "{{ colors.surface_container_high.default.hex }}", fg = "{{ colors.on_surface.default.hex }}" },
		PmenuSel = { bg = "{{ colors.primary.default.hex }}", fg = "{{ colors.on_primary.default.hex }}", bold = true },
		FloatBorder = { fg = "{{ colors.primary.default.hex }}", bg = "{{ colors.surface.default.hex }}" },
		PmenuSbar = { bg = "{{ colors.surface_container_low.default.hex }}" },
		PmenuThumb = { bg = "{{ colors.outline.default.hex }}" },
		Search = {
			bg = "{{ colors.secondary_container.default.hex }}",
			fg = "{{ colors.on_secondary_container.default.hex }}",
		},
	},

	treesitter = {
		["@variable"] = { fg = M.base_16.base07 },
		["@module"] = { fg = M.base_16.base07 },
		["@variable.member"] = { fg = M.base_16.base07 },
		["@type.builtin"] = { fg = M.base_30.purple },
		["@variable.parameter"] = { fg = M.base_30.orange },
		["@operator"] = { fg = M.base_30.cyan },
		["@punctuation.delimiter"] = { fg = M.base_30.cyan },
		["@punctuation.bracket"] = { fg = M.base_30.cyan },
		["@punctuation.special"] = { fg = M.base_30.teal },
		["@function.macro"] = { fg = M.base_30.pink },
		["@keyword.storage"] = { fg = M.base_30.purple },
	},

	syntax = {
		StorageClass = { fg = M.base_30.purple },
		Repeat = { fg = M.base_30.purple },
		Define = { fg = M.base_30.blue },
	},

	telescope = {
		TelescopeSelection = { bg = M.base_30.one_bg },
	},
}

return M
