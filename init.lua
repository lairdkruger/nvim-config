require("options")

-- Standalone file-tree pane: skip everything else
if vim.env.NVIM_PANE == "tree" then
	require("pane_tree")
	return
end

require("plugins")
require("keymaps")
require("diagnostics")
require("autocmds")

-- Plugin configuration (loaded after vim.pack.add)
require("ui")
require("lsp")
require("completion")
require("format")
require("search")
require("git")

if vim.env.NVIM_PANE == "main" then
	require("panes").main()
end
