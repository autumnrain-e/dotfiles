# Dotfiles Memory — Neovim Invariants

Domain split created 2026-09-21 when `.claude/tasks/lessons.md` was folded into memory: its
Neovim, image.nvim and font-verification entries landed here as one-liners. The verbose originals,
with code snippets, are in git: `git show 0e2cae9:.claude/tasks/lessons.md`.

**This file is NOT auto-loaded** — the `load-memory` SessionStart hook injects `MEMORY.md` only.
Read it before editing anything under `nvim/`; `.claude/rules/memory.md` carries that trigger.
Same rules as the active file's invariants: one line each, never archived, corrected in place
when they change and deleted when they stop being true.

Operational documentation — plugin list, LSP servers, options, where keymaps live — is CLAUDE.md's
Neovim section. This file is only the traps.

---

## LazyVim & plugin specs

- LazyVim `extras` imports fail in this install: `{ import = "lazyvim.plugins.extras.ui.mini-icons" }` dies with "s: expected string, got nil" and `...extras.editor.aerial` trips the import-order warning. Declare `nvim-mini/mini.icons` and `stevearc/aerial.nvim` directly with their own `keys`/`dependencies` — the same reason Python is not the `lang.python` extra.
- mini.icons' source is `nvim-mini/mini.icons`; `echasnovski/mini.icons` triggers a rename warning. It gives every directory ONE colour by design — per-extension variety applies to files only, so "all folders look the same" is not a bug.
- render-markdown's full-width coloured header lines come from `heading.backgrounds`, not `heading.border` (default `false`, so toggling it does nothing). The fix is `heading = { border = false, backgrounds = {} }`.
- `vim.pack` (0.12's native manager) is NOT a migration target — its author tells LazyVim users to start from a clean config, there is no 1:1 spec path. Experiment only under `NVIM_APPNAME=nvim-pack`.
- gruvbox-material overrides `SnacksDashboardHeader`; `snacks.lua` re-applies the `#FB4934` highlight on `ColorScheme`, or the dashboard header silently loses its colour.

## LSP & Mason

- `_transport.lua:68 ... not executable` on every file means the server BINARY is missing, not that the 0.12 API broke. The real message is in `~/.local/state/nvim/lsp.log` — the popup truncates it. Verify with `ls ~/.local/share/nvim/mason/bin/`.
- mason-lspconfig `ensure_installed` takes LSPCONFIG names (`lua_ls`, `ts_ls`, `cssls`, `emmet_ls`, `html`, `yamlls`, `taplo`, `basedpyright`, `ruff`); `:MasonInstall` takes PACKAGE names (`lua-language-server`, `typescript-language-server`, `css-lsp`, `emmet-ls`, `html-lsp`, `yaml-language-server`). Headless unblock without a restart: `nvim --headless "+MasonInstall <package names>" +qa`.
- ruff and basedpyright both attach to Python; `lsp.lua` switches off ruff's `hoverProvider` so `K` reaches basedpyright.

## image.nvim

- Remote SVG badges (shields.io etc.) raise `magick: unable to read font '' @ error/annotate.c/RenderFreetype`: Homebrew's imagemagick has no librsvg delegate and falls back to MSVG, which needs fonts macOS does not provide. Dead ends, all tried: installing `ghostscript`; `brew reinstall imagemagick` after `librsvg` (still not linked); `MAGICK_FONT_PATH` (a single path, not a colon list).
- `resolve_image_path` in the markdown integration runs for LOCAL paths only, never for URLs, so returning `nil` from it does nothing for badges. The working fix is `image.lua`'s post-`setup` monkey-patch of `require("image").from_url` (`ctx.api` is that same table) skipping badge URLs.

## Glyphs & fonts

- Nerd Font glyphs in Lua (lualine's `` U+E62B) must be written via Python — the Edit/Write tools drop them silently; verify bytes `ee 98 ab` with `hexdump -C`. The general PUA rule is in `MEMORY.md`.
- Font presence is checked with `ls ~/Library/Fonts /Library/Fonts`. `kitty +list-fonts` dies without a tty (`open /dev/tty: device not configured`) and `system_profiler -json SPFontsDataType` can return an empty set under a sandbox — both look exactly like "not installed".
