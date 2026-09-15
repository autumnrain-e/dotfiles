# Dotfiles Memory

## Invariants & Gotchas

- **SketchyBar invariants live in `.claude/memory/MEMORY-sketchybar.md`** — chip geometry, brackets, `width=0` stacking, graphs, plugin sampling and pixel verification, split off 2026-08-10 because they were 63% of this section. That file is NOT auto-loaded: read it before editing anything under `sketchybar/`.
- **Ghostty invariants live in `.claude/memory/MEMORY-ghostty.md`** — config-read-once-at-startup, the two config paths, the kitty→ghostty key translation traps, and the bundled-theme variants. Split off 2026-08-22 when the package landed. NOT auto-loaded: read it before editing anything under `ghostty/`.
- kitty is a **manual install** (`curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin` = the `ku` alias), deliberately not the cask and deliberately absent from the Brewfile, so `brew bundle install` + `stow` leaves a fresh machine with `kitty.conf` and no kitty. Ghostty **is** in the Brewfile (2026-08-22), so a fresh machine does now get a terminal — just not that one.
- `brew install --cask --adopt <app>` takes ownership of an already-installed app **in place** when the versions match — no uninstall, the running app untouched — and cannot be combined with `--force` (which deletes and reinstalls). It also links artifacts a manual install misses: adopting ghostty added its man pages and fish completions.
- `brew bundle check` flags OUTDATED formulae with the same "needs to be installed or updated" line as missing ones, so its failure list is not an inventory of what the Brewfile is missing (79 outdated here on 2026-08-10). Check a single entry against `brew outdated`/`brew list` before believing it.
- kitty has been granted macOS Accessibility access; anything launched from a kitty window inherits it.
- AeroSpace `on-window-detected` rules never re-fire on an already-open window, so they cannot fix live runtime state (a float toggle, a stuck layout).
- AeroSpace per-workspace runtime state — root container `h_accordion`, per-window `floating` — is invisible in the config and is the usual cause of "tiling broke". Check `window-layout` via `aerospace list-windows` first.
- macOS "Move focus to next window" dead-ends after one hop in kitty: its patched-GLFW Cocoa layer never restacks `NSWindow`s and tiled windows never overlap, so the z-order list freezes. Use `alt-h`/`alt-l`.
- `~/.config/aerospace` is a tree-folded stow *directory* symlink (same inode) — repo edits are live, no re-stow needed.
- Nerd Font PUA glyphs must be written to config files via Python `\uXXXX` escapes — pasted glyphs are silently dropped or corrupted. `nf-md-*` glyphs above U+FFFF (e.g. U+F16E1) need the 8-digit `\U` form.
- "Symbols Nerd Font Mono" is required by kitty's `symbol_map` and every sketchybar icon, is **not** a system font, and kitty falls back silently with no error if it is missing. Cask: `font-symbols-only-nerd-font`.
- Each active memory file must stay under **8,900 chars** — past that the harness silently substitutes a preview while the hook still reports `success`. Verify with `bash .claude/hooks/load-memory.sh | wc -m`.
- AeroSpace measures gaps from the monitor's VISIBLE frame, and a notched built-in display's ~30pt menu-bar reserve is already excluded from it — so a top gap stacks on top of that. Current bar is 32px, so the target is 40pt (32+8): `[{ monitor."built-in" = 10 }, 40]` (10+30=40 on the notch).
- Per-monitor gaps re-resolve on monitor hot-plug — re-docking the display restored its own value with no config touch (one `asreload` was also run, so not cleanly isolated). `aerospace reload-config` DOES apply gaps live (verified, windows re-tile). Only `after-startup-command` needs a real restart — and `open -a AeroSpace` on a running app merely activates it, so AeroSpace, sketchybar and borders must all be killed first or the daemons stay dead.
- CoreText matches font style names EXACTLY; an unmatched style falls back to **Helvetica** silently, and `sketchybar --query` echoes the requested string, not the resolved font, so it never reveals the swap.
- Berkeley Mono here is the *Condensed* cut — faces are `Condensed`/`Medium Condensed`/`Bold Condensed`; there is no plain `Bold`.

## Decisions Log

