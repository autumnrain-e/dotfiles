return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		workspaces = {
			{ name = "Antonio", path = "~/Documents/Antonio" },
		},
		picker = {
			name = "snacks.picker",
		},
		-- Disable built-in UI — render-markdown.nvim handles rendering
		ui = {
			enable = false,
		},
	},
}
