return {
	"jesseleite/nvim-startled",
	enabled = false, -- Disable to use default LazyVim dashboard (set to true to re-enable)
	lazy = false,
	config = function()
		require("startled").setup({
			highlights = {
				StartledPrimary = "#E4609B",
				StartledSecondary = "#47BAC0",
				StartledMuted = "#535353",
			},
			content = require("startled.content.default"),
		})
	end,
}
