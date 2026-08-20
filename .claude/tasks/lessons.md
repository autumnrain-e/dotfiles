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

## Kitty

### hsplit/vsplit require the splits layout
- **Problem**: `launch --location=vsplit` and `launch --location=hsplit` appear to do nothing (or default to the same split direction) even after reloading config.
- **Root cause**: These location values only work in Kitty's `splits` layout. Without it, Kitty uses the default `tall` layout and ignores the `hsplit`/`vsplit` hint entirely.
- **Fix**: Add `enabled_layouts splits` to `kitty.conf`. After that, `vsplit` = vertical divider (left/right panes) and `hsplit` = horizontal divider (top/bottom panes).

### split direction terminology
- `vsplit` = vertical dividing line = left/right panes (what most people call a "vertical split")
- `hsplit` = horizontal dividing line = top/bottom panes (what most people call a "horizontal split")

---

## Neovim (continued)

### image.nvim — SVG badge rendering error (magick: unable to read font)
- **Problem**: Hovering over a remote badge image in a README (e.g. shields.io) triggers `magick: unable to read font '' @ error/annotate.c/RenderFreetype`.
- **Root cause**: Shields.io badges are SVGs. Homebrew's `imagemagick` formula no longer includes `librsvg`, so ImageMagick falls back to its own MSVG renderer which requires fonts — and finds none on macOS.
- **Dead ends**:
  - Installing `ghostscript` alone does not fix it; `imagemagick` must be rebuilt to pick up Ghostscript as a delegate, and even then SVG font rendering is unreliable.
  - `brew reinstall imagemagick` after installing `librsvg` did not add `rsvg` to the delegates — Homebrew's formula simply doesn't link librsvg.
  - Setting `MAGICK_FONT_PATH` to a colon-separated list breaks things further: ImageMagick treats the whole string as a single path and tries to open `<full-string>/type.xml`.
  - `resolve_image_path` in the markdown integration opts is **only called for local paths** — it is never invoked for remote URLs (those go through `from_url` directly). Returning `nil` from it does nothing for badges.
- **Fix**: Monkey-patch `require("image").from_url` after setup in a `config` function to silently skip badge URLs:
  ```lua
  config = function(_, opts)
    require("image").setup(opts)
    local api = require("image")
    local original_from_url = api.from_url
    api.from_url = function(url, options, callback)
      if is_badge_url(url) then
        if callback then callback(nil) end
        return
      end
      return original_from_url(url, options, callback)
    end
  end
  ```
  `ctx.api` inside the integration IS the same table as `require("image")`, so patching it post-setup affects all integration calls.
- **Badge detection**: Match on `shields%.io`, `badgen%.net`, `github%.com/.+/workflows/`, `codecov%.io`, and `%.svg` extension.

---

## Yazi

> **Current state (2026-05-29)**: active flavor is `gruvbox-material`, not everforest-medium.
> The `[filetype]`/`[icon]` directory-green overrides below are **commented out** in `theme.toml`
> because gruvbox-material colors directories itself. The notes are kept for when a flavor
> needs manual directory coloring again.

### Yazi 26.5.6 won't start — `$schema` rejected + `missing field group`
- **Problem**: `yazi` failed with `TOML parse error ... "$schema" ... must be a kebab-cased string` (line 3). After removing `$schema`, a second error surfaced: `missing field group` in the `[plugin]` fetchers.
- **Root cause**: Yazi 26.5.6 is a **breaking release** (see CHANGELOG v26.5.6). The repo's `yazi.toml`/`keymap.toml` were near-verbatim copies of an *older* Yazi's default config, so multiple breaking changes hit at once: (1) top-level keys must be kebab-case, so `"$schema"` is rejected; (2) `[plugin]` fetcher entries now require a `group` field.
- **Fix**: Remove the `$schema` header lines from both files, and **delete the entire `[plugin]` block** (fetchers/spotters/preloaders/previewers) from `yazi.toml`. That block was identical to Yazi's built-in defaults — Yazi merges user config over defaults, so removing it loses nothing and is upgrade-proof.
- **General rule**: Never paste Yazi's full default config into your dotfiles. Keep **only the keys you actually override**. Pasting defaults means every breaking release breaks you.
- **Diagnose/verify**: `yazi --version` parses the config first and prints the parse error before the version string — use it to confirm the config is valid (clean output = `Yazi 26.5.6 (Homebrew ...)`).
- **Note on deployment**: `~/.config/yazi` is a stow **directory** symlink → `../dotfiles/yazi/.config/yazi`, so `ls -la ~/.config/yazi/<file>` shows the *target* (a regular file), making individual files look un-symlinked. Check `ls -ld ~/.config/yazi` to see the real symlink. Editing the repo file updates the live config directly.

