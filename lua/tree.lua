-- nvim-tree config shared by the in-editor tree and the standalone tree pane
local M = {}

M.opts = {
	disable_netrw = true,
	sync_root_with_cwd = true,
	view = { signcolumn = "no" },
	renderer = {
		icons = {
			web_devicons = {
				file = { enable = true, color = false },
				folder = { enable = false, color = false },
			},
			git_placement = "after",
			show = { folder_arrow = false },
		},
	},
	update_focused_file = { enable = true },
	diagnostics = { enable = true, show_on_dirs = true },
	modified = { enable = true },
	filters = { git_ignored = false },
	actions = {
		change_dir = { enable = false, restrict_above_cwd = true },
	},
}

function M.setup(extra)
	require("nvim-tree").setup(vim.tbl_deep_extend("force", M.opts, extra or {}))
end

return M
