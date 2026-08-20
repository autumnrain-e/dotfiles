# dotfiles

Personal macOS (Apple Silicon) dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Tools

| Tool | Purpose |
|------|---------|
| [Kitty](https://sw.kovidgoyal.net/kitty/) | Terminal emulator (default) |
| [Fish](https://fishshell.com/) | Shell (primary) |
| [Neovim](https://neovim.io/) | Editor (LazyVim-based) |
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager |
| [Starship](https://starship.rs/) | Shell prompt |
| [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info display |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | Tiling window manager |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | Status bar |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Window borders |
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal emulator (secondary, config kept) |
| [Zsh](https://www.zsh.org/) | Shell (secondary, mirrors Fish aliases) |

## Theme

**Gruvbox Material Dark Hard** on the active desktop. Everforest Dark Hard files are still in the repo but inactive.

- **Kitty**: `Gruvbox Material Dark Hard.conf`, included from `kitty.conf`. `Everforest Dark Hard.conf` is on disk, not included.
- **Neovim**: [`sainnhe/gruvbox-material`](https://github.com/sainnhe/gruvbox-material), hard background, no italics, transparent. The Everforest spec stays on disk, lazy/inactive.
- **Yazi**: `gruvbox-material` flavor. `everforest-medium` is installed but unused; the old directory-green overrides in `theme.toml` are commented out.
- **SketchyBar**: Gruvbox Material palette in `colors.sh`. Accent matches the window-border orange (`#e78a4e`).
- **JankyBorders**: active `#e78a4e` (gruvbox-material orange), inactive `#ddc7a1`.
- **WezTerm** (secondary): built-in `Gruvbox Dark (Gogh)` — Gruvbox, not the Material variant.
- **Starship**: inherits terminal colors.

**Fonts**: [Berkeley Mono](https://berkeleygraphics.com/typefaces/berkeley-mono/) (the installed cut is **Condensed**: `Condensed` / `Medium Condensed` / `Bold Condensed`) · [Symbols Nerd Font Mono](https://www.nerdfonts.com/) (icons; required, not a system font) · 18pt in Kitty and WezTerm.

SketchyBar is the one exception: its labels are Helvetica, not Berkeley Mono.

## Structure

Each top-level directory is a Stow package that mirrors `$HOME`:

```
aerospace/  →  ~/.config/aerospace/
borders/    →  ~/.config/borders/
fastfetch/  →  ~/.config/fastfetch/
fish/       →  ~/.config/fish/
kitty/      →  ~/.config/kitty/
nvim/       →  ~/.config/nvim/
sketchybar/ →  ~/.config/sketchybar/
starship/   →  ~/.config/starship.toml
wezterm/    →  ~/.wezterm.lua
yazi/       →  ~/.config/yazi/
zsh/        →  ~/.zprofile, ~/.zshrc
```

## Installation

```bash
# Clone
git clone https://gitlab.com/autumnrain-e/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow a package (creates symlinks in $HOME)
stow fish
stow nvim
stow kitty
# ... etc

# Remove a package
stow -D nvim

# Dry-run to preview links
stow -n -v nvim
```

## Neovim

LazyVim-based setup. Plugin specs live in `nvim/.config/nvim/lua/plugins/` — one file per plugin or group.

**Notable plugins:**

| Plugin | Purpose |
|--------|---------|
| `sainnhe/gruvbox-material` | Colorscheme |
| `nvim-mini/mini.icons` | Theme-aware icons (replaces nvim-web-devicons) |
| `stevearc/aerial.nvim` | Document outline / ToC (`<leader>cs`) |
| `MeanderingProgrammer/render-markdown.nvim` | Rendered markdown in buffer |
| `3rd/image.nvim` | Inline image preview (via Kitty) |
| `snacks.nvim` | Dashboard, UI utilities |

**LSP** (auto-installed via Mason): `ts_ls`, `lua_ls`, `html`, `cssls`, `emmet_ls`, `yamlls`

**Treesitter**: bash, css, dockerfile, fish, html, javascript, json, lua, markdown, tsx, typescript, yaml

## Fish Shell

Fish is the primary shell. Zsh mirrors the same aliases for compatibility.

**Key aliases:**

| Alias | Command |
|-------|---------|
| `ls`, `la`, `lt` | `eza` with icons |
| `vim` | `nvim` |
| `gb` | `git branch` |
| `gc` | `git commit` |
| `gf` | `git fetch` |
| `gcln` / `gcle` | Set local git user (personal / work) |
| `npmi` / `npmidev` / `npmiglobal` | `pnpm`-based installs |

**Environment tools**: [FNM](https://github.com/Schniz/fnm) · [Zoxide](https://github.com/ajeetdsouza/zoxide) · [Starship](https://starship.rs/) · Maven 3.9.0

Fish sources `~/.config/fish/secrets.fish` on startup if it exists — this file is gitignored and never committed.

## Fastfetch

Uses a [custom fork](https://github.com/Maybe4a6f7365/fastfetch-gif-support) with animated GIF support, installed at `~/.local/bin/fastfetch`. The logo is an animated GIF rendered via Kitty's `icat` protocol.

To rebuild the binary after a fresh setup:

```bash
git clone https://github.com/Maybe4a6f7365/fastfetch-gif-support
cd fastfetch-gif-support
# On macOS: remove the unconditional #include <sys/sendfile.h> from src/logo/image/image.c
mkdir build && cd build
cmake .. && make -j$(sysctl -n hw.ncpu)
cp fastfetch ~/.local/bin/fastfetch
```

## Yazi

File manager using the `gruvbox-material` flavor (same family as Neovim). The `everforest-medium` flavor remains on disk but is not selected. Directory-green `[filetype]` / `[icon]` overrides in `theme.toml` are commented out — gruvbox-material colors directories itself.