### Folder icon color — blue despite Everforest flavor
- (Historical — applied under the everforest-medium flavor; overrides currently commented out under gruvbox-material.)
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

---

## Fonts

### "Symbols Nerd Font Mono" was never actually installed
- **Problem**: `kitty.conf` maps its entire `symbol_map` range to `Symbols Nerd Font Mono`, and CLAUDE.md documented it as an installed fallback — but the font was not on the machine. Discovered while wiring up SketchyBar icons.
- **How it hid**: Kitty (and CoreText generally) fall back to another font **silently** — no warning, no error, no log line. Glyphs either render as tofu boxes or get substituted, which is easy to misread as "the icon is wrong" instead of "the font is missing".
- **Verify properly**: `ls ~/Library/Fonts /Library/Fonts` — user-installed fonts live there. Do **not** trust `kitty +list-fonts` from a non-interactive shell: it needs a tty and dies with `Error: open /dev/tty: device not configured`. `system_profiler -json SPFontsDataType` can also return an empty set under a sandbox, which looks identical to "no fonts installed".
- **Fix**: `brew install --cask font-symbols-only-nerd-font` (glyphs-only, no text faces — keeps Berkeley Mono as the primary font) and record it in the Brewfile.

---

## AeroSpace

### Windows stop tiling / stack on top of each other — check the layout, not permissions
- **Symptom**: new windows pile on top of each other instead of tiling; feels like AeroSpace "stopped working" after a restart.
- **Root cause found (2026-08-05)**: the workspace's **root container layout** was `h_accordion`, not `tiles`. In accordion, windows overlap with `accordion-padding` and the focused one takes the space — visually identical to "not tiling". `default-root-container-layout = 'tiles'` only seeds *new* workspaces, and this is per-workspace **runtime** state, so `reload-config` does not clear it and nothing in the config reveals it.
- **Diagnose** (all read-only, no format guessing — `%{window-is-floating}` does not exist):
  ```bash
  aerospace list-windows --workspace focused \
      --format '%{app-name}|%{window-layout}|%{workspace-root-container-layout}'
  ```
  Values seen in practice: `h_tiles` / `v_tiles` (healthy), `h_accordion` (the bug), `floating` (window opted out of tiling), `macos_native_window_of_hidden_app` (app is hidden, not in the tree).
- **Fix**: `aerospace layout tiles horizontal vertical` (the `alt-slash` binding).
- **Why a keypress can look dead**: `layout` applies to the **focused window's parent container**. Pressing `alt-slash` while a `floating` or `macos_native_window_of_hidden_app` window is focused does nothing to the tiling root, so the layout never changes and the binding appears broken. Focus an actually-tiled window first.
- **Ruling out the usual suspects first** (saves a wrong diagnosis):
  - If `list-windows` prints live window **titles**, accessibility permission is fine — titles come from the AX API. Don't go re-granting permissions.
  - If a CLI command like `aerospace layout tiles` returns `exit=0` **and** the queried state changes, the server, config load, and AX access are all healthy — the problem is state, not the daemon.
  - Secure input blocks global hotkeys; check with `ioreg -l -d 1 -k IOConsoleUsers | grep kCGSSessionSecureInputPID`.
  - `aerospace enable on --fail-if-noop` returns exit 2 with **no message**, so it is useless as an enable-state probe. Infer enabled-ness from whether a mutating command actually changes state.
- **Red herring to avoid**: "hotkeys failed to register because the restart raced" — plausible-sounding and wrong in this case. The hotkeys were fine; the accordion layout was the whole defect. Confirm a hotkey is dead by pressing it and re-querying state before theorizing about registration.
- **`focus --window-id` follows the window across workspaces.** After focusing a window that lives elsewhere, `--workspace focused` reports that *other* workspace, so unrelated windows appear to have "vanished". Query `list-windows --all --format '%{workspace}|%{app-name}'` before concluding anything was lost.

