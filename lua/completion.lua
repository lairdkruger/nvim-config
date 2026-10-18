require("blink.cmp").setup({
	-- Use default preset: <C-space> trigger, <C-y> confirm, <Tab>/<S-Tab> navigate
	keymap = {
		preset = "default",
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	completion = {
		-- Show docs alongside the completion menu
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
		-- Highlight matching characters in the menu
		menu = { draw = { treesitter = { "lsp" } } },
		trigger = {
			-- Show completions when entering insert mode at a valid position
			show_on_insert = true,
			-- Unblock { and ( so object/function completions fire immediately
			show_on_x_blocked_trigger_characters = { "'", '"' },
		},
	},

	-- Let Copilot ghost text handle AI suggestions separately
	signature = { enabled = true },
})
