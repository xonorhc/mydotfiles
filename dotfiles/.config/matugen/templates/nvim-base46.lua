local M = {}

M.base_30 = {
	red = "#f07178",
	baby_pink = "#FFADFF",
	pink = "#DA70CA",
	green = "#c3e88d",
	vibrant_green = "#c3e88d",
	nord_blue = "#6e98eb",
	blue = "#82aaff",
	yellow = "#ffcb6b",
	sun = "#e6b455",
	purple = "#c792ea",
	dark_purple = "#b480d6",
	teal = "#abcf76",
	orange = "#f78c6c",
	cyan = "#89ddff",
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
  <* for name, value in base16 *>
  {{name | camel_case}} = "{{ value.default.hex | blend: {{ colors.source_color.default.hex | to_color }}, 0.5 | to_color | auto_lightness: 10 | set_lightness: 75 | set_saturation: 70, "hsl" }}",
  <* endfor *>
}

M.type = "dark"

M.polish_hl = {
	defaults = {
		Pmenu = { bg = "{{ colors.surface_container_high.default.hex }}", fg = "{{ colors.on_surface.default.hex }}" },
		PmenuSel = { bg = "{{ colors.primary.default.hex }}", fg = "{{ colors.on_primary.default.hex }}", bold = true },
		FloatBorder = { fg = "{{ colors.primary.default.hex }}", bg = "{{ colors.surface.default.hex }}" },
		PmenuSbar = { bg = "{{ colors.surface_container_low.default.hex }}" },
		PmenuThumb = { bg = "{{ colors.outline.default.hex }}" },
		Search = { bg = "{{ colors.secondary_container.default.hex }}", fg = "{{ colors.on_secondary_container.default.hex }}" },
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
