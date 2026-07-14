local M = {}

M.base_30 = {
	white = "#eeffff",
	darker_black = "#191919",
	black = "#212121", --  nvim bg
	black2 = "#292929",
	one_bg = "#303030",
	one_bg2 = "#383838",
	one_bg3 = "#404040",
	grey = "#4A4A4A",
	grey_fg = "#545454",
	grey_fg2 = "#5E5E5E",
	light_grey = "#6B6B6B",
	red = "#f07178",
	baby_pink = "#FFADFF",
	pink = "#DA70CA",
	line = "#383838", -- for lines like vertsplit
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
	statusline_bg = "#262626",
	lightbg = "#323232",
	pmenu_bg = "#6e98eb",
	folder_bg = "#6e98eb",
}

M.base_16 = {
	-- Background tones
	base00 = "{{colors.surface.default.hex}}", -- Default Background
	base01 = "{{colors.surface_container.default.hex}}", -- Lighter Background (status bars)
	base02 = "{{colors.surface_container_high.default.hex}}", -- Selection Background
	base03 = "{{colors.outline.default.hex}}", -- Comments, Invisibles
	-- Foreground tones
	base04 = "{{colors.on_surface_variant.default.hex}}", -- Dark Foreground (status bars)
	base05 = "{{colors.on_surface.default.hex}}", -- Default Foreground
	base06 = "{{colors.on_surface.default.hex}}", -- Light Foreground
	base07 = "{{colors.on_background.default.hex}}", -- Lightest Foreground
	-- Accent colors
	base08 = "{{colors.error.default.hex}}", -- Variables, XML Tags, Errors
	base09 = "{{colors.tertiary.default.hex}}", -- Integers, Constants
	base0A = "{{colors.secondary.default.hex}}", -- Classes, Search Background
	base0B = "{{colors.primary.default.hex}}", -- Strings, Diff Inserted
	base0C = "{{colors.tertiary_fixed_dim.default.hex}}", -- Regex, Escape Chars
	base0D = "{{colors.primary_fixed_dim.default.hex}}", -- Functions, Methods
	base0E = "{{colors.secondary_fixed_dim.default.hex}}", -- Keywords, Storage
	base0F = "{{colors.on_error_container.default.hex}}", -- Deprecated, Embedded Tags
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
