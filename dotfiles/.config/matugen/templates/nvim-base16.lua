return {
	"y3owk1n/base16-pro-max.nvim",
	priority = 1000,
	config = function()
		require("base16-pro-max").setup({
			colors = {
        <* for name, value in base16 *>
        {{name | camel_case}} = "{{ value.default.hex | blend: {{ colors.source_color.default.hex | to_color }}, 1.0 | to_color | lighten: 20 | saturate: 20, "hsl" }}",
        <* endfor *>
			},
			styles = { italic = true, transparency = true },
			plugins = { enable_all = true },
		})
	end,
}
