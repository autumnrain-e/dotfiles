# Dotfiles Memory

## Invariants & Gotchas

- **SketchyBar invariants live in `.claude/memory/MEMORY-sketchybar.md`** — 17 lines on chip geometry, brackets, `width=0` stacking, graphs, plugin sampling and pixel verification, split off 2026-08-10 because they were 63% of this section. That file is NOT auto-loaded: read it before editing anything under `sketchybar/`.
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
- AeroSpace measures gaps from the monitor's VISIBLE frame, and a notched built-in display's ~30pt menu-bar reserve is already excluded from it — so a top gap stacks on top of that: 47 put the window edge at 77pt there, 17 lands it at the intended 47. Per-monitor form: `[{ monitor."built-in" = 17 }, 47]`; `built-in` is a valid pattern.
- Per-monitor gaps re-resolve on monitor hot-plug — re-docking the display restored its own value with no config touch (one `asreload` was also run, so not cleanly isolated). `aerospace reload-config` DOES apply gaps live (verified, windows re-tile). Only `after-startup-command` needs a real restart — and `open -a AeroSpace` on a running app merely activates it, so AeroSpace, sketchybar and borders must all be killed first or the daemons stay dead.
- CoreText matches font style names EXACTLY; an unmatched style falls back to **Helvetica** silently, and `sketchybar --query` echoes the requested string, not the resolved font, so it never reveals the swap.
- Berkeley Mono here is the *Condensed* cut — faces are `Condensed`/`Medium Condensed`/`Bold Condensed`; there is no plain `Bold`.

## Decisions Log

[2026-08-22] DECISION: `ghostty` is a new stow package ported from `kitty.conf`, carrying its own `themes/Gruvbox Material Dark Hard` instead of Ghostty's bundled Gruvbox Material Dark. kitty stays the documented default; ghostty is additive.
              REASON: The bundled theme is the MEDIUM variant (`#282828`), and its palette 3 would break the accent orange shared with JankyBorders and SketchyBar. `~/.config/ghostty/themes/` is searched before app resources, so a local file wins on a similar name.
              REJECTED: (1) `theme = Gruvbox Material Dark` — wrong variant, desyncs three tools. (2) Replacing the kitty package — kitty's conf is untouched and still default. (3) One theme file shared by both terminals — formats differ (`color3` vs `palette = 3=`).

[2026-08-22] DECISION: `cask "ghostty"` is in the Brewfile as a bootstrap-only entry, reconciled with the already-installed 1.3.1 via `brew install --cask --adopt`.
              REASON: Closes the fresh-machine gap kitty has on purpose. The cask is `auto_updates`, so `brew upgrade` skips it and Ghostty's own updater stays in charge — brew only bootstraps, and the Caskroom version going stale is expected.
              REJECTED: (1) Leaving it out for symmetry with kitty — kitty's absence is forced by its curl-installer upstream, ghostty has a real cask. (2) `--force` — deletes and reinstalls a working app. (3) Uninstall-then-install — same, with downtime.

[2026-08-10] DECISION: `gaps.outer.top` is per-monitor — `[{ monitor."built-in" = 17 }, 47]` — and the WM/bar lifecycle commands are aliases in both shells: `ascheck`/`asreload`/`asrestart`, `sbreload`/`sbrestart`.
              REASON: The two displays need different numbers for the same 47pt clearance (see the visible-frame invariant), so undocking the Dell used to mean hand-editing the value. One config now covers both, and `asreload` alone applies it — the aliases make that one word instead of a recalled kill/sleep/open chain.
              REJECTED: (1) A single constant edited per screen — exactly what produced the oversized laptop gap. (2) `brew services` for sketchybar/borders — AeroSpace stays the single lifecycle owner. (3) Reaching for `asrestart` after a gaps edit; `asreload` suffices and leaves the daemons alone.

---

## Session History

## Session — 2026-08-22 — Ghostty package
### Worked On
- New `ghostty` stow package ported from `kitty.conf`; Homebrew cask adopt; SketchyBar ghost glyph.
### Completed
- `config.ghostty` + local `themes/Gruvbox Material Dark Hard`, stowed, `+validate-config` clean and every resolved value checked.
- `brew install --cask --adopt ghostty` (1.3.1 in place, gained man pages + fish completions) and `cask "ghostty"` in the Brewfile.
- `ICON_APP_GHOSTTY` U+EEFE + `"Ghostty"` branch in `plugins/front_app.sh`; verified on the live bar and by screenshot.
### In Progress (with next step)
- CLAUDE.md + README have no Ghostty section yet — write one next.
- Carried: `config.fish.bak.*`; reboot-verify daemons; media.
### Decisions Made
- [2026-08-22] ghostty package with its own hard-variant theme file; [2026-08-22] Brewfile bootstrap-only cask via `--adopt`.
### Next Session Priorities
1. Document the `ghostty` package in CLAUDE.md + README.
2. Decide GitKraken's glyph — U+F2AC resolves to `fa-snapchat_ghost`, now a visual twin of Ghostty's chip, and this font has no GitKraken glyph.
3. Drop stray `config.fish.bak.*` before stow.

## Session — 2026-08-20 — Claude app icon
### Worked On
- SketchyBar front_app chip: Claude glyph.
### Completed
- `nf-cod-claude` U+EC82 for `"Claude"` | `"Claude Code"`; user confirmed live.
### In Progress (with next step)
- Carried: `config.fish.bak.*`; reboot-verify daemons; media.
### Decisions Made
- None — followed the existing `$INFO` map pattern.
### Next Session Priorities
1. Drop stray `config.fish.bak.*` before stow.
2. Reboot-verify sketchybar + borders.
