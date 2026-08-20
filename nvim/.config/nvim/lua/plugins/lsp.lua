return {
	"neovim/nvim-lspconfig",
	config = function()
		-- Enable LSP servers
		vim.lsp.enable({ "cssls", "emmet_ls", "html", "lua_ls", "taplo", "ts_ls", "yamlls" })

		-- Set up LSP keybindings when LSP attaches to a buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				-- Keybindings
				local opts = { buffer = bufnr, noremap = true, silent = true }

				-- Go to definition
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				-- Go to declaration
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				-- Show hover documentation
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				-- Go to implementation
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				-- Show signature help
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				-- Go to type definition
				vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
				-- Rename symbol
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				-- Code action
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				-- Show references
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			end,
		})
	end,
}