[2026-09-15] DECISION: Python in Neovim is `basedpyright` + `ruff` (Mason `ensure_installed` and `vim.lsp.enable`) plus the `python` treesitter parser, declared in the existing plugin specs.
              REASON: Matches how the other languages are listed. basedpyright covers types/completion; ruff covers lint/format. Ruff hover is disabled so basedpyright owns `K`.
              REJECTED: pyright alone (no lint/format); pylsp; LazyVim `lang.python` extra (extras imports have already failed here for mini.icons and aerial).

[2026-08-31] DECISION: Media chip uses `media-control` (Brewfile), not SketchyBar `media_change`. Playing: equalizer bars; paused: nf-fa-pause + title; stopped: hidden. Item has `updates=on` and `update_freq=1`.
              REASON: `media_change` is deprecated on macOS 26 and does not fire (26.6.2). A hidden item with default `updates=when_shown` never runs its script, so it cannot unhide. `media-control get --no-artwork` talks to MediaRemote.
              REJECTED: nowplaying-cli (same Sequoia breakage); keeping `media_change` as primary.

[2026-08-31] DECISION: Logo is `nf-fa-canadian_maple_leaf` U+EF39, still `$YELLOW`. Coffee/pom-away/ghost stay commented alts. Supersedes archived [2026-08-24] coffee logo.
              REASON: User asked for the maple leaf after the flatten.
              REJECTED: Recolouring it to Canadian red — not asked.

[2026-08-31] DECISION: Weather chip after RAM uses Open-Meteo (no key) + IP geolocation (24h cache), Celsius, and Apple Color Emoji (☀️/🌙 from `is_day`). `icon.font` is Apple Color Emoji; `icon.color` is white so they are not tinted to ACCENT.
              REASON: User wanted temp + condition at current location. Open-Meteo beats a keyed API here: sketchybar is launched from AeroSpace and cannot see `secrets.fish`. IP, not CoreLocation — the bar has no TCC identity (same as SSID).
              REJECTED: WeatherAPI.com (gitignored key file for no gain at 48 calls/day); Nerd Font weather glyphs (user preferred emoji after seeing them live).

[2026-08-31] DECISION: SketchyBar is a flat 32px strip — no item boxes, workspace digits recolor on focus, right side `media | cpu | ram | clock` with pipes, wifi/volume unhooked (files kept). Text is Noto Sans Mono; Nerd glyphs stay on FONT_ICON. BAR_BG is BG1 @ 70% (`0xb3282828`). ACCENT is `$FG` (#d4be98), not borders orange. AeroSpace top gap is `[{ monitor."built-in" = 10 }, 40]`.
              REASON: User dropped the boxed/two-line look, then iterated color (orange → #C88C6A → coffee yellow → FG), alpha (opaque → 70%), font, and which sections stay.
              REJECTED: Copying the reference layout; keeping CPU graphs / two-line wifi / the two-tone app chip; tying ACCENT to borders; putting Nerd glyphs on Noto (tofu); nf-fa-memory as wifi-up (already RAM).

[2026-08-22] DECISION: `ghostty` is a new stow package ported from `kitty.conf`, carrying its own `themes/Gruvbox Material Dark Hard` instead of Ghostty's bundled Gruvbox Material Dark. kitty stays the documented default; ghostty is additive.
              REASON: The bundled theme is the MEDIUM variant (`#282828`), and its palette 3 would break the accent orange shared with JankyBorders and SketchyBar. `~/.config/ghostty/themes/` is searched before app resources, so a local file wins on a similar name.
              REJECTED: (1) `theme = Gruvbox Material Dark` — wrong variant, desyncs three tools. (2) Replacing the kitty package — kitty's conf is untouched and still default. (3) One theme file shared by both terminals — formats differ (`color3` vs `palette = 3=`).

---

## Session History

## Session — 2026-09-15 — Neovim Python LSP
### Worked On
- Adding Python to Neovim LSP, Mason, and Treesitter.
### Completed
- `basedpyright` + `ruff` in mason/`vim.lsp.enable`; ruff hover off so basedpyright owns `K`.
- Treesitter `python` parser in `ensure_installed`.
### In Progress (with next step)
- CLAUDE.md SketchyBar section is still stale (graphs, two-line chips, Helvetica, boxes).
### Decisions Made
- [2026-09-15] basedpyright + ruff, not LazyVim python extra.
### Next Session Priorities
1. Rewrite CLAUDE.md SketchyBar section to match the flat bar.
2. Document the ghostty package in CLAUDE.md + README.
