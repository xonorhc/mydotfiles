---@type LazySpec
return {
	"y3owk1n/base16-pro-max.nvim",
	lazy = true,
	config = function()
		require("base16-pro-max").setup({
			colors = {
				base00 = "{{colors.background.default.hex}}", -- Default background
				base01 = "{{colors.surface_container_lowest.default.hex}}", -- Lighter background (status bars)
				base02 = "{{colors.surface_container_highest.default.hex}}", -- Selection background
				base03 = "{{colors.outline_variant.default.hex}}", -- Comments, line highlighting
				base04 = "{{colors.on_surface_variant.default.hex}}", -- Dark foreground (status bars)
				base05 = "{{colors.on_surface.default.hex}}", -- Default foreground
				base06 = "{{colors.inverse_on_surface.default.hex}}", -- Light foreground
				base07 = "{{colors.surface_bright.default.hex}}", -- Lightest foreground

				base08 = "{{colors.error.default.hex}}", -- Red (variables, errors)
				base09 = "{{colors.tertiary.default.hex}}", -- Orange (integers, constants)
				base0A = "{{colors.secondary.default.hex}}", -- Yellow (classes, search)
				base0B = "{{colors.primary.default.hex}}", -- Green (strings, success)
				base0C = "{{colors.tertiary_fixed.default.hex}}", -- Cyan (support, regex)
				base0D = "{{colors.primary_fixed.default.hex}}", -- Blue (functions, info)
				base0E = "{{colors.secondary_fixed.default.hex}}", -- Purple (keywords, changes)
				base0F = "{{colors.error_container.default.hex}}", -- Brown (deprecated)
			},
			styles = { italic = true, transparency = true },
			plugins = { enable_all = true },
		})
	end,
}
