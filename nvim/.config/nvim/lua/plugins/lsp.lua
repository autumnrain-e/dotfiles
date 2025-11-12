return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.enable({ "cssls", "emmet_ls", "html", "lua_ls", "ts_ls", "yamlls" })
	end,
}
