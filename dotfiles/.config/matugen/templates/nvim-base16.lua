---@type LazySpec
return {
	"y3owk1n/base16-pro-max.nvim",
	lazy = true,
	config = function()
		require("base16-pro-max").setup({
			colors = {
        <* for name, value in base16 *>
  			{{name | camel_case}} = "{{ value.default.hex | to_color | blend: {{ colors.source_color.default.hex | to_color }}, 0.7 }}",
        <* endfor *>
			},
			styles = { italic = true, transparency = true },
			plugins = { enable_all = true },
		})
	end,
}
