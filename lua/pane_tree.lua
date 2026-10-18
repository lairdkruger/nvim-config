-- Standalone file-tree pane (NVIM_PANE=tree): only theme + nvim-tree, no LSP.
-- Files open in the main nvim pane; see panes.lua.
vim.pack.add({
	{ src = "https://codeberg.org/evergarden/nvim", name = "evergarden" },
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-tree/nvim-tree.lua",
})

require("theme")
local panes = require("panes")
panes.init("tree")

vim.o.laststatus = 0
vim.o.showtabline = 0
vim.o.cmdheight = 0
vim.o.signcolumn = "no"

local api = require("nvim-tree.api")

local function is_dir(node)
	return node.type == "directory" or (node.type == "link" and vim.fn.isdirectory(node.absolute_path) == 1)
end

local function open_in_main(cmd, focus)
	return function()
		local node = api.tree.get_node_under_cursor()
		if not node then
			return
		end
		if is_dir(node) then
			api.node.open.edit(node)
			return
		end
		if not panes.call("main", "require('panes').open(...)", cmd, node.absolute_path) then
			vim.notify("Main nvim pane isn't running", vim.log.levels.WARN)
			return
		end
		if focus then
			panes.focus("main")
		end
	end
end

-- External files (Finder clipboard / Ghostty drop) ------------------------

local function clipboard()
	return require("nvim-tree.core").get_explorer().clipboard
end

-- Copy paths into the dir under the cursor via nvim-tree's own paste, which
-- reads newline-separated paths from its register when its clipboard is
-- empty and handles conflicts. Uses internals: re-check on nvim-tree updates.
local function paste_paths(paths)
	local lines = {}
	for _, p in ipairs(paths) do
		local stat = vim.uv.fs_stat(p)
		if stat then
			table.insert(lines, stat.type == "directory" and p:gsub("/$", "") .. "/" or p)
		end
	end
	if #lines == 0 then
		vim.notify("Nothing to paste", vim.log.levels.WARN)
		return
	end

	local clip = clipboard()
	local reg = clip.reg
	clip.reg = "z" -- keep the system clipboard intact
	clip.data = { copy = {}, cut = {} }
	vim.fn.setreg("z", table.concat(lines, "\n"))
	local ok, err = pcall(api.fs.paste, api.tree.get_node_under_cursor())
	clip.reg = reg
	if not ok then
		vim.notify("Paste failed: " .. err, vim.log.levels.ERROR)
	end
end

local finder_script = [[
ObjC.import("AppKit");
var urls = $.NSPasteboard.generalPasteboard.readObjectsForClassesOptions(
	$([$.NSURL]), $({ NSPasteboardURLReadingFileURLsOnlyKey: true }));
var out = [];
if (urls) for (var i = 0; i < urls.count; i++) out.push(urls.objectAtIndex(i).path.js);
out.join("\n");
]]

local function finder_files()
	local res = vim.system({ "osascript", "-l", "JavaScript", "-e", finder_script }, { text = true }):wait()
	return vim.split(vim.trim(res.stdout or ""), "\n", { trimempty = true })
end

-- p: nvim-tree clipboard if it has anything, else files copied in Finder
local function smart_paste()
	local clip = clipboard()
	if #clip.data.copy == 0 and #clip.data.cut == 0 then
		local files = finder_files()
		if #files > 0 then
			paste_paths(files)
			return
		end
	end
	api.fs.paste()
end

-- Split Ghostty's dropped text (shell-escaped paths) into paths
local function parse_paths(text)
	local paths, cur, quote, i = {}, "", nil, 1
	local function push()
		if cur ~= "" then
			table.insert(paths, cur)
		end
		cur = ""
	end
	while i <= #text do
		local c = text:sub(i, i)
		if quote then
			if c == quote then
				quote = nil
			else
				cur = cur .. c
			end
		elseif c == "\\" then
			i = i + 1
			cur = cur .. text:sub(i, i)
		elseif c == "'" or c == '"' then
			quote = c
		elseif c:match("%s") then
			push()
		else
			cur = cur .. c
		end
		i = i + 1
	end
	push()
	return paths
end

-- Treat any paste (incl. drag-and-drop) as files to copy in
local pasted = {}
---@diagnostic disable-next-line: duplicate-set-field
vim.paste = function(lines, phase)
	vim.list_extend(pasted, lines)
	if phase == -1 or phase == 3 then
		local text = table.concat(pasted, "\n")
		pasted = {}
		vim.schedule(function()
			paste_paths(parse_paths(text))
		end)
	end
	return true
end

-- Tree ---------------------------------------------------------------------

require("tree").setup({
	update_focused_file = { enable = false }, -- main pane drives this
	diagnostics = { enable = false },
	modified = { enable = false },
	on_attach = function(bufnr)
		api.config.mappings.default_on_attach(bufnr)
		local function map(lhs, fn, desc)
			vim.keymap.set("n", lhs, fn, { buffer = bufnr, nowait = true, desc = "nvim-tree: " .. desc })
		end
		map("<CR>", open_in_main("edit", true), "Open in main pane")
		map("o", open_in_main("edit", true), "Open in main pane")
		map("<2-LeftMouse>", open_in_main("edit", true), "Open in main pane")
		map("<Tab>", open_in_main("edit", false), "Preview in main pane")
		map("<C-v>", open_in_main("vsplit", true), "Open vsplit in main pane")
		map("<C-x>", open_in_main("split", true), "Open split in main pane")
		map("<C-t>", open_in_main("tabedit", true), "Open tab in main pane")
		map("p", smart_paste, "Paste (nvim-tree or Finder clipboard)")
		map("q", "<cmd>qa<cr>", "Quit tree pane")
	end,
})

-- Keep main's buffers in sync with renames/moves/deletes done here
local Event = api.events.Event
api.events.subscribe(Event.NodeRenamed, function(data)
	panes.call("main", "require('panes').renamed(...)", data.old_name, data.new_name)
end)
api.events.subscribe(Event.FileRemoved, function(data)
	panes.call("main", "require('panes').removed(...)", data.fname)
end)
api.events.subscribe(Event.FolderRemoved, function(data)
	panes.call("main", "require('panes').removed(...)", data.folder_name)
end)

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("pane-tree", { clear = true }),
	callback = function()
		api.tree.open({ current_window = true })
	end,
})
