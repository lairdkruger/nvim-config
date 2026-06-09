-- Run :TSUpdate after nvim-treesitter is installed or updated
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and (ev.data.kind == "install" or ev.data.kind == "update") then
			require("nvim-treesitter").install():wait(300000)
		end
		if ev.data.spec.name == "blink.cmp" and (ev.data.kind == "install" or ev.data.kind == "update") then
			require("blink.cmp").build():wait(60000)
		end
	end,
})

vim.pack.add({
	-- Colorscheme
	{
		src = "https://codeberg.org/evergarden/nvim",
		name = "evergarden",
	},

	-- Icons (dependency for nvim-tree, bufferline)
	"https://github.com/nvim-tree/nvim-web-devicons",

	-- File explorer
	"https://github.com/nvim-tree/nvim-tree.lua",

	-- Buffer tabs
	"https://github.com/akinsho/bufferline.nvim",

	-- Keymap hints
	"https://github.com/folke/which-key.nvim",

	-- LSP
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/neovim/nvim-lspconfig",

	-- Formatting
	"https://github.com/stevearc/conform.nvim",

	-- Text manipulation
	"https://github.com/kylechui/nvim-surround",

	-- Fuzzy finder
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",

	-- Syntax highlighting (parsers + queries)
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

	-- Completion
	"https://github.com/Saghen/blink.lib",
	"https://github.com/Saghen/blink.cmp",

	-- AI completion
	"https://github.com/github/copilot.vim",

	-- Git diff viewer
	"https://github.com/esmuellert/codediff.nvim",
})
