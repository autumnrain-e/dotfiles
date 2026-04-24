# Lessons Learned

## Neovim

### render-markdown.nvim — heading decorations
- **Problem**: Full-width colored lines appearing next to headers in markdown files.
- **Root cause**: Two independent features in render-markdown.nvim:
  - `heading.border` — adds box-drawing characters spanning the full width (default: `false`, so setting it had no effect)
  - `heading.backgrounds` — fills the entire heading line with a color; this was the actual culprit
- **Fix**: `heading = { border = false, backgrounds = {} }` in render-markdown opts.

### mini.icons — correct plugin name
- **Problem**: Used `echasnovski/mini.icons` which triggered a rename warning from LazyVim.
- **Fix**: Use `nvim-mini/mini.icons` as the plugin source.

### mini.icons — do not use LazyVim extras import
- **Problem**: `{ import = "lazyvim.plugins.extras.ui.mini-icons" }` fails with "s: expected string, got nil" because the extra path doesn't exist in the installed LazyVim version.
- **Fix**: Declare the plugin directly:
  ```lua
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
  }
  ```

### aerial.nvim — do not use LazyVim extras import
- **Problem**: `{ import = "lazyvim.plugins.extras.editor.aerial" }` triggers the LazyVim import order warning.
- **Fix**: Declare `stevearc/aerial.nvim` directly with its own `keys` and `dependencies`.

### mini.icons — icon colors vs. filename text colors
- **Behavior**: mini.icons makes icon colors follow the colorscheme. However, directories all share one "directory" color — you won't get per-folder distinct colors. Per-type color variety only applies to files by extension.
- **This is expected behavior**, not a bug.

---

## Yazi

### Folder icon color — blue despite Everforest flavor
- **Problem**: Folder icons appeared blue even with the everforest-medium flavor applied.
- **Root causes investigated (and ruled out)**:
  1. `LS_COLORS` / `LSCOLORS` — not set in Fish, so not the cause.
  2. `use_lscolors = false` in `yazi.toml` — **this option does not exist** in Yazi; it is silently ignored. Do not use it.
  3. `[filetype]` rules in `theme.toml` — these only color the **filename text**, not the icon glyph. Adding `{ url = "*/", fg = "#a7c080" }` alone does not fix the icon color.
- **Root cause**: Yazi's built-in default theme has `{ if = "dir", text = "", fg = "blue" }` in its `conds` rules. The everforest-medium flavor does not define an `[icon]` section, so this built-in blue wins.
- **Fix**: Add to `theme.toml`:
  ```toml
  [icon]
  prepend_conds = [
    { if = "dir", text = "", fg = "#a7c080" },
  ]
  ```
- **Critical**: The `text` field is **required** in `prepend_conds` — omitting it causes a Yazi error. The glyph is U+E5FF (Yazi's built-in default folder icon). Always write it via Python to avoid encoding corruption:
  ```python
  folder_icon = ''  # U+E5FF
  ```
  Do NOT paste the glyph directly into an Edit tool call — it may get silently dropped or corrupted.

### filetype rules vs. icon rules are independent
- `[filetype]` rules → control **filename text** color
- `[icon]` rules → control **icon glyph** color
- Both are needed to fully color directories. Setting one does not affect the other.
