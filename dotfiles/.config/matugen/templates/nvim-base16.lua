return {
	"y3owk1n/base16-pro-max.nvim",
	priority = 1000,
	config = function()
		require("base16-pro-max").setup({
			colors = {
				<* for name, value in base16 *>
				{{ name | camel_case }} = "{{ value.default.hex | auto_lightness: 10 | lighten: 20 | saturate: 30, "hsl" | to_color | blend: {{ colors.primary.default.hex }}, 0.3 }}",
				<* endfor *>
			},
			styles = {
				italic = true, 
				bold = false, 
				transparency = true, 
			},
			plugins = {
				enable_all = true, 
			},
			highlight_groups = {
				Comment = { fg = "{{ base16.base03.default.hex | lighten:10 }}", bg = "NONE" },
				LineNr = { fg = "{{ base16.base03.default.hex | lighten:10 }}", bg = "NONE" },
			},
		})
	end,
}
