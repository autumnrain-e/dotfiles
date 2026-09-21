return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "ipynb" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons", "3rd/image.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		file_types = { "markdown", "ipynb" },
		image = { enabled = true },
		heading = { border = false, backgrounds = {} },
		overrides = {
			filetype = {
				ipynb = {
					anti_conceal = { enabled = false },
				},
			},
		},
	},
}
