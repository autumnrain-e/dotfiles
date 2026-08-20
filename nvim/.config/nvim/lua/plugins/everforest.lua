-- Inactive: kept available but not the active colorscheme.
-- Gruvbox Material is the active theme (see gruvbox-material.lua).
return {
	"neanias/everforest-nvim",
	lazy = true,
	opts = {
		background = "hard",
		italics = false,
		transparent_background_level = 2,
	},
	config = function(_, opts)
		require("everforest").setup(opts)
	end,
}
