# Dotfiles Repository

Personal dotfiles for macOS (Apple Silicon) managed with **GNU Stow**.

This file is the **structure and how-to-operate** layer. The *why* behind non-obvious choices,
rejected alternatives, and every known trap live in the memory files (see [Memory Protocol](#memory-protocol)).
Do not copy them here — one home per fact.

## Structure

Each top-level directory is a stow package mirroring `$HOME`:

```
aerospace/  -> ~/.config/aerospace/     (AeroSpace tiling WM; also launches borders + sketchybar)
borders/    -> ~/.config/borders/       (JankyBorders window borders)
cliamp/     -> ~/.config/cliamp/        (cliamp terminal music player — config.toml only)
emacs/      -> ~/.emacs.d/init.el       (Emacs, use-package + MELPA)
fastfetch/  -> ~/.config/fastfetch/     (System info display)
fish/       -> ~/.config/fish/          (Fish shell, primary)
ghostty/    -> ~/.config/ghostty/       (Ghostty terminal: config, local theme, shader)
kitty/      -> ~/.config/kitty/         (Kitty terminal, default)
nvim/       -> ~/.config/nvim/          (Neovim, LazyVim-based)
opencode/   -> ~/.config/opencode/      (only an empty themes/ dir so far — untracked)
raycast/    -> ~/.raycast-scripts/      (Raycast script commands: focus left/right half, maximize)
sketchybar/ -> ~/.config/sketchybar/    (SketchyBar status bar)
starship/   -> ~/.config/starship.toml  (Starship prompt)
wezterm/    -> ~/.wezterm.lua           (WezTerm terminal, secondary)
yazi/       -> ~/.config/yazi/          (Yazi file manager)
zsh/        -> ~/.zprofile, ~/.zshrc    (Zsh shell, alternative)
```

## Deployment

```bash
# Always from the repo root (~/dotfiles)
stow <package>        # symlink into $HOME
stow -D <package>     # remove
stow -R <package>     # restow after adding files
brew bundle install   # tooling from Brewfile
```

The `Brewfile` carries the CLI tools, `felixkratz/formulae/borders` + `sketchybar`, `media-control`,
the `font-symbols-only-nerd-font` cask and the `ghostty` cask. **Not** in it, on purpose or by
circumstance: kitty (upstream curl installer — the `ku` alias), Emacs (`emacs-app` cask), cliamp
(`~/.local/bin/cliamp`), and the fastfetch fork (`~/.local/bin/fastfetch`, see below).

## Config Languages

- **Neovim**: Lua (LazyVim framework, lazy.nvim)
- **WezTerm**: Lua
- **Fish**: Fish shell syntax (not POSIX)
- **Zsh**: POSIX-compatible shell
- **Starship**, **AeroSpace**, **Yazi**, **cliamp**: TOML
- **Fastfetch**: JSONC
- **Kitty**: INI-like custom format (`key value`)
- **Ghostty**: `key = value`, hyphenated keys (not kitty's format)
- **JankyBorders**: Bash (`bordersrc` is an executable script)
- **SketchyBar**: Bash (`sketchybarrc`, `items/*.sh`, `plugins/*.sh`, all executable)
- **Emacs**: Emacs Lisp
- **Raycast**: Bash with `# @raycast.*` header comments

## Theme & Appearance

**Gruvbox Material Dark Hard** everywhere. Any new config or theme change must keep that
consistency. The repo was previously on Everforest Dark Hard; Everforest files are kept on disk but
inactive.

- **Kitty**: `Gruvbox Material Dark Hard.conf`, included in the `BEGIN_KITTY_THEME` block at the end of `kitty.conf`. `Everforest Dark Hard.conf` still exists by name but its **contents are the Gruvbox Material palette** (kitty's theme picker overwrote it) — there is no real Everforest file for kitty. `background_opacity 0.9` and `background_blur 20` are currently on.
- **Ghostty**: local `themes/Gruvbox Material Dark Hard` in the package (the hard variant — Ghostty's bundled "Gruvbox Material Dark" is medium). Fully opaque. Everforest revert is the bundled `Everforest Dark Hard`, no file needed.
- **Neovim**: `sainnhe/gruvbox-material` in `gruvbox-material.lua` — `background = "hard"`, italics off, `transparent_background = 2`. `everforest.lua` (`neanias/everforest-nvim`) is on disk with `lazy = true`, inactive.
- **Yazi**: `gruvbox-material` flavor for both `dark` and `light` in `theme.toml`. `everforest-medium.yazi` is on disk but unused; the old directory-green `[filetype]`/`[icon]` overrides are commented out.
- **JankyBorders**: `active_color=0xFFE78A4E` (orange), `inactive_color=0xFFDDC7A1`.
- **SketchyBar**: palette in `colors.sh`. `ACCENT` is `$FG` (`#d4be98`), **not** the borders orange; `BAR_BG` is BG1 at 70% (`0xb3282828`).
- **Emacs**: `gruvbox-theme` from MELPA.
- **WezTerm**: built-in `Gruvbox Dark (Gogh)`.
- **Starship**: inherits terminal colors.

**Fonts**: Berkeley Mono at 18pt in Kitty, Ghostty and WezTerm. The installed cut is **Berkeley Mono
Condensed** (faces `Condensed` / `Medium Condensed` / `Bold Condensed`). Symbols Nerd Font Mono
supplies the glyph range for kitty's `symbol_map`, Ghostty's `font-codepoint-map` and SketchyBar's
icons — it is the Brewfile cask `font-symbols-only-nerd-font`, not a system font. Two exceptions:
SketchyBar text is **Noto Sans Mono**, and Emacs uses **PragmataPro Mono Liga** at 18pt.

## Neovim

Read `.claude/memory/MEMORY-nvim.md` before changing plugin specs or LSP setup.

- LazyVim starter; one spec table per file in `nvim/.config/nvim/lua/plugins/`.
- Options in `lua/config/options.lua`: 4-space indent (`expandtab`, `tabstop`/`shiftwidth` 4), `wrap` off, absolute line numbers only.
- Keymaps: general ones in `lua/config/keymaps.lua`; LSP bindings (`gd`, `gD`, `K`, `gi`, `<C-k>`, `gt`, `<leader>rn`, `<leader>ca`, `gr`) are set on `LspAttach` in `lua/plugins/lsp.lua`.
- LSP servers (`vim.lsp.enable` in `lsp.lua`, auto-installed by `mason-lspconfig` `ensure_installed` in `mason.lua`): `basedpyright`, `cssls`, `emmet_ls`, `html`, `lua_ls`, `ruff`, `taplo`, `ts_ls`, `yamlls`. Ruff's hover is disabled so basedpyright owns `K`.
- Treesitter (`nvim-treesitter.lua`): bash, css, dockerfile, fish, html, javascript, jsdoc, json, lua, markdown, markdown_inline, python, regex, sql, toml, tsx, typescript, vim, vimdoc, yaml; `auto_install = true`.
- Dashboard: snacks.nvim, header highlight `SnacksDashboardHeader` = `#FB4934`, re-applied on `ColorScheme`.

Plugin files worth knowing:
- `gruvbox-material.lua` — active colorscheme; `everforest.lua` — previous, lazy/inactive
- `blink.lua` — `saghen/blink.cmp` completion (release `1.*`)
- `mini-icons.lua` — `nvim-mini/mini.icons`, replaces `nvim-web-devicons`
- `aerial.lua` — outline sidebar, `<leader>cs`
- `render-markdown.lua` — heading `border`/`backgrounds` disabled
- `image.lua` — `3rd/image.nvim` with a badge-URL skip patch
- `obsidian.lua` — vault `~/Documents/Antonio`, snacks picker
- `ipynb.lua` — `ajbucci/ipynb.nvim`, notebook shadow dir kept in the workspace
- `lualine.lua` — mode text prefixed with a Nerd Font glyph
- Disabled (`enabled = false`): `neo-tree`, `noice`, `flash`, `nvim-startled`

## Shell

Fish is the primary shell (`fish/.config/fish/config.fish`). Zsh mirrors the aliases in
`zsh/.zprofile`. **Keep both in sync**, comments included — background syntax differs: fish needs
`&; disown`, zsh takes `& disown`.

Aliases:
- `ls`, `la`, `lt` → eza (long, icons, dirs first; `la` all, `lt` tree)
- Git: `gb` branch, `gf` fetch, `gc` clone, `gcln`/`gcle`/`gclocal` set the local identity, `setkw`/`setkp` pick the SSH key and toggle GPG signing
- Node: `npmi`/`npmidev`/`npmiglobal` (npm), `pnpmi`/`pnpmd` (pnpm)
- LnW work: `gp`, `gproxy*`, `cps`, `gs`, `gclean` (gulp), `slwrapper`, `cpw`, `bportal`/`rportal`/`docs`
- Misc: `gdots` (repo in nvim), `gconf`, `aliases`, `myip`, `obsidian`, `lg` (lazygit), `cl` (claude), `ku` (kitty installer), `obb` (Brave), `pip3`
- AeroSpace: `ascheck` (dry-run validate), `asreload` (re-read `aerospace.toml`), `asrestart` (kill AeroSpace + sketchybar + borders, relaunch — the only way to re-fire `after-startup-command`)
- SketchyBar: `sbreload` (`--reload`, picks up any config edit), `sbrestart` (only for a wedged process)
- `y` — yazi wrapper function

**Environment tools**: FNM (Node), Zoxide, Starship, Maven 3.9.0.

**Secrets**: Fish sources `~/.config/fish/secrets.fish` if it exists. Gitignored; never commit it.

## Fastfetch

- Config `fastfetch/.config/fastfetch/config.jsonc`; logo `img/fma.gif` (animated, via Kitty's icat protocol).
- Animation needs the fork `https://github.com/Maybe4a6f7365/fastfetch-gif-support`, installed at `~/.local/bin/fastfetch` (ahead of Homebrew's). Call it by full path with `--logo-animate`.
- The interactive-session call in `config.fish` is **currently commented out** (`# fastfetch` in the `status is-interactive` block).
- Rebuild if lost: `git clone https://github.com/Maybe4a6f7365/fastfetch-gif-support && mkdir build && cd build && cmake .. && make -j$(sysctl -n hw.ncpu)`, then copy the binary to `~/.local/bin/fastfetch`. A macOS patch removing the unconditional `#include <sys/sendfile.h>` from `src/logo/image/image.c` is required first.

## Yazi

- `yazi.toml`, `keymap.toml`, `theme.toml` hold **only overrides**, never a copy of Yazi's defaults (Yazi merges them; pasted defaults break on every major release).
- Flavors in `flavors/`: `gruvbox-material.yazi` (active), `everforest-medium.yazi` (inactive).
- Verify after any edit with `yazi --version` — it parses the config first and errors loudly.

## Kitty

- Installed with the `ku` alias (upstream installer), deliberately not via Homebrew.
- `kitty.conf`: Berkeley Mono 18, `symbol_map` → Symbols Nerd Font Mono, `hide_window_decorations titlebar-only`, `enabled_layouts splits` (required for `launch --location=hsplit|vsplit`), hjkl pane navigation, theme include block at the end.
- Reload: `ctrl+shift+F5` inside kitty, or `kill -SIGUSR1 $(pgrep kitty)`.

## Ghostty

Read `.claude/memory/MEMORY-ghostty.md` before editing this package.

- `config.ghostty` is a port of `kitty.conf` — keep the two in sync; every kitty setting without an equivalent is called out in a "no equivalent" comment.
- `themes/Gruvbox Material Dark Hard` — the local hard variant, resolved before the bundled themes.
- `shaders/cursor_sweep.glsl`, wired with `custom-shader` (the key accumulates; repeat it to stack shaders).
- Berkeley Mono 18, opaque, `quit-after-last-window-closed = true`.
- Reload a live instance with `cmd+shift+,`; validate with `ghostty +validate-config`; inspect non-default values with `ghostty +show-config`.

## AeroSpace

- Config `aerospace/.config/aerospace/aerospace.toml`; `start-at-login = true`.
- `after-startup-command` launches `borders` (no args, so it reads `bordersrc`) and `/opt/homebrew/bin/sketchybar` (absolute path — that exec environment has no Homebrew in `PATH`). It fires only when AeroSpace starts.
- `exec-on-workspace-change` fires `sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE`.
- `gaps.outer.top = [{ monitor."built-in" = 10 }, 40]` — bar height 32 + 8, per monitor. Change it together with the bar height. The macOS menu bar must be set to auto-hide.
- Reload: `ascheck` then `asreload` (applies gaps live). Restart: `asrestart` — kills all three processes first, because borders and sketchybar outlive AeroSpace and `open -a` on a running app only activates it.
- Diagnose "tiling broke" from runtime state, not config: `aerospace list-windows --workspace focused --format '%{app-name}|%{window-layout}|%{workspace-root-container-layout}'`; `alt-slash` (`layout tiles horizontal vertical`) resets an accordion root.

## JankyBorders

- `borders/.config/borders/bordersrc` is a **bash script, must be executable**, read only when `borders` runs with **no arguments**.
- Options: `style=round`, `width=5.0`, `hidpi=off`, colors `0xAARRGGBB` (alpha first).
- Launched by AeroSpace (above); not `brew services`. `borders width=8.0` retunes the live process — persist the value into `bordersrc` afterwards.
- Ad-hoc start: `nohup borders >/dev/null 2>&1 & disown` (a bare `borders &` dies with the shell).

## SketchyBar

Installed from the `felixkratz/formulae` tap via the Brewfile; only the config is vendored.
**Read `.claude/memory/MEMORY-sketchybar.md` before editing anything in this package.**

Current look: a flat **32px** strip, no item boxes, `BAR_BG` at 70%, text Noto Sans Mono 13pt bold,
Nerd glyphs on `FONT_ICON` (Symbols Nerd Font Mono) 16pt, everything coloured `$ACCENT`:

```
🍁 1 2 3 …  AppName                                media | cpu | ram | weather | clock
```

- Layout: `sketchybarrc` (entry point: PATH, fonts, bar, `--default`, source order) → `items/*.sh` (declarations) → `plugins/*.sh` (scripts). `colors.sh` = palette, `icons.sh` = Nerd Font codepoints. Everything must be executable.
- **Source order in `sketchybarrc` is the only place bar order lives.** Left items add left-to-right; right items add **right-to-left**, so the first right file sourced (`clock.sh`) is rightmost. `add_right_separator` adds the `|` pipes and is called after the item to the pipe's right. To move a section, move its `source` line and the separator after it.
- Active items: `logo` + `space.*` (`items/spaces.sh`; workspaces from `aerospace list-workspaces --all`, focused digit turns `$ACCENT`), `front_app.name` (`items/front_app.sh`), `clock` (30s), `weather` (Open-Meteo + IP geolocation, Apple Color Emoji, 30 min), `ram` (`vm_stat`, 15s), `cpu` (`iostat`, 5s), `media` (`media-control get`, 1s; hidden when stopped, together with `sep.cpu`).
- On disk but unhooked: `items/wifi.sh` + `plugins/wifi.sh`/`wifi_ssid.sh`, `items/status.sh` (volume; battery commented out), `plugins/cpu_graph.sh` (old graph cluster). Re-enable with a `source` line plus a separator.
- `icons.sh` holds raw Private Use Area codepoints — **regenerate it with Python `\uXXXX` / `\UXXXXXXXX` escapes**, never paste glyphs.
- SketchyBar passes `$CONFIG_DIR`, `$NAME`, `$SENDER`, `$INFO`; plugins re-`source` `colors.sh`/`icons.sh`. `sketchybarrc` prepends `/opt/homebrew/bin` to `PATH` for `aerospace`, `jq`, `media-control` and `sketchybar`.
- AeroSpace hooks: see the AeroSpace section. `sketchybarrc` seeds the workspace highlight once at the end because the event has not fired at startup.
- Fonts: `FONT_TEXT` / `FONT_TEXT_REGULAR` / `FONT_TEXT_BOLD` exported in `sketchybarrc`; Helvetica, Berkeley Mono (Condensed cut) and Fira Code kept commented. Check real style names with `fc-list | grep -i <family>` before swapping.
- Reload with `sbreload` after any edit (asynchronous — do not chain a `--set` on the next line); `sbrestart` only for a wedged process.

## Other Packages

- **Emacs** (`emacs/.emacs.d/init.el`): `use-package` with `always-ensure`, MELPA added for `gruvbox-theme`, undecorated frame, `custom.el` kept out of git. Generated state (`elpa/`, `eln-cache/`, …) is gitignored.
- **cliamp** (`cliamp/.config/cliamp/config.toml`): EQ preset `Rock`, visualizer `BarsDot`. `*.log`, `history.toml` and `resume.json` are gitignored runtime state.
- **Raycast** (`raycast/.raycast-scripts/`): `focus-left-half.sh`, `focus-right-half.sh`, `focus-maximize.sh` — bash + osascript, `@raycast.mode silent`. Add the folder as a Script Commands directory in Raycast.
- **WezTerm** (`wezterm/.wezterm.lua`): secondary; 18pt, hjkl pane navigation. Check with `wezterm --config-file ~/.wezterm.lua`.
- **opencode**: an empty `themes/` directory, untracked. Add a theme or drop the package.

## Memory Protocol

Project memory lives in `.claude/memory/`. `MEMORY.md` — invariants, an append-only decision log,
capped session history — is injected at session start by the `load-memory` SessionStart hook
(`.claude/hooks/load-memory.sh`), which also re-injects it after `/compact`.

- `.claude/rules/memory.md` is the always-on trigger (auto-loaded; **do not `@`-import it**).
- The `memory-log` skill holds the write procedure: logging format, session summaries, archiving.
- **Domain files are NOT injected by the hook.** Read the relevant one before editing that package, and put new invariants for that domain there, not in `MEMORY.md`:
  - `sketchybar/` → `.claude/memory/MEMORY-sketchybar.md`
  - `ghostty/` → `.claude/memory/MEMORY-ghostty.md`
  - `nvim/` → `.claude/memory/MEMORY-nvim.md` (absorbed the former `.claude/tasks/lessons.md` on 2026-09-21)
- Overflow goes to `.claude/memory/MEMORY_archive.md`, never read automatically.
- Native Auto Memory is disabled (`autoMemoryEnabled: false` in `.claude/settings.json`) so the committed files stay the single source of truth.
- Hook stdout is capped, so `MEMORY.md` must stay under **8,900 characters**. Verify with `bash .claude/hooks/load-memory.sh | wc -m` — over the cap, memory silently stops loading while the hook still reports success. Domain files are read on demand and are not bound by it.
- **Layering rule**: this file describes structure and how to operate. Reasons, rejected alternatives and traps go in memory. Never copy an invariant into this file.

## Workflow Rules

- Keep Fish and Zsh aliases (and their comments) in sync.
- Never commit secrets (`secrets.fish` is gitignored).
- Kitty is the default terminal; Ghostty and WezTerm configs are kept and maintained but secondary.
- hjkl pane navigation in Kitty, Ghostty and WezTerm.
- Neovim plugins follow the LazyVim convention: one spec table per file in `lua/plugins/`.
- A new tool gets a new stow package directory following the existing pattern, a line in Structure, and a short section here.
- GUI/WM-adjacent daemons (JankyBorders, SketchyBar) are launched from AeroSpace's `after-startup-command`, not from shell rc files or `brew services` — one lifecycle owner, absolute paths.
- Nerd Font glyphs go into config files via Python escapes, never pasted.

## Testing Changes

```bash
stow -n -v <package>                  # dry-run: what would be linked
nvim --startuptime /tmp/startup.log   # errors / slow plugins
source ~/.config/fish/config.fish
kill -SIGUSR1 $(pgrep kitty)          # kitty reload (or ctrl+shift+F5)
ghostty +validate-config              # ghostty; reload a live instance with cmd+shift+,
wezterm --config-file ~/.wezterm.lua
yazi --version                        # parses the config first; errors loudly if invalid
aerospace reload-config --dry-run     # = ascheck
aerospace list-windows --workspace focused --format '%{app-name}|%{window-layout}|%{workspace-root-container-layout}'
borders width=8.0                     # retune the running instance
killall borders; nohup borders >/dev/null 2>&1 & disown   # full restart, re-reads bordersrc
sketchybar --reload                   # = sbreload; asynchronous
sketchybar --reload && sleep 1 && sketchybar --query bar | jq '.height, .position'
sketchybar --query cpu                # resolved properties; bounding_rects is top-level, not under .geometry
CONFIG_DIR=~/.config/sketchybar NAME=ram ~/.config/sketchybar/plugins/ram.sh   # run a plugin by hand
# Offline plugin test: put a stub `sketchybar` that echoes its args first on PATH, then run as above.
# If item boxes ever return, verify gaps by pixel, not eye — procedure in git:
#   git show 0e2cae9:.claude/tasks/lessons.md   (section "A bracket cannot be spaced by padding")
```

## Git Conventions

- Commit messages: short, descriptive, `type(scope): summary` (see recent history).
- User: Antonio Felizzola <antonio.qfel@gmail.com>
- All changes go directly to `main`.
