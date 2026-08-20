# Dotfiles Repository

Personal dotfiles for macOS (Apple Silicon) managed with **GNU Stow**.

## Structure

Each top-level directory is a stow package mirroring `$HOME`:

```
fish/    -> ~/.config/fish/          (Fish shell)
nvim/    -> ~/.config/nvim/          (Neovim, LazyVim-based)
wezterm/ -> ~/.wezterm.lua           (WezTerm terminal)
kitty/   -> ~/.config/kitty/         (Kitty terminal, default)
yazi/    -> ~/.config/yazi/          (Yazi file manager)
starship/-> ~/.config/starship.toml  (Starship prompt)
fastfetch/-> ~/.config/fastfetch/    (System info display)
aerospace/-> ~/.config/aerospace/    (AeroSpace tiling WM)
borders/ -> ~/.config/borders/       (JankyBorders window borders)
sketchybar/-> ~/.config/sketchybar/  (SketchyBar status bar)
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

Tooling comes from `Brewfile` (`brew bundle install`) — including both AeroSpace-launched daemons,
`borders` and `sketchybar`, from the `felixkratz/formulae` tap. **Kitty is deliberately not in it**:
it is installed from the upstream curl installer (the `ku` alias in `config.fish`), which is the
route Kitty's author supports, so a fresh machine needs that one step by hand even though
`kitty.conf` arrives with `stow kitty`. Note that `brew bundle check` reports outdated formulae the
same way it reports missing ones, so a long "needs to be installed or updated" list usually just
means `brew upgrade` is overdue.

## Config Languages

- **Neovim**: Lua (LazyVim framework, lazy.nvim plugin manager)
- **WezTerm**: Lua
- **Fish**: Fish shell syntax (not POSIX)
- **Zsh**: POSIX-compatible shell
- **Starship**: TOML
- **Fastfetch**: JSONC
- **Kitty**: INI-like custom format
- **AeroSpace**: TOML
- **JankyBorders**: Bash (`bordersrc` is an executable script, not a config format)

## Theme & Appearance

**Gruvbox Material Dark Hard** is the current theme across all tools. Any new config or theme change must maintain this consistency. The repo was previously on Everforest Dark Hard; Everforest files are kept on disk but inactive everywhere (see the per-tool notes).
- Kitty: Gruvbox Material Dark Hard via `Gruvbox Material Dark Hard.conf`, included in the `BEGIN_KITTY_THEME` block at the end of `kitty.conf`. `Everforest Dark Hard.conf` is still in the package but not included. `background_opacity`/`background_blur` are currently commented out (fully opaque background).
- Neovim: **Gruvbox Material** (`sainnhe/gruvbox-material`) with `gruvbox_material_background = "hard"`, italics off, and `gruvbox_material_transparent_background = 2`. The Everforest spec (`neanias/everforest-nvim`) is kept on disk but lazy/inactive.
- Yazi: **`gruvbox-material`** flavor (set in `theme.toml`), matching the Neovim colorscheme. The `everforest-medium` flavor is still installed on disk but inactive. The `[filetype]`/`[icon]` directory-green overrides are present in `theme.toml` but commented out (gruvbox-material handles directory colors itself).
- JankyBorders: active `0xFFE78A4E` (gruvbox-material orange — same value as Kitty's `color3`), inactive `0xFFDDC7A1` (gruvbox-material foreground tone, slightly brighter than Kitty's `#d4be98`)
- SketchyBar: full Gruvbox Material palette in `sketchybar/.config/sketchybar/colors.sh` (same `0xAARRGGBB` format as JankyBorders). Accent `0xffe78a4e` matches the borders active color; bar background `0xff1d2021` matches Kitty's `background`.
- Starship: Inherits terminal colors

**Fonts**: Berkeley Mono (primary, 18pt in Kitty via `font_size`). The installed cut is **Berkeley Mono Condensed** — its faces are `Condensed` / `Medium Condensed` / `Bold Condensed`, and there is **no plain `Bold`**. Symbols Nerd Font Mono supplies the Nerd Font glyph range — Kitty's `symbol_map` and SketchyBar's icons both depend on it, and it is **not** a system font: install it with `brew install --cask font-symbols-only-nerd-font` (in the Brewfile). Without it, glyphs render as tofu boxes and Kitty silently falls back with no error.

