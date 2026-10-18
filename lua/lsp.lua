-- GDScript LSP (connects to running Godot editor on port 6005)
vim.lsp.config("gdscript", {
	cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
	filetypes = { "gdscript" },
	root_markers = { "project.godot", ".git" },
})
vim.lsp.enable("gdscript")

-- LSP server installation
require("mason").setup()

-- Also enables every Mason-installed server (automatic_enable), applying its
-- fixes for some servers (e.g. astro falls back to its bundled TypeScript when
-- the project's TS 7 lacks tsserverlibrary.js). Configs below still apply.
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"astro",
		"cssls",
		"css_variables",
		"eslint",
		"glsl_analyzer",
		"graphql",
		"html",
		"rust_analyzer",
		"svelte",
		"tailwindcss",
		"ts_ls",
	},
})

-- Extend css_variables to more filetypes
vim.lsp.config("css_variables", {
	filetypes = { "css", "scss", "less", "html", "svelte", "astro" },
})

-- Extend glsl_analyzer to gdshader files, remove unused filetypes
vim.lsp.config("glsl_analyzer", {
	filetypes = { "glsl", "gdshader" },
})

-- cssls: ignore Tailwind v4 at-rules (@theme, @apply, etc.)
vim.lsp.config("cssls", {
	settings = {
		css = { lint = { unknownAtRules = "ignore" } },
		scss = { lint = { unknownAtRules = "ignore" } },
		less = { lint = { unknownAtRules = "ignore" } },
	},
})

-- tailwindcss: trim to filetypes we actually use
vim.lsp.config("tailwindcss", {
	filetypes = {
		"html",
		"css",
		"scss",
		"less",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"astro",
		"svelte",
	},
})

-- LSP keymaps (0.12 defaults: gra, grr, gri, grn, grt, grx, gO, K, gd, gD)
-- We override go-to actions to use Telescope for a better picker UI.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local telescope = require("telescope.builtin")
		local buf = event.buf

		vim.keymap.set("n", "gd", telescope.lsp_definitions, { buffer = buf, desc = "LSP: Go to definition" })
		vim.keymap.set("n", "grr", telescope.lsp_references, { buffer = buf, desc = "LSP: Go to references" })
		vim.keymap.set("n", "gri", telescope.lsp_implementations, { buffer = buf, desc = "LSP: Go to implementations" })
		vim.keymap.set(
			"n",
			"grt",
			telescope.lsp_type_definitions,
			{ buffer = buf, desc = "LSP: Go to type definition" }
		)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "LSP: Go to declaration" })
		-- grn (rename), gra (code action), grx (codelens), gO (doc symbols), K (hover)
		-- are provided by Neovim 0.12 defaults — no need to re-declare

		-- blink.cmp handles LSP completion
	end,
})
