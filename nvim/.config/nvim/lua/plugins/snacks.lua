return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	init = function()
		-- Create custom highlight group for dashboard header with exact red color
		local set_custom_hl = function()
			vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#FB4934", bold = true })
		end

		-- Set it immediately
		set_custom_hl()

		-- Re-apply after colorscheme loads (gruvbox was overriding it)
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_custom_hl,
		})
	end,
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = [[

  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                     ]],
			},
			formats = {
				header = { "%s", align = "center", hl = "SnacksDashboardHeader" },
			},
		},
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
