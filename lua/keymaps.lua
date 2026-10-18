local map = vim.keymap.set

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Copilot
map("i", "<C-]>", "<Plug>(copilot-accept-word)", { desc = "Copilot: accept next word", remap = true })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Diagnostics
map("n", "<leader>E", vim.diagnostic.open_float, { desc = "Diagnostic: show float" })
map("n", "<leader>y", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics == 0 then
		return
	end
	local msg = table.concat(
		vim.tbl_map(function(d)
			return d.message
		end, diagnostics),
		"\n"
	)
	vim.fn.setreg("+", msg)
	vim.notify("Diagnostic copied")
end, { desc = "Diagnostic: yank message" })