### Daemons spawned by after-startup-command outlive AeroSpace
- `killall AeroSpace` does **not** kill `borders` / `sketchybar` — verified 2026-08-05: the login-time `borders` (PID 1016) was still running after AeroSpace was killed and relaunched under a new PID.
- Consequence: restarting AeroSpace leaves the old daemon running and the fresh `after-startup-command` launch is a no-op (or errors on a second instance). Always `killall sketchybar borders` first.

---

## SketchyBar

### Right-side items are added right-to-left
- The **first** `right` item added ends up **rightmost**. Sourcing order in `sketchybarrc` therefore reverses on screen: source `items/status.sh` before `items/media.sh` to get `media | cpu | wifi | volume | battery | clock`.
- `left` items behave the intuitive way (first added = leftmost).

### AeroSpace workspaces need a custom event
- **Problem**: sketchybar's built-in `space_change` event never fires for AeroSpace workspaces — AeroSpace workspaces are not macOS Spaces.
- **Fix**: declare `sketchybar --add event aerospace_workspace_change`, fire it from `exec-on-workspace-change` in `aerospace.toml`, and `--subscribe` each `space.*` item to it. AeroSpace exports `$AEROSPACE_FOCUSED_WORKSPACE` to that callback.
- **Startup gotcha**: the event has not fired when the bar first launches, so nothing is highlighted until the first workspace switch. Seed it at the end of `sketchybarrc`:
  ```bash
  sketchybar --trigger aerospace_workspace_change \
      FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"
  ```

### PATH is not inherited when launched from AeroSpace
- `exec-and-forget` gives a minimal PATH with no `/opt/homebrew/bin`. Use the absolute path in `after-startup-command`, and `export PATH="/opt/homebrew/bin:$PATH"` at the top of `sketchybarrc` so plugins can find `aerospace`, `jq`, and `sketchybar`.

### AeroSpace does not reserve space for the bar
- The bar is an overlay window, so tiled windows sit under it. Set `gaps.outer.top` to the bar height (+ any gap you want). 39px bar → `gaps.outer.top = 47`.

### Plugin gotchas found while testing
- Plugins run as **fresh processes**: they must re-`source` `colors.sh`/`icons.sh`. Only `$CONFIG_DIR`, `$NAME`, `$SENDER`, `$INFO` come from sketchybar.
- BSD `grep -E` has **no `\d`** — `grep -Eo '[0-9]+%'`, not `'\d+%'`, when parsing `pmset -g batt`.
- `osascript -e 'output volume of (get volume settings)'` can return **`missing value`** (active output device exposes no software volume — some DACs, HDMI, AirPlay). Guard with a non-numeric case and hide the label instead of printing a bogus number; the `volume_change` event's `$INFO` still works.
- Test any plugin without installing sketchybar by putting a stub `sketchybar` that just echoes its args first on `PATH`, then running the plugin with `CONFIG_DIR`/`NAME`/`INFO` set by hand. Catches quoting and logic bugs before the bar ever runs.

### `graph` items and the `width=0` stacking trick
Learned porting FelixKratz's CPU graph cluster into `items/cpu.sh`.

