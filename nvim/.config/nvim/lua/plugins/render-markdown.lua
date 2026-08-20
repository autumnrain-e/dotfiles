return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons", "3rd/image.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		image = { enabled = true },
		heading = { border = false, backgrounds = {} },
	},
}