SketchyBar is the one **deliberate exception**: its text is Helvetica (`Regular`/`Bold`), not Berkeley Mono. See the SketchyBar section for why and how to switch it back.

## Neovim Details

- Plugin manager: lazy.nvim via LazyVim starter
- Plugin configs live in `nvim/.config/nvim/lua/plugins/` (one file per plugin or group)
- Editor options in `lua/config/options.lua` (4-space indent, no wrap, no relative numbers)
- Keymaps in `lua/config/keymaps.lua` (LSP bindings, buffer navigation)
- LSP servers: ts_ls, lua_ls, html, cssls, emmet_ls, yamlls (auto-installed via Mason)
- Treesitter parsers: bash, css, dockerfile, fish, html, javascript, json, lua, markdown, tsx, typescript, yaml, and more
- Dashboard: snacks.nvim with custom "NEOVIM" ASCII header (color #E85840)

Key plugin files:
- `gruvbox-material.lua` — active colorscheme (`sainnhe/gruvbox-material`, hard background, transparent, no italics)
- `everforest.lua` — previous colorscheme (`neanias/everforest-nvim`), kept available but `lazy = true` / inactive
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
- AeroSpace: `ascheck` (dry-run validate), `asreload` (re-read `aerospace.toml`), `asrestart` (kill AeroSpace + sketchybar + borders, then relaunch — the only way to re-fire `after-startup-command`)
- SketchyBar: `sbreload` (`--reload`, picks up any config edit), `sbrestart` (only for a wedged process)

The AeroSpace/SketchyBar blocks carry long comments explaining *why* `asrestart` kills all three
processes; keep the two shells' comments in sync too, not just the alias bodies. The background
syntax differs: fish needs `&; disown`, zsh takes `& disown`.

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

- **Active flavor: `gruvbox-material`** (set in `theme.toml` for both `dark` and `light`), to match the Neovim colorscheme. Both `gruvbox-material.yazi/` and `everforest-medium.yazi/` live in `yazi/.config/yazi/flavors/`; everforest-medium is kept on disk but inactive.
- `theme.toml` also contains commented-out `[filetype]`/`[icon]` directory-green (`#a7c080`) overrides. These were needed under everforest-medium (whose default folder icon was blue); gruvbox-material colors directories itself, so the overrides are currently disabled. If re-enabling them under a future flavor, see the lessons file — the `[icon] prepend_conds` glyph U+E5FF must be written via Python to avoid encoding corruption, and `[filetype]` (filename text) vs `[icon]` (glyph) colors are independent.
- **Config must contain only overrides, not a full copy of Yazi's defaults.** Yazi merges your config over its built-in defaults. `yazi.toml`/`keymap.toml` previously embedded the entire default file (including a `[plugin]` block and a `"$schema"` header); Yazi 26.5.6 (a breaking release) then refused to start. The `[plugin]` block and `$schema` headers were removed. When editing, do not re-add whole default sections — keep the config minimal so Yazi upgrades don't break it. Verify with `yazi --version` (it parses the config and errors loudly if invalid).

## JankyBorders Details

Colored borders around windows on macOS 14+ ([FelixKratz/JankyBorders](https://github.com/FelixKratz/JankyBorders)). Installed via Homebrew from the `felixkratz/formulae` tap and listed in the `Brewfile` as `felixkratz/formulae/borders` (currently 1.9.0 at `/opt/homebrew/bin/borders`) — it is **not** vendored in this repo, only its config is.

- Config: `borders/.config/borders/bordersrc`. It is a **bash script, not a declarative config**, and **must be executable** (`chmod +x`).
- `bordersrc` is read **only when `borders` is invoked with no arguments**. Passing any option on the command line bypasses the file entirely.
- Colors are `0xAARRGGBB` — **alpha first**, not `0xRRGGBBAA`. Current values: `active_color=0xFFE78A4E`, `inactive_color=0xFFDDC7A1`. Other options in use: `style=round`, `width=5.0`, `hidpi=off`.
- **Launch path: AeroSpace.** `aerospace/.config/aerospace/aerospace.toml` sets `after-startup-command = ['exec-and-forget borders']` (no args, so `bordersrc` supplies the appearance). With `start-at-login = true`, borders comes up with the WM at login. Borders inherits AeroSpace's accessibility permissions, which enables the more compatible `ax_focus` window-resolution path. It does **not** exit with AeroSpace: verified 2026-08-05 that after `killall AeroSpace` + relaunch, the original login-time `borders` process was still alive under its old PID while AeroSpace had a new one. Because the old daemon survives, run `killall sketchybar borders` *before* restarting AeroSpace — otherwise you keep a stale daemon and the new `after-startup-command` launch is a no-op.
- `after-startup-command` fires **only when AeroSpace starts**. `aerospace reload-config` does not re-run it, and `aerospace run-callback` only supports the window/focus callbacks. After editing that line, restart AeroSpace (`killall AeroSpace; sleep 1; open -a AeroSpace`, which re-tiles open windows) or log out and back in.
- Running `borders &` from a shell does **not** persist — the process is a child of the shell and takes SIGHUP when the terminal closes. For an ad-hoc start use `nohup borders >/dev/null 2>&1 & disown`.
- If an instance is already running, any new invocation with options **updates the live process** rather than starting a second one: `borders width=8.0` re-tunes instantly. Persist the value into `bordersrc` afterwards, or it is lost on restart.
- `brew services start borders` (launchd, `KeepAlive` + `RunAtLoad`, independent of the WM) is a supported alternative but is **deliberately not used** — see the `[2026-08-04]` entry in `.claude/memory/MEMORY.md`.
- Full option reference: `man borders`.

## SketchyBar Details

Custom macOS status bar ([FelixKratz/SketchyBar](https://github.com/FelixKratz/SketchyBar)). Installed from the same tap as JankyBorders (`brew install felixkratz/formulae/sketchybar`) — not vendored here, only its config.

- Package: `sketchybar/.config/sketchybar/`. `sketchybarrc` is the entry point and **must be executable** (`chmod +x`); so must every script in `plugins/`.
- Layout: `sketchybarrc` (bar + defaults) → `items/*.sh` (declarations, sourced in draw order) → `plugins/*.sh` (the script each item runs). `colors.sh` holds the palette, `icons.sh` the Nerd Font glyphs.
- **Colors are `0xAARRGGBB` — alpha first**, same as JankyBorders.
- **Item order**: `left` items are added left-to-right, `right` items **right-to-left**. The first `right` item added ends up rightmost, so each later `source` line in `sketchybarrc` lands its items further left — `clock.sh` → `status.sh` → `wifi.sh` → `ram.sh` → `cpu.sh` → `media.sh` produces the reading order `media | cpu | ram | wifi | volume | clock`. The source block in `sketchybarrc` is the **only** place that order is expressed; move a chip by moving its line.
- **Items are drawn in add order too**, which matters as soon as two overlap: an opaque `background` on a later item paints over an earlier one. A stacked chip therefore needs a **bracket** (drawn beneath all its members) rather than one member owning the box — see the clock cluster below.
- **Spacing a bracket needs an empty item, not padding.** A bracket ignores its own `padding_left/right` (they report back as `null`), swallows its members' padding into its box, and is unaffected by `background.padding_*` — all three measured. So each cluster file declares a `<cluster>.gap.left` / `<cluster>.gap.right` item (`width=3`, every `drawing=off`), added last and first respectively, and deliberately **not** listed as a bracket member. Two adjacent clusters then meet at 3+3=6px, matching what plain chips get from their own padding. Plain items are the opposite case — their background excludes their padding, so there item padding is correct. Details and the pixel-scan procedure: `.claude/tasks/lessons.md`.
- SketchyBar exports `$CONFIG_DIR`, `$NAME`, `$SENDER`, and `$INFO` to every script it runs. Plugins re-`source` `colors.sh`/`icons.sh` because they run as fresh processes, not in the config's shell.
- **PATH**: launched from AeroSpace, so the process does *not* inherit a login shell PATH. `sketchybarrc` prepends `/opt/homebrew/bin` — plugins depend on this for `aerospace`, `jq`, and `sketchybar` itself.
- **AeroSpace integration** (two hooks in `aerospace.toml`):
  - `after-startup-command` runs `/opt/homebrew/bin/sketchybar` (absolute path) alongside `borders`.
  - `exec-on-workspace-change` fires `sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE`. The `space.*` items subscribe to that custom event; `plugins/aerospace.sh` compares its `$1` against `$FOCUSED_WORKSPACE`. Workspaces are enumerated from `aerospace list-workspaces --all`, so they follow `persistent-workspaces` with no hardcoded list.
  - Because the event has not fired at startup, `sketchybarrc` seeds the highlight with an explicit `--trigger` using `aerospace list-workspaces --focused`.
- **Bar height vs. gaps**: bar is 39px at `position=top`, so tiled windows need a 47px (39 + 8) top clearance. This assumes the macOS menu bar is set to auto-hide (System Settings → Control Center → Automatically hide and show the menu bar → Always); with the menu bar visible the two overlap. A commented floating-bar variant in `sketchybarrc` needs ≈ 55. **`gaps.outer.top` is per-monitor** — `[{ monitor."built-in" = 17 }, 47]` — because AeroSpace measures from each monitor's *visible frame*, and the built-in Retina display's ~30pt menu-bar/notch reserve is already excluded from it, so the gap stacks on top of it (47 there put the window edge at 77pt). `aerospace reload-config` / `asreload` applies a gaps change live; no restart needed.
- **Fonts**: `sketchybarrc` exports `FONT_TEXT` plus `FONT_TEXT_REGULAR` / `FONT_TEXT_BOLD`. The style names are variables because **CoreText matches them exactly** — a style matching no installed face falls back to **Helvetica silently**, with no error and no hint from `--query` (which echoes the requested string, not the resolved font). Keep the family and its real style names together; check them with `fc-list | grep -i <family>` before swapping. Currently Helvetica `Regular`/`Bold`; Berkeley Mono (`Condensed` / `Bold Condensed`) and Fira Code (`Regular` only — it has no Bold on disk) are commented out ready to restore.
- Every label is bold: the `--default` block sets `label.font` to `$FONT_TEXT_BOLD`, which all status items and media inherit. `$FONT_TEXT_REGULAR` is currently unused, kept as the escape hatch for exempting an item.
- Icons live in `icons.sh` and are raw Private Use Area codepoints. **Regenerate that file with Python using `\uXXXX` escapes** — pasted glyphs get silently dropped (see `.claude/tasks/lessons.md`).
- **Doom logo** (`items/spaces.sh` + `plugins/doom.sh`): left-edge chip, pinned `width=35`, 32px HUD sprites at `scale=0.75` with `image.padding_left=6`. Frames are `assets/doom/<N>_<label>/doom_guy_*.png` — the plugin globs them, no hardcoded list. 5s per frame; last frame of a folder holds 180s, then the next folder; wrap after 4. `items/spaces.sh` wipes `$TMPDIR/sketchybar_doom.state` so `--reload` restarts at folder 0 frame 0. White-matte knock-out is `scripts/prepare-doom-faces.py` (flood-fill + 1px erode). Ghost revert is the commented block above the `--add`; keep `logo_separator`. Static revert: drop `script`/`update_freq` and point at `assets/doom.png`.
- **App chip** (`items/front_app.sh` + `plugins/front_app.sh`): the focused app as two boxes — a per-app Nerd Font glyph in a `$ACCENT` box (glyph itself `$BG0`, dark-on-orange), then a 2px gap, then the app name on `$GROUP_BG`. **Two plain items, deliberately not a bracket**: a bracket draws one box beneath all its members, which is the opposite of a two-tone chip. Since they are plain items, item padding is the correct spacing tool — the whole `APP_SEAM_GAP=2` sits on the icon half's `padding_right` with the name half's `padding_left` at 0, so the constant equals the visible gap instead of half of it (the doubling `SPACE_GAP`/`RAM_GAP` have to warn about). Left items are added left-to-right, so the icon half must be added **first**; the 8px gap from the workspaces still comes from `space_separator`.
  - `APP_ICON_WIDTH=28` matches `SPACE_WIDTH`, and pinning it is **required, not cosmetic** — sketchybar sizes an icon slot from measured glyph extents, so an unpinned box visibly resizes on every app switch as one glyph gives way to another.
  - The map keys off the name macOS reports in `$INFO`, which is the bundle's **`localizedName` and not the `.app` filename**. Two differ here: Docker's window belongs to the *inner* `Docker Desktop.app` so it reports `Docker Desktop`, and Chrome reports `Google Chrome` though its `CFBundleName` is just `Chrome`. Both short forms are aliased in the `case`. Read a new app's real name with `sketchybar --query front_app.name | jq -r .label.value`, then add an `ICON_APP_*` glyph to `icons.sh` and a branch to the plugin.
  - Mapped: kitty (nf-md-cat), Helium (nf-md-snowflake), GitKraken (nf-fa-gitkraken), Docker Desktop (nf-fa-docker), Obsidian (nf-custom-obsidian), Microsoft Teams (nf-md-microsoft_teams), Google Chrome (nf-fa-chrome), Passwords (nf-md-key_chain), Emacs (nf-custom-emacs), Finder (nf-md-apple_finder), Claude (nf-cod-claude). Anything unmapped falls back to `ICON_APP_DEFAULT` (nf-md-application_outline) rather than keeping the previous app's glyph, which would name one app and picture another.
  - The name half is `$FG`, not the `$ACCENT` it was as a single chip — the accent now carries the glyph box, and orange text beside an orange box loses the two-tone contrast. One-word revert in `items/front_app.sh`.
- **CPU graph cluster** (`items/cpu.sh` + `plugins/cpu_graph.sh`), ported from [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles/blob/master/.config/sketchybar/items/cpu.sh). Four items — `cpu.user`/`cpu.sys` (overlapping `graph` items), `cpu.percent`, `cpu.top` (busiest process) — wrapped in a `cpu.group` bracket so they read as one chip. Upstream drives this from a compiled mach helper; this port uses a shell sampler instead, so there is no build step.
  - **`--add graph <name> <side> <width>`** takes its width as a positional arg, and is fed with **`--push <name> <0.0–1.0>`** (a fraction, not a percentage). A graph plots inside its *background* rect, so `background.drawing=on` is required and `background.height` is the plot height — here left unset so it inherits the 26px default and fills the chip.
  - **`width=0` is the stacking primitive.** A zero-width item consumes no horizontal space *and never advances the layout cursor*, so the next item is placed at the same x and the two overlap — that is how `cpu.sys` sits under `cpu.user`, and `cpu.top` above `cpu.percent`. A zero-width item's label is **right-anchored and extends leftward**, so it must be added *before* (i.e. to the right of) the item it should overlay.
  - Because a zero-width item doesn't advance the cursor, its `padding_right` moves only itself. An item with a real box (`cpu.percent`) instead needs `label.padding_right` for an inset — item padding there would drag the bracket's right edge in with it and cancel the margin out.
  - The old single `cpu` chip is **commented out in `items/status.sh`** and `plugins/cpu.sh` is untouched on disk. Revert = uncomment that block and drop the `source items/cpu.sh` line from `sketchybarrc`.
- **Graph vertical scale**: `CPU_GRAPH_FULL_SCALE` at the top of `plugins/cpu_graph.sh` sets the load that fills the 26px plot — `60`, not upstream's literal `100`, because everyday load sits under 30% and never left the bottom few pixels. Values above it clamp flat to the top rather than drawing outside the box. It is **per-series, not per-total**: the two graphs plot independently, so one series at 60% fills the height, while a 60% *total* split 40/20 tops out around two thirds. Read the label for an exact figure; the graph is for shape.
- `plugins/cpu_graph.sh` samples with **`iostat -c 2 -w 1 -n 0`** (row 2 is the 1s delta; row 1 is the since-boot average). `-n 0` is **required** — each attached disk prepends three columns and silently shifts `us/sy/id`, so awk would read disk throughput as CPU load. Deliberately not `top -l 2 -n 0`: same figures with decimals, but measured here it burns **~0.57s of CPU per sample** vs ~0.00s for iostat, which just sleeps. The cost is integer-percent granularity (~¼px on a 26px graph).
- **Wi-Fi cluster** (`items/wifi.sh` + `plugins/wifi.sh` + `plugins/wifi_ssid.sh`): the network icon beside a two-line throughput readout — red dot + upload above, blue dot + download below — in a `wifi.group` bracket. The SSID is no longer the label; it lives in a click-to-open popup, because it was spending the chip's whole width on a string that changes twice a day. The old single chip is commented out in `items/status.sh`, revertible the same way as the cpu one.
  - The two lines align because both pin the **same** `icon.width` (11) and `label.width` (52): `wifi.up` is `width=0` and therefore right-anchored, so equal inner widths are the only thing that puts both dots in one column. It also stops the chip resizing as a rate crosses KB/s → MB/s.
  - `label.width` **clips rather than grows**, so the formatter in `plugins/wifi.sh` is capped at 8 characters (MB/s from 1000 KB/s rather than 1024, no decimal past 10 MB/s). That cap is what lets the pinned width be tight; widen one without the other and you either clip or carry dead space.
  - Dots are 6pt against 9.5pt text — a filled circle fills its em box, so at label size it reads as a bullet as tall as the line. `ICON_UPLOAD`/`ICON_DOWNLOAD` arrow glyphs are pre-wired in `icons.sh` if you'd rather swap them in for `ICON_DOT`.
  - `plugins/wifi.sh` samples **`netstat -bnI <iface>`** and diffs against a state file in `$TMPDIR` — ~5ms with no sample window, unlike `iostat` for the CPU. Read the `<Link#N>` row (`Ibytes`=$7, `Obytes`=$10) with an `NF >= 11` guard; a row missing its MAC shifts the columns. State older than 60s is discarded rather than averaged across a sleep/wake, which is why the readout shows `--` for one tick after a reload.
  - The popup subscribes **`mouse.exited.global`, never plain `mouse.exited`** — the chip is three items, so a bare `mouse.exited` fires as the pointer crosses from the icon onto the numbers and shuts the popup mid-chip.
  - `plugins/wifi_ssid.sh` holds the whole SSID resolution chain (`networksetup` → `ipconfig getsummary` → `scutil` `CachedScanRecord` + python3 NSKeyedArchiver decode) and runs **only from `click_script`**, never on a timer.
- **Clock cluster** (`items/clock.sh` + `plugins/clock.sh`): the rightmost chip — a 16pt calendar glyph beside two centred lines, date over time (`Mon 10 Aug` / `11:07 AM`) — in a `clock.group` bracket. The old single-line `clock` item is commented out in `items/status.sh`; revert by uncommenting it and dropping `source items/clock.sh` from `sketchybarrc`.
  - `clock.time` owns `update_freq` and the script; one `date` call in `plugins/clock.sh` sets both labels. `clock.date` is `width=0` and so overlays it — which is why the **bracket is mandatory**, not cosmetic: without it `clock.time`'s own background paints over the date line (add-order draw).
  - Geometry is carried entirely by pinned widths, with every `label.padding_*`/`icon.padding_*` set to **0**. A bracket's box is the union of its members' `bounding_rects`, and a rect excludes padding — measured at 8/8 and 20/20, the box stayed exactly `label.width` and did not move. So the inner margin is slack in `CLOCK_BOX_WIDTH` (72 = the widest string, "Wed 22 May" at 55px, plus 8px a side) and in `CLOCK_ICON_WIDTH` (23 = the glyph's 15px at 16pt plus 8px) with `icon.align=right` throwing that slack to the left.
  - Both formats are fixed-length by construction (`%a`/`%b` are always 3 chars, `%d`/`%I` zero-padded), so only glyph width varies — but a pinned `label.width` **clips**, so re-measure before changing the font or size.
  - The icon deliberately does **not** set `icon.font`: it inherits 16pt from the `--default` block. 14pt was tried and rejected — the calendar glyph is a grid of day cells and they mush at that size.
- **RAM chip** (`items/ram.sh` + `plugins/ram.sh`): circuit-board glyph (`ICON_RAM`, nf-cod-circuit_board U+EABE) in `AQUA` + percent used, sitting between the cpu and wifi clusters. Only the icon is coloured — it escalates to yellow/orange/red at the thresholds below, while the label keeps the default `FG`. Three Material alternatives (`nf-md-memory`, `nf-md-integrated_circuit_chip`, `nf-md-alpha_r_box`) are kept commented in `icons.sh`; note the Codicon sits below U+FFFF, so it takes the 4-digit `\u` escape rather than the 8-digit `\U` the `nf-md-*` glyphs need. A **plain single item**, not a cluster — no bracket, no gap items, and its own `padding_left/right` (`RAM_GAP=3`) is the correct spacing mechanism, unlike the bracketed chips. It has its own file purely so `sketchybarrc` can position it by source order.
  - `plugins/ram.sh` computes Activity-Monitor-style usage from **`vm_stat`** — `(active + wired + compressor-occupied) × page size ÷ hw.memsize` — one instant counter read, no sample window. Inactive/speculative pages are excluded (they are reclaimable cache; counting them pegs the chip near full). Deliberately **not `memory_pressure`**: it costs ~0.22s per tick and its "free percentage" counts inactive pages as free — 85% free vs 55% used, same machine, same moment.
  - Thresholds are 90/80/65 (red/orange/yellow, else `FG`), much higher than the cpu chip's 70/30/10, because macOS runs memory hot by design.
- **Battery is hidden**, not removed: the item block is commented out in `items/status.sh` and `plugins/battery.sh` is untouched on disk. Uncomment the block to bring it back — it lands right of volume as before, with no other edits.
- `plugins/media.sh` needs `jq` (already in the Brewfile).
- Full property reference: `man sketchybar`, plus the [wiki](https://felixkratz.github.io/SketchyBar/).

## AI Assistant Notes

- Lessons learned from past sessions are documented in `.claude/tasks/lessons.md`
- Always read that file before making changes to Yazi theme, Neovim plugins, or colorscheme configs

## Memory Protocol

Project memory lives in `.claude/memory/MEMORY.md` — invariants, an append-only decision log, and
capped session history — injected at session start by the `load-memory` SessionStart hook
(`.claude/hooks/load-memory.sh`), which also carries it across `/compact`.

- `.claude/rules/memory.md` is the always-on trigger (auto-loaded; **do not `@`-import it**, rules
  in `.claude/rules/` already load at launch and importing double-loads them).
- The `memory-log` skill holds the write procedure: logging format, session summaries, archiving.
- Overflow goes to `.claude/memory/MEMORY_archive.md`, which is never read automatically.
- **SketchyBar invariants are split out into `.claude/memory/MEMORY-sketchybar.md`** (2026-08-10 —
  they were 63% of the Invariants section). The hook does **not** inject it: read it before editing
  anything under `sketchybar/`, and put new SketchyBar invariants there rather than in `MEMORY.md`.
- Native Auto Memory is disabled for this project (`autoMemoryEnabled: false` in
  `.claude/settings.json`) so the committed file stays the single source of truth.
- Hook stdout is capped by the harness, so keep each active memory file under **8,900 characters**.
  Verify with `bash .claude/hooks/load-memory.sh | wc -m` — over the cap, memory silently stops
  loading while the hook still reports success.

## Workflow Rules

- Keep Fish and Zsh aliases in sync when adding new ones
- Never commit secrets or credentials (secrets.fish is excluded via .gitignore)
- Kitty is the default terminal; WezTerm config is kept but Kitty is preferred
- WezTerm config lives at repo root as `.wezterm.lua` (not inside a .config subdir)
- Vim-style keybindings (hjkl) are used for pane navigation in both WezTerm and Kitty
- Neovim plugins should follow the LazyVim convention: one spec table per file in `lua/plugins/`
- When adding a new tool config, create a new stow package directory following the existing pattern
- GUI/WM-adjacent daemons (JankyBorders, SketchyBar) are launched from AeroSpace's `after-startup-command`, not from shell rc files or `brew services` — keeps one lifecycle owner. Use absolute paths there; that exec environment has no Homebrew in `PATH`

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

# Validate AeroSpace config without applying it
aerospace reload-config --dry-run

# Retune borders live (updates the running instance, no restart)
borders width=8.0

# Full borders restart (re-reads bordersrc)
killall borders; nohup borders >/dev/null 2>&1 & disown

# Reload sketchybar after editing any config file (re-runs sketchybarrc)
sketchybar --reload

# Check sketchybar config errors (it logs to stderr; nothing appears in the bar)
sketchybar --reload && sleep 1 && sketchybar --query bar | jq '.height, .position'

# Inspect a single item's resolved properties
sketchybar --query cpu

# Test a plugin without waiting for its event/tick
CONFIG_DIR=~/.config/sketchybar NAME=battery ~/.config/sketchybar/plugins/battery.sh

# Check item positions/overlap (bounding_rects is top-level, NOT under .geometry)
sketchybar --query cpu.percent | jq '.bounding_rects."display-1"'

# Verify chip gaps by pixel, not by eye — two touching chips read as ONE run.
# Retina capture is 2x, so resize back to points first. See lessons.md for the awk.
screencapture -x -R2900,0,500,39 /tmp/bar.png
magick /tmp/bar.png -resize 500x39! /tmp/bar.png
```

## Git Conventions

- Commit messages: short, descriptive (see recent history for style)
- User: Antonio Felizzola <antonio.qfel@gmail.com>
- All changes go directly to `main` branch
