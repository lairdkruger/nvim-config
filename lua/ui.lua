-- Treesitter
require("nvim-treesitter").setup()

-- Treesitter textobjects
vim.cmd.packadd("nvim-treesitter-textobjects")
local ts_select = require("nvim-treesitter-textobjects.select")
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		include_surrounding_whitespace = false,
	},
})
vim.keymap.set({ "x", "o" }, "af", function()
	ts_select.select_textobject("@function.outer", "textobjects")
end, { desc = "TS: around function" })
vim.keymap.set({ "x", "o" }, "if", function()
	ts_select.select_textobject("@function.inner", "textobjects")
end, { desc = "TS: inner function" })
vim.keymap.set({ "x", "o" }, "ac", function()
	ts_select.select_textobject("@class.outer", "textobjects")
end, { desc = "TS: around class" })
vim.keymap.set({ "x", "o" }, "ic", function()
	ts_select.select_textobject("@class.inner", "textobjects")
end, { desc = "TS: inner class" })

-- Colorscheme
require("theme")

-- File explorer (in pane mode it runs in its own Ghostty pane; see panes.lua)
if vim.env.NVIM_PANE ~= "main" then
	require("tree").setup()

	vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("nvim-tree-on-startup", { clear = true }),
		callback = function(args)
			if args.file == "" then
				vim.cmd("NvimTreeToggle")
			end
		end,
	})

	-- Prevent nvim-tree from interfering with codediff tabs
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeDiffOpen",
		callback = function()
			vim.api.nvim_clear_autocmds({ group = "NvimTree" })
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeDiffClose",
		callback = function()
			require("nvim-tree.autocmd").global()
		end,
	})
end

-- LSP-powered inline color previews
vim.lsp.document_color.enable(true, nil, { style = "virtual" })

-- Buffer tabs
require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		offsets = {
			{
				filetype = "NvimTree",
				text = "",
				text_align = "left",
				separator = true,
			},
		},
		color_icons = false,
		show_buffer_icons = true,
		show_buffer_close_icons = false,
		show_close_icon = false,
		show_tab_indicators = true,
		always_show_bufferline = true,
	},
})

-- Keymap hints
require("which-key").setup({})
