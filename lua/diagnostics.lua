local sev = vim.diagnostic.severity

vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	float = {
		focusable = false,
		border = "rounded",
		source = true,
		wrap = true,
		max_width = 80,
	},
	underline = { severity = sev.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[sev.ERROR] = "󰅚 ",
			[sev.WARN] = "󰀪 ",
			[sev.INFO] = "󰋽 ",
			[sev.HINT] = "󰌶 ",
		},
	} or {},
	-- Inline virtual text; use <leader>E to see the full message in a float
	virtual_lines = false,
	virtual_text = {
		source = "if_many",
		spacing = 2,
	},
})
