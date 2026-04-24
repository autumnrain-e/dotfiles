# Dotfiles Repository

Personal dotfiles for macOS (Apple Silicon) managed with **GNU Stow**.

## Structure

Each top-level directory is a stow package mirroring `$HOME`:

```
fish/    -> ~/.config/fish/          (Fish shell)
nvim/    -> ~/.config/nvim/          (Neovim, LazyVim-based)
wezterm/ -> ~/.wezterm.lua           (WezTerm terminal)
kitty/   -> ~/.config/kitty/         (Kitty terminal, default)
starship/-> ~/.config/starship.toml  (Starship prompt)
fastfetch/-> ~/.config/fastfetch/    (System info display)
zsh/     -> ~/.zprofile, ~/.zshrc    (Zsh shell, alternative)
```

## Deployment

```bash
# Install a package (symlink to $HOME)
stow <package>

# Remove a package
stow -D <package>

# Restow (useful after adding files)
stow -R <package>
```

Always run `stow` from the repo root (`~/dotfiles`).

## Config Languages

- **Neovim**: Lua (LazyVim framework, lazy.nvim plugin manager)
- **WezTerm**: Lua
- **Fish**: Fish shell syntax (not POSIX)
- **Zsh**: POSIX-compatible shell
- **Starship**: TOML
- **Fastfetch**: JSONC
- **Kitty**: INI-like custom format

## Theme & Appearance

**Everforest Dark Hard** is the current theme used across all tools. Any new config or theme change must maintain this consistency:
- Kitty: Everforest Dark Hard via `Everforest Dark Hard.conf` (included at end of kitty.conf)
- Neovim: `everforest-nvim` (`neanias/everforest-nvim`) with `background = "hard"` and `transparent_background_level = 2`
- Yazi: `everforest-medium` flavor with icon and filetype color overrides in `theme.toml`
- Starship: Inherits terminal colors

**Fonts**: Berkeley Mono (primary), Symbols Nerd Font Mono (fallback for full Nerd Font glyph range). Font size 17pt in Kitty.

## Neovim Details

- Plugin manager: lazy.nvim via LazyVim starter
- Plugin configs live in `nvim/.config/nvim/lua/plugins/` (one file per plugin or group)
- Editor options in `lua/config/options.lua` (4-space indent, no wrap, no relative numbers)
- Keymaps in `lua/config/keymaps.lua` (LSP bindings, buffer navigation)
- LSP servers: ts_ls, lua_ls, html, cssls, emmet_ls, yamlls (auto-installed via Mason)
- Treesitter parsers: bash, css, dockerfile, fish, html, javascript, json, lua, markdown, tsx, typescript, yaml, and more
- Dashboard: snacks.nvim with custom "NEOVIM" ASCII header (color #E85840)

Key plugin files:
- `everforest.lua` — colorscheme (`neanias/everforest-nvim`, Dark Hard, transparent)
- `render-markdown.lua` — markdown rendering; heading `border` and `backgrounds` are disabled to avoid full-width colored lines on headers
- `mini-icons.lua` — replaces `nvim-web-devicons` with `nvim-mini/mini.icons` so icon colors follow the active colorscheme instead of being hardcoded
- `aerial.lua` — document outline / ToC sidebar (`stevearc/aerial.nvim`), toggled with `<leader>cs`

## Shell Configuration

Fish is the primary shell. Zsh mirrors the same aliases for compatibility.

Key aliases (defined in both shells):
- `ls`, `la`, `lt` -> eza with icons
- `vim` -> nvim
- Git: `gb` (branch), `gf` (fetch), `gc` (commit), `gcln`/`gcle` (set local git user)
- Node: `npmi`, `npmidev`, `npmiglobal` (pnpm-based)

**Environment tools**: FNM (Node version manager), Zoxide (smart cd), Starship (prompt), Maven 3.9.0

**Secrets**: Fish sources `~/.config/fish/secrets.fish` if it exists. This file is gitignored and must never be committed.

## Fastfetch Details

- Config: `fastfetch/.config/fastfetch/config.jsonc`
- Logo: `fastfetch/.config/fastfetch/img/fma.gif` (animated GIF, rendered via Kitty's icat protocol)
- Animated GIF support requires a custom fork (not stock fastfetch): `https://github.com/Maybe4a6f7365/fastfetch-gif-support`
- The fork binary is installed at `~/.local/bin/fastfetch` (takes precedence over Homebrew's `/opt/homebrew/bin/fastfetch`)
- Fish config calls `~/.local/bin/fastfetch --logo-animate` on every interactive session (full path required because `~/.local/bin` is added to PATH later in config.fish)
- If the fork binary is ever lost, rebuild it: `git clone https://github.com/Maybe4a6f7365/fastfetch-gif-support && mkdir build && cd build && cmake .. && make -j$(sysctl -n hw.ncpu)` — then copy the binary to `~/.local/bin/fastfetch` (a macOS patch removing the unconditional `#include <sys/sendfile.h>` from `src/logo/image/image.c` is required before building)

## Yazi Details

- Flavor: `everforest-medium` (installed in `yazi/.config/yazi/flavors/everforest-medium.yazi/`)
- `theme.toml` sets the flavor and adds two critical overrides:
  - `[filetype]` rules: color directory names with Everforest green (`#a7c080`)
  - `[icon] prepend_conds`: color the directory icon glyph (U+E5FF, ``) with the same green — this must be written with the literal glyph character, not escaped, because Yazi requires the exact UTF-8 byte sequence
- The icon glyph U+E5FF is Yazi's built-in default folder icon. Always use Python to write it to avoid encoding issues: `python3 -c "open('theme.toml','w').write(...)"`
- `[filetype]` rules only affect filename text color; icon color requires a separate `[icon]` rule — these are independent

## AI Assistant Notes

- Lessons learned from past sessions are documented in `.claude/tasks/lessons.md`
- Always read that file before making changes to Yazi theme, Neovim plugins, or colorscheme configs

## Workflow Rules

- Keep Fish and Zsh aliases in sync when adding new ones
- Never commit secrets or credentials (secrets.fish is excluded via .gitignore)
- Kitty is the default terminal; WezTerm config is kept but Kitty is preferred
- WezTerm config lives at repo root as `.wezterm.lua` (not inside a .config subdir)
- Vim-style keybindings (hjkl) are used for pane navigation in both WezTerm and Kitty
- Neovim plugins should follow the LazyVim convention: one spec table per file in `lua/plugins/`
- When adding a new tool config, create a new stow package directory following the existing pattern

## Testing Changes

```bash
# Verify stow links are correct
stow -n -v <package>  # dry-run, shows what would be linked

# Test Neovim config
nvim --startuptime /tmp/startup.log  # check for errors/slow plugins

# Reload Fish config without restarting
source ~/.config/fish/config.fish

# Reload Kitty config
# ctrl+shift+F5 inside Kitty, or:
kill -SIGUSR1 $(pgrep kitty)

# Check WezTerm config
wezterm --config-file ~/.wezterm.lua
```

## Git Conventions

- Commit messages: short, descriptive (see recent history for style)
- User: Antonio Felizzola <antonio.qfel@gmail.com>
- All changes go directly to `main` branch
