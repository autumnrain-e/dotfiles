return {
	"ajbucci/ipynb.nvim",
	-- BufReadCmd is registered in setup(), so this cannot be ft-lazy.
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"neovim/nvim-lspconfig",
		"folke/snacks.nvim",
	},
	opts = {
		-- Default "temp" hides the notebook from the project layout, so
		-- basedpyright misses local packages. Workspace keeps a .ipynb.nvim/
		-- dir next to the notebook.
		shadow = {
			location = "workspace",
			dir = ".ipynb.nvim",
		},
	},
	config = function(_, opts)
		require("ipynb").setup(opts)

		-- Upstream starts the kernel bridge with jobstart() and no cwd, so the
		-- kernel inherits Nvim's cwd instead of the notebook's directory.
		-- Jupyter Lab / VS Code start the kernel in the notebook's directory,
		-- which is what makes sibling modules like week1/scraper.py importable.
		local kernel = require("ipynb.kernel")
		local start_bridge = kernel.start_bridge
		kernel.start_bridge = function(state, python_path)
			local jobstart = vim.fn.jobstart
			vim.fn.jobstart = function(cmd, job_opts)
				job_opts = job_opts or {}
				job_opts.cwd = job_opts.cwd or vim.fn.fnamemodify(state.source_path, ":h")
				return jobstart(cmd, job_opts)
			end
			local ok, result = pcall(start_bridge, state, python_path)
			vim.fn.jobstart = jobstart
			if not ok then
				error(result, 0)
			end
			return result
		end
	end,
}
