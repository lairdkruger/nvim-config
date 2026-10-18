-- Glue between the main nvim and the standalone tree nvim when they run in
-- separate Ghostty panes (NVIM_PANE=main|tree, set by ghostty-default-layout).
-- Each listens on a per-project socket; calls are fire-and-forget Lua.
local M = {}

local project = vim.fn.getcwd()
local name = vim.fn.fnamemodify(project, ":t")
local dir = vim.fn.stdpath("state") .. "/panes"
local id = vim.fn.sha256(project):sub(1, 12)

M.sock = { main = dir .. "/" .. id .. ".main", tree = dir .. "/" .. id .. ".tree" }
-- Ghostty pane titles, used to find panes for focusing
M.title = { main = "nvim · " .. name, tree = "tree · " .. name }

local function connect(path)
	local ok, chan = pcall(vim.fn.sockconnect, "pipe", path, { rpc = true })
	return ok and chan > 0 and chan or nil
end

function M.init(role)
	vim.o.title = true
	vim.o.titlestring = M.title[role]

	local path = M.sock[role]
	vim.fn.mkdir(dir, "p")
	if vim.uv.fs_stat(path) then
		local chan = connect(path)
		if chan then
			-- Another live instance already owns this project's socket
			vim.fn.chanclose(chan)
			return
		end
		os.remove(path) -- stale, from a crashed instance
	end
	vim.fn.serverstart(path)
end

local chans = {}

-- Run `code` (with `...` as args) in the peer; false if it isn't running
function M.call(peer, code, ...)
	for _ = 1, 2 do -- retry once in case the peer restarted
		chans[peer] = chans[peer] or connect(M.sock[peer])
		if not chans[peer] then
			return false
		end
		if pcall(vim.rpcnotify, chans[peer], "nvim_exec_lua", code, { ... }) then
			return true
		end
		chans[peer] = nil
	end
	return false
end

local focus_script = [[
on run argv
	tell application "Ghostty"
		repeat with t in terminals
			if name of t is item 1 of argv then
				focus t
				return
			end if
		end repeat
	end tell
end run]]

function M.focus(peer)
	vim.system({ "osascript", "-e", focus_script, M.title[peer] })
end

-- Main side --------------------------------------------------------------

local function bufs_under(path)
	local found = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local bufname = vim.api.nvim_buf_get_name(buf)
		if bufname == path or vim.startswith(bufname, path .. "/") then
			table.insert(found, { buf = buf, name = bufname })
		end
	end
	return found
end

function M.main()
	M.init("main")

	-- Reveal the current file in the tree pane
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("panes-main", { clear = true }),
		callback = function(ev)
			local file = vim.api.nvim_buf_get_name(ev.buf)
			if vim.bo[ev.buf].buftype == "" and file ~= "" then
				M.call("tree", "require('nvim-tree.api').tree.find_file({ buf = ... })", file)
			end
		end,
	})

	vim.keymap.set("n", "<leader>t", function()
		M.focus("tree")
	end, { desc = "Focus file tree pane" })
end

-- Called by the tree pane
function M.open(cmd, file)
	vim.cmd(cmd .. " " .. vim.fn.fnameescape(file))
end

function M.renamed(old, new)
	for _, b in ipairs(bufs_under(old)) do
		vim.api.nvim_buf_set_name(b.buf, new .. b.name:sub(#old + 1))
		if vim.bo[b.buf].buftype == "" then
			-- Clear "file exists" state left by renaming the buffer
			vim.api.nvim_buf_call(b.buf, function()
				vim.cmd("silent! write!")
				vim.cmd("edit")
			end)
		end
	end
end

function M.removed(path)
	for _, b in ipairs(bufs_under(path)) do
		if not vim.bo[b.buf].modified then
			vim.api.nvim_buf_delete(b.buf, {})
		end
	end
end

return M
