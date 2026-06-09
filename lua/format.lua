require("nvim-surround").setup()

require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		astro = { "prettier" },
		json = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		html = { "prettier" },
		python = { "black" },
		lua = { "stylua" },
		gdscript = { "gdformat" },
	},

	format_on_save = {
		timeout_ms = 5000,
		lsp_fallback = true,
	},
})
