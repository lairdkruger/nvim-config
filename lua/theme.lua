require("evergarden").setup({
	theme = { variant = "fall" },
	style = {
		search = {},
		incsearch = {},
		keyword = {},
		types = {},
	},
	overrides = function(theme)
		return {
			Visual = { bg = theme.surface2 },
			Search = { bg = theme.surface2 },
			IncSearch = { bg = theme.surface2 },
			-- Upstream now links to Panel (bg only), losing the dimmed fg
			NvimTreeNormal = { fg = theme.subtext1, bg = theme.mantle },
		}
	end,
})
vim.cmd([[colorscheme evergarden]])
