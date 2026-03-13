---@type Base46Table
local M = {}

M.base_30 = {
	white = "{{ colors.on_surface.default.hex }}",
	black = "{{ colors.surface.default.hex }}",

	-- Aumentamos o passo de 0.06 para 0.03/0.05 para variações perceptíveis em fundos escuros
	darker_black = "{{ colors.surface.default.hex | lighten: -0.03 }}",
	black2 = "{{ colors.surface.default.hex | lighten: 0.05 }}",
	one_bg = "{{ colors.surface.default.hex | lighten: 0.10 }}",

	-- MUITO IMPORTANTE: O Base46 usa 'one_bg2' ou 'blue' para o item selecionado no Pmenu
	-- Se o texto do item selecionado estiver escuro, certifique-se que o fundo da seleção seja claro
	one_bg2 = "{{ colors.surface.default.hex | lighten: 0.15 }}",

	one_bg3 = "{{ colors.surface.default.hex | lighten: 0.20 }}",

	-- Tons de Cinza
	grey = "{{ colors.outline.default.hex }}", -- Outline é mais visível que Surface Variant
	grey_fg = "{{ colors.on_surface_variant.default.hex }}",
	grey_fg2 = "{{ colors.on_surface_variant.default.hex | lighten: 0.1 }}",
	light_grey = "{{ colors.outline_variant.default.hex }}",

	-- Cores de Acento (Trocado de Container para Default para brilhar mais)
	red = "{{ colors.error.default.hex }}",
	baby_pink = "{{ colors.tertiary.default.hex | lighten: 0.2 }}",
	pink = "{{ colors.tertiary.default.hex }}",
	line = "{{ colors.surface.default.hex | lighten: 0.12 }}",

	green = "{{ colors.primary.default.hex }}",
	vibrant_green = "{{ colors.primary.default.hex | lighten: 0.15 }}",

	nord_blue = "{{ colors.secondary.default.hex | lighten: 0.1 }}",
	blue = "{{ colors.secondary.default.hex }}",
	seablue = "{{ colors.secondary.default.hex | lighten: -0.05 }}",

	yellow = "{{ colors.primary.default.hex | lighten: 0.3 }}", -- Forçando contraste no amarelo
	sun = "{{ colors.primary.default.hex | lighten: 0.35 }}",

	purple = "{{ colors.tertiary.default.hex }}", -- Purple geralmente mapeia bem para Tertiary
	dark_purple = "{{ colors.tertiary.default.hex | lighten: -0.1 }}",

	teal = "{{ colors.secondary.default.hex | lighten: 0.2 }}",
	orange = "{{ colors.error.default.hex | lighten: 0.2 }}",
	cyan = "{{ colors.primary.default.hex | lighten: 0.25 }}",

	-- UI Elements
	--
	-- Cor da barra de status e seleções de menu
	statusline_bg = "{{ colors.surface_container_low.default.hex }}",

	lightbg = "{{ colors.surface_container_highest.default.hex }}",

	-- Fundo do Menu de Autocomplete
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
	base06 = "{{ colors.on_surface.default.hex | lighten: 0.1 }}",
	base07 = "{{ colors.on_surface.default.hex | lighten: 0.2 }}",

	-- Sintaxe (Usando cores puras, evitando containers escuros)
	base08 = "{{ colors.error.default.hex }}", -- Variables
	base09 = "{{ colors.tertiary.default.hex }}", -- Integers (Tertiary costuma ser uma cor distinta)
	base0A = "{{ colors.primary.default.hex | lighten: 0.3 }}", -- Classes (Amarelado/Destaque)
	base0B = "{{ colors.primary.default.hex }}", -- Strings
	base0C = "{{ colors.secondary.default.hex }}", -- Support
	base0D = "{{ colors.secondary.default.hex | lighten: 0.1 }}", -- Functions
	base0E = "{{ colors.tertiary.default.hex }}", -- Keywords
	base0F = "{{ colors.error.default.hex | lighten: 0.2 }}", -- Deprecated/Special
}

M.type = "dark" -- "or light"

M.polish_hl = {
	defaults = {
		-- Pmenu: Janela flutuante (fundo e texto comum)
		Pmenu = {
			bg = "{{ colors.surface_container_high.default.hex }}",
			fg = "{{ colors.on_surface.default.hex }}",
		},
		-- PmenuSel: Item selecionado (Onde o contraste costuma quebrar)
		PmenuSel = {
			bg = "{{ colors.primary.default.hex }}", -- Fundo de destaque (cor vibrante)
			fg = "{{ colors.on_primary.default.hex }}", -- Texto em cima do destaque (sempre legível)
			bold = true,
		},
		-- Bordas das janelas flutuantes
		FloatBorder = {
			fg = "{{ colors.primary.default.hex }}",
			bg = "{{ colors.surface.default.hex }}",
		},
		-- Barra de rolagem do menu
		PmenuSbar = { bg = "{{ colors.surface_container_low.default.hex }}" },
		PmenuThumb = { bg = "{{ colors.outline.default.hex }}" },

		-- Destaque de busca (quando você aperta / ou *)
		Search = {
			bg = "{{ colors.secondary_container.default.hex }}",
			fg = "{{ colors.on_secondary_container.default.hex }}",
		},
	},
}

M = require("base46").override_theme(M, "matugen")

return M
