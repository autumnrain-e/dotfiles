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
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal emulator (secondary, config kept) |
| [Zsh](https://www.zsh.org/) | Shell (secondary, mirrors Fish aliases) |

## Theme

**Everforest Dark Hard** across all tools.

- **Kitty**: `Everforest Dark Hard.conf`
- **Neovim**: [`neanias/everforest-nvim`](https://github.com/neanias/everforest-nvim), hard background, transparent
- **Yazi**: `everforest-medium` flavor with custom icon and filetype color overrides
- **Starship**: Inherits terminal colors

**Fonts**: [Berkeley Mono](https://berkeleygraphics.com/typefaces/berkeley-mono/) (primary) · Symbols Nerd Font Mono (icons) · 17pt in Kitty

## Structure

Each top-level directory is a Stow package that mirrors `$HOME`:

```
fastfetch/  →  ~/.config/fastfetch/
fish/       →  ~/.config/fish/
kitty/      →  ~/.config/kitty/
nvim/       →  ~/.config/nvim/
starship/   →  ~/.config/starship.toml
wezterm/    →  ~/.wezterm.lua
yazi/       →  ~/.config/yazi/
zsh/        →  ~/.zprofile, ~/.zshrc
```

## Installation

```bash
# Clone
git clone https://github.com/antoniofelizzola/dotfiles ~/dotfiles
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
| `neanias/everforest-nvim` | Colorscheme |
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

File manager with Everforest theming. The `theme.toml` applies the `everforest-medium` flavor and adds two overrides that the flavor itself is missing:

- `[filetype]` rules — directory **name** color
- `[icon] prepend_conds` — directory **icon** color (U+E5FF glyph, Everforest green `#a7c080`)

Both overrides are required — they are independent in Yazi's theming system.
