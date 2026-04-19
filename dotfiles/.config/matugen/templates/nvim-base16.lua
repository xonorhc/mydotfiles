---@type LazySpec
return {
	"y3owk1n/base16-pro-max.nvim",
	lazy = true,
	config = function()
		require("base16-pro-max").setup({
			colors = {
				base00 = "{{colors.background.default.hex}}",
				base01 = "{{colors.surface_container_lowest.default.hex}}",
				base02 = "{{colors.surface_container_highest.default.hex}}",
				base03 = "{{colors.outline_variant.default.hex}}",
				base04 = "{{colors.on_surface_variant.default.hex}}",
				base05 = "{{colors.on_surface.default.hex}}",
				base06 = "{{colors.inverse_on_surface.default.hex}}",
				base07 = "{{colors.surface_bright.default.hex}}",

				base08 = "{{colors.purple_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base09 = "{{colors.orange_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0A = "{{colors.cyan_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0B = "{{colors.yellow_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0C = "{{colors.cyan_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0D = "{{colors.green_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0E = "{{colors.pink_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
				base0F = "{{colors.red_source.default.hex|to_color|blend:{{colors.source_color.default.hex|to_color}},0.7}}",
			},
			styles = { italic = true, transparency = true },
			plugins = { enable_all = true },
		})
	end,
}
