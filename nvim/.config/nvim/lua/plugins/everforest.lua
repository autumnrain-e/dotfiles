return {
	"neanias/everforest-nvim",
	priority = 1000,
	lazy = false,
	opts = {
		background = "hard",
		italics = false,
		transparent_background_level = 2,
	},
	config = function(_, opts)
		require("everforest").setup(opts)
		vim.cmd("colorscheme everforest")
	end,
}
