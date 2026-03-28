return {
	"AstroNvim/astroui",
	priority = 10000,
	---@type AstroUIOpts
	opts = {
		highlights = {
			default = {
				Comment = { fg = "{{colors.outline.dark.hex}}", bg = "NONE" },
				Delimiter = { fg = "{{colors.outline_variant.dark.hex}}", bg = "NONE" },
				Operator = { fg = "{{colors.on_surface_variant.dark.hex}}", bg = "NONE" },
				Todo = { fg = "{{colors.tertiary.dark.hex}}", bg = "NONE", bold = true },
				Identifier = { fg = "{{colors.secondary.dark.hex}}", bg = "NONE" },
				Constant = { fg = "{{colors.tertiary.dark.hex}}", bg = "NONE" },
				Type = { fg = "{{colors.primary.dark.hex}}", bg = "NONE" },
				String = { fg = "{{colors.on_surface.dark.hex}}", bg = "NONE" },
				Special = { fg = "{{colors.secondary_container.dark.hex}}", bg = "NONE" },
				PreProc = { fg = "{{colors.inverse_primary.dark.hex}}", bg = "NONE" },
				Function = { fg = "{{colors.primary.dark.hex}}", bg = "NONE" },
				Statement = { fg = "{{colors.on_secondary_container.dark.hex}}", bg = "NONE" },
				Error = { fg = "{{colors.on_error_container.dark.hex}}", bg = "{{colors.error_container.dark.hex}}" },
				StatusLine = { fg = "{{colors.primary.dark.hex}}", bg = "{{colors.on_primary.dark.hex}}" },
				StatusLineNC = {
					fg = "{{colors.primary_container.dark.hex}}",
					bg = "{{colors.on_primary_container.dark.hex}}",
				},
				Visual = { bg = "{{colors.surface_variant.dark.hex}}" },
			},
		},
	},
}
