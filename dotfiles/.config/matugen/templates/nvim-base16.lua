---@type LazySpec
return {
	"y3owk1n/base16-pro-max.nvim",
	lazy = true,
	config = function()
		require("base16-pro-max").setup({
			colors = {
        <* for name, value in base16 *>
        {{name | camel_case}} = "{{ value.default.hex | harmonize: {{ colors.source_color.default.hex | to_color }} | to_color | lighten: 20 | auto_lightness: 10 | to_color | saturate: 35, "hsl" }}",
        <* endfor *>
      },
			styles = { italic = true, transparency = true },
			plugins = { enable_all = true },
		})
	end,
}
