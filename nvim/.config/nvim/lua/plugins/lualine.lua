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
    return opts
  end,
}