- `--add graph <name> <side> <width>` takes width as a **positional argument**, not `width=`. Values are fed with `--push <name> <value>` where value is a **0.0–1.0 fraction**, not a percentage — pushing `42` for 42% pins the plot off the top of the box.
- A graph plots **inside its background rect**. So `background.drawing=on` is mandatory (with `background.color=$TRANSPARENT` if you don't want a visible box), and `background.height` is really the *plot height*. Leaving it unset lets it inherit the `--default` height, which is how the plot ends up exactly filling the chip — and keeps the chip-geometry-in-one-place rule intact.
- **`width=0` is the stacking primitive.** A zero-width item consumes no horizontal space *and never advances the layout cursor*, so the next item is drawn at the same x and the two overlap. Two graphs stacked this way = one two-tone chart; a tiny label over a big one = a two-line text block.
- **Direction matters and is easy to get backwards**: a zero-width item's label is **right-anchored and extends leftward**. So it must be added *before* (= to the right of) the item it should overlay. Add it after and the label lands one item too far left, over whatever precedes it. I got this wrong twice — first the caption spilled outside the bracket, then it sat over the graph.
- Corollary: since a zero-width item never advances the cursor, its `padding_right` shifts **only itself** and nothing downstream. An item with a real box needs `label.padding_right` instead for the same inset — item padding there pulls the enclosing bracket's right edge in with it and cancels the margin out.
- **A bracket is right when the items genuinely are one element** (this cluster), and wrong when they merely sit next to each other (the workspace chips, which each need their own box). Bracket = one box spanning the union of its members' rects.
- Don't eyeball overlap — measure it. `sketchybar --query <item> | jq '.bounding_rects."display-1"'` gives origin+size; two items sharing an origin are genuinely stacked. Note `bounding_rects` is **top-level**, not under `.geometry`.

### Sampling CPU in shell: `iostat`, not `top`
- macOS has **no `kern.cp_time`** (that's FreeBSD), so there is no cheap cumulative CPU tick counter for a stateful delta the way the upstream C helper does it with `host_statistics()`. A shell plugin must sample over a real time window.
- `iostat -c 2 -w 1` = two samples 1s apart; **row 2 is the delta**, row 1 is the average since boot (using row 1 shows a number that barely moves).
- **`-n 0` is not optional**: without it iostat prints per-disk columns first, and every attached drive shifts `us/sy/id` three fields right. The awk indices then silently read disk throughput as CPU load — wrong numbers, no error.
- **`top -l 2 -n 0` is the trap.** Same figures with decimal precision, but measured on this machine it costs **~0.57s of CPU per sample** (`real 1.59 user 0.06 sys 0.51`) vs **~0.00s** for iostat (`real 1.03 user 0.00 sys 0.00`) — iostat spends its second asleep. At `update_freq=2` that's ~30% of a core burned permanently to draw a CPU meter. Benchmark the sampler; the intuitive choice was 30x worse.
- Busiest process: `ps -Aceo pcpu,comm -r | sed -n '2p'`. `-c` gives the accounting name only (no path/args), `-r` sorts by CPU, so row 2 is the winner. Strip the `com.apple.` prefix — it's noise at bar width.

### A bracket cannot be spaced by padding — use an empty item
The cpu and wifi clusters shipped visually **touching** each other while every plain chip around them had a 6px gap. Three separate attempts to space them did nothing, and one of them fooled me into announcing a fix that wasn't there.

What does **not** work, all four measured against the rendered bar:
- **`padding_left`/`padding_right` on the bracket** — ignored outright. Set it to `20` and no rect moves; `--query` reports the property back as `null`.
- **`padding_left`/`padding_right` on the member items** — the bracket grows its box to swallow it. The chip gets *wider*; the gap never appears.
- **`background.padding_left`/`background.padding_right` on the bracket** — no pixel effect either. This is the one that looked right in an upscaled screenshot; a proper pixel scan showed captures at 6, 7 and 8 were byte-identical.
- **`--move <spacer> before <item>`** — the spacer got a real rect, but `--move` put it left of the *entire* neighbouring cluster instead of between the two. Ordering via `--move` is not worth reverse-engineering; source order in the item file is deterministic.

What works: **a real item holding empty space**, declared in the cluster's own file and *not* added as a bracket member.
```bash
sketchybar --add item cpu.gap.right right \
    --set cpu.gap.right width=3 \
    icon.drawing=off label.drawing=off background.drawing=off
```
Add it **first** in the file for a gap on the cluster's right edge, **last** for its left edge (right items are added right-to-left). Each cluster carries one on each side, so two adjacent clusters meet at 3+3=6px — the same total two plain chips get from their own `padding_left`/`padding_right`. Keep it out of the `--add bracket` member list, or its space falls *inside* the box.

Plain items are the opposite case and this is the whole reason for the confusion: their background excludes their own padding, so for them item padding *is* the correct spacing mechanism.

**Measure, don't look.** A zoomed screenshot of a 3px gap is not evidence. Scan the actual pixels for the chip colour and print runs:
```bash
screencapture -x -R2900,0,500,39 /tmp/bar.png
magick /tmp/bar.png -resize 500x39! /tmp/bar.png   # retina capture -> points
magick /tmp/bar.png -crop 500x26+0+7 +repage txt:- | awk '
NR>1 { split($1,a,","); if ($0 ~ /#282828/) seen[a[1]+2900]=1 }
END { for (x=2900; x<3400; x++) {
  if (seen[x] && !inrun) { start=x; inrun=1 }
  else if (!seen[x] && inrun) { w=x-start; if (w>=15) { printf "box %d..%d (w %d)", start, x-1, w;
    if (pe!="") printf "   gap %d", start-pe-1; printf "\n"; pe=x-1 }; inrun=0 } } }'
```
Two chips that are touching read as **one merged run** of their combined width — that single number is the whole test. Cross-check the runs against `bounding_rects`; they should agree exactly.

Also: geometry drifts for reasons unrelated to your change. Mid-investigation every box left of `volume` jumped 23px because the volume plugin had picked up a `0%` label and grown. Re-read the neighbours' rects before blaming the edit.

### Wi-Fi throughput chip (two stacked lines + SSID popup)
- **`netstat -bnI <iface>` needs no sample window** — read the `<Link#N>` row (`Ibytes`=$7, `Obytes`=$10) and diff against a small state file in `$TMPDIR`. ~5ms, versus the 1s the CPU plugin has to spend sleeping in `iostat`. Guard the row with `NF >= 11 && $3 ~ /^<Link/`: a row missing its MAC address shifts the byte columns.
- Cap the state file's age (here 60s). A stale baseline across a sleep/wake draws a rate smeared over the whole gap. Clamp negative deltas too — the counters reset when the interface cycles.
- **Cap the formatter's output width, then pin the label to it.** Switching to MB/s at 1000 KB/s (not 1024) and dropping the decimal past 10 MB/s keeps every possible string at 8 characters, which let `label.width` be 52 instead of the ~60 a 4-digit `1023 KB/s` would force. A fixed text width **clips** rather than grows, so the cap is what makes the tight width safe — and the difference is dead space visible in the chip at every normal rate.
- Aligning two stacked lines: pin the **same** `icon.width` and `label.width` on both. `width=0` right-anchors the overlay while the boxed item is left-anchored, so with variable-width labels the two dots hang at different x. Equal inner widths make both edges coincide.
- **`icon.padding_right` reads as roughly half itself** for a small filled circle — the 6pt glyph's ink is far narrower than the slot it's centred in. Set it by eye against the render; 4 still had the dot touching the digits, 7 was right.
- A filled-circle icon must be much smaller than the text (6pt against 9.5pt), because the glyph fills its em box and at label size it reads as a bullet as tall as the line.
- **Subscribe `mouse.exited.global`, never plain `mouse.exited`,** for a popup on a multi-item chip. A bare `mouse.exited` fires when the pointer merely crosses from the icon onto the label, slamming the popup shut halfway across the chip that opened it.
- Move expensive lookups off the poll path. The SSID chain (`networksetup` → `ipconfig` → `scutil` + a python3 NSKeyedArchiver decode) now lives in its own `plugins/wifi_ssid.sh`, run from `click_script` only — it was being paid every 2s for a string that changes twice a day.
- **`sketchybar --reload` is asynchronous.** A plugin invoked on the next line fails with `[!] Set: Item not found` because the rebuild hasn't finished. Sequence it as a separate call after a short wait.

---

## Claude Code

### Custom skills — correct directory structure
- **Problem**: Skill files placed as flat `.md` files in `.claude/skills/` (e.g. `.claude/skills/update-lessons.md`) do not appear in the `/skills` picker.
- **Root cause**: The `.claude/skills/` loader expects a **subdirectory per skill** containing a `SKILL.md` entrypoint. Flat `.md` files in that directory are not recognized.
- **Fix**: Restructure each skill into its own subdirectory:
  ```
  .claude/skills/update-lessons/SKILL.md   ✓ correct
  .claude/skills/update-lessons.md         ✗ not recognized
  ```
  Quick migration:
  ```bash
  cd .claude/skills
  for skill in update-lessons update-claude-md nvim-colorscheme update-readme; do
    mkdir -p "$skill" && mv "$skill.md" "$skill/SKILL.md"
  done
  ```
- **Alternative**: Flat `.md` files in `.claude/commands/` (not `.claude/skills/`) also work and create the same `/name` slash commands — that is the legacy path.

---

## Neovim (LSP / Mason)

### `_transport.lua:68` "not executable" error after 0.11→0.12 upgrade
- **Problem**: Opening any file showed an LSP error (`.../vim/lsp/_transport.lua:68: ...`) and there were no diagnostics or intellisense.
- **Real error** (from `~/.local/state/nvim/lsp.log`, NOT the truncated UI popup): `cmd: ... got table. Info: lua-language-server is not executable`.
- **Root cause**: The language server binaries were never installed. `~/.local/share/nvim/mason/bin/` only had `shfmt`, `stylua`, `tree-sitter` — no LSP servers. `lsp.lua` calls `vim.lsp.enable({...})`, which tries to spawn servers whose binaries don't exist → spawn failure. The 0.12 upgrade (or a Mason reset) wiped the servers and nothing reinstalled them.
- **NOT the cause**: The 0.12 LSP API changes. `vim.lsp.enable(...)` / `vim.lsp.config` is the correct current 0.12 idiom — the config was already right.
- **Fix**: Add `mason-org/mason-lspconfig.nvim` with `ensure_installed` (lspconfig-style names) so missing servers auto-install on startup — matches the "auto-installed via Mason" claim in CLAUDE.md, which was previously never actually wired up. To unblock immediately without a restart, run headless with Mason **package** names (different from lspconfig names):
  ```bash
  nvim --headless "+MasonInstall lua-language-server emmet-ls html-lsp css-lsp typescript-language-server yaml-language-server taplo" +qa
  ```
- **Name mapping** (lspconfig → Mason package): `lua_ls`→`lua-language-server`, `emmet_ls`→`emmet-ls`, `html`→`html-lsp`, `cssls`→`css-lsp`, `ts_ls`→`typescript-language-server`, `yamlls`→`yaml-language-server`, `taplo`→`taplo`. `ensure_installed` in mason-lspconfig v2 uses the **lspconfig** names; `:MasonInstall` uses the **package** names.
- **Diagnose first**: Always read `~/.local/state/nvim/lsp.log` for the real error — the floating UI popup truncates it. Verify installs with `ls ~/.local/share/nvim/mason/bin/`.

### vim.pack (0.12 built-in plugin manager) — do NOT migrate from LazyVim
- 0.12 ships `vim.pack` (native plugin manager: `vim.pack.add/update/del`, `nvim-pack-lock.json` lockfile).
- The guide's author (echasnovski) explicitly recommends LazyVim users start from a clean config rather than migrate — there is no clean 1:1 path from lazy.nvim's spec system. This repo stays on LazyVim/lazy.nvim. To experiment safely, use `NVIM_APPNAME=nvim-pack`.

## Neovim (lualine)

### lualine — Nerd Font icon not written to file by Edit/Write tool
- **Problem**: Wanted to prepend the Nerd Font Vim icon (`` U+E62B) to the mode text in lualine (`NORMAL` → ` NORMAL`).
- **What failed**: Writing the file with the Write tool produced a file where the icon was silently dropped — the bytes showed only `20 22 20 22` (space-quote-space-quote) with no icon. The character appeared present in the tool call but was not saved.
- **Root cause**: The Write/Edit tools silently drop certain non-ASCII Unicode characters (like Nerd Font glyphs) when writing file content.
- **Fix**: Use Python to write the file, concatenating the icon as a raw string literal:
  ```python
  icon = ""  # U+E62B, typed or pasted directly in the Python source
  content = '... return "' + icon + ' " .. str\n ...'
  with open('path/to/lualine.lua', 'w', encoding='utf-8') as f:
      f.write(content)
  ```
  Verify with `hexdump -C` that the bytes `ee 98 ab` (UTF-8 for U+E62B) are present before telling the user to reload.
- **Working lualine.lua** for prepending a Vim icon to mode:
  ```lua
  return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local mode = opts.sections.lualine_a[1]
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            return " <icon> " .. str  -- icon written via Python
          end,
          padding = type(mode) == "table" and mode.padding or { left = 1, right = 1 },
        },
      }
      return opts
    end,
  }
  ```
