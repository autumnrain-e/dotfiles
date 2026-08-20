return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			-- lspconfig-style names; mason-lspconfig maps these to Mason packages
			-- and installs any that are missing on startup.
			ensure_installed = {
				"cssls",
				"emmet_ls",
				"html",
				"lua_ls",
				"taplo",
				"ts_ls",
				"yamlls",
			},
		},
	},
}
