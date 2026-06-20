-- Treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Redraw statusline on LSP progress updates
vim.api.nvim_create_autocmd("LspProgress", {
	group = vim.api.nvim_create_augroup("lsp-progress-redraw", { clear = true }),
	callback = function()
		vim.cmd.redrawstatus()
	end,
})

-- Auto-read files changed on disk
-- checktime fires frequently so external changes are detected near-instantly.
-- autoread (set in options.lua) silently reloads if buffer is clean.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = vim.api.nvim_create_augroup("auto-read", { clear = true }),
	command = "checktime",
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

-- Disable autocomplete in Telescope prompt
vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	group = vim.api.nvim_create_augroup("telescope-no-completion", { clear = true }),
	callback = function()
		vim.opt_local.autocomplete = false
	end,
})

-- Auto-reload unmodified buffers when file changes externally.
-- This suppresses the "modified elsewhere" warning for clean buffers
-- (e.g. edited by Godot, AI tools). Dirty buffers still warn on :w.
vim.api.nvim_create_autocmd("FileChangedShell", {
	group = vim.api.nvim_create_augroup("auto-reload-unmodified", { clear = true }),
	callback = function()
		if not vim.bo.modified then
			vim.cmd("e!")
		end
	end,
})

-- Soft-wrap text-like files without modifying file contents
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	group = vim.api.nvim_create_augroup("wrap-text-files", { clear = true }),
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
