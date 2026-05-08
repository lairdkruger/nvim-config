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
	formatters = {
		prettier = {
			command = "node_modules/.bin/prettier",
			args = function(self, ctx)
				local args = { "--stdin-filepath", "$FILENAME" }
				if ctx.filename:match("%.astro$") then
					table.insert(args, "--plugin")
					table.insert(args, "node_modules/@prettier/plugin-astro/src/index.js")
				end
				return args
			end,
		},
	},
	format_on_save = {
		timeout_ms = 5000,
		lsp_fallback = true,
	},
})
