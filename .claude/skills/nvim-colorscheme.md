# nvim-colorscheme

Use this skill when the user asks to change, swap, add, or remove a Neovim colorscheme in this dotfiles repo.

## Plugin file location

All colorscheme plugins live in:
`nvim/.config/nvim/lua/plugins/`

One file per colorscheme, named after the theme (e.g. `rose-pine.lua`, `kanagawa.lua`).

## Rules

- Only ONE colorscheme file should have `priority = 1000`, `lazy = false`, and call `vim.cmd("colorscheme <name>")` at a time. All others cause conflicts.
- When switching themes, delete the old file(s) — don't just disable them.
- Before creating a new file, glob `nvim/.config/nvim/lua/plugins/*.lua` and check for any existing colorscheme files that set `vim.cmd("colorscheme ...")`. Remove them.

## Template for a new colorscheme

```lua
return {
  "author/plugin-name.nvim",
  name = "theme-name",        -- only needed if repo name differs
  priority = 1000,
  lazy = false,
  opts = {
    -- theme-specific options here
  },
  config = function(_, opts)
    require("theme-name").setup(opts)
    vim.cmd("colorscheme theme-name")
  end,
}
```

## Current active theme: Everforest Dark Hard

File: `nvim/.config/nvim/lua/plugins/everforest.lua`
Plugin: `neanias/everforest-nvim`
Options: `background = "hard"`, `italics = false`, `transparent_background_level = 2`

## Checklist when switching themes

1. Glob plugins dir for any file calling `vim.cmd("colorscheme ...")` — delete all of them
2. Create new `<theme-name>.lua` with `priority = 1000`, `lazy = false`
3. Add directory highlight overrides if needed (see above)
4. Update `CLAUDE.md` "Theme & Appearance" section to reflect the new active theme
