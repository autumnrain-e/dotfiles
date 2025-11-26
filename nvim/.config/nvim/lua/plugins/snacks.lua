return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = { enabled = true }, -- LazyVim's default dashboard
		explorer = { enabled = true },
		picker = {
			enabled = true,
			sources = {
				explorer = {
					hidden = true, -- Show hidden files by default
				},
			},
		},
	},
	keys = {
		-- Top Pickers & Explorer
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>,",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
}
