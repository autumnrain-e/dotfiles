return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local mode = opts.sections.lualine_a[1]
    opts.sections.lualine_a = {
      {
        "mode",
        fmt = function(str)
          return " " .. str
        end,
        padding = type(mode) == "table" and mode.padding or { left = 1, right = 1 },
      },
    }
    table.insert(opts.sections.lualine_x, 1, {
      function()
        local ok, kernel = pcall(require, "ipynb.kernel")
        return ok and kernel.statusline() or ""
      end,
      cond = function()
        local ok, kernel = pcall(require, "ipynb.kernel")
        return ok and kernel.statusline_visible() or false
      end,
      color = function()
        local ok, kernel = pcall(require, "ipynb.kernel")
        return ok and kernel.statusline_color() or nil
      end,
    })
    return opts
  end,
}
