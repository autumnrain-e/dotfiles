# Dotfiles Memory

## Invariants & Gotchas

- **SketchyBar invariants live in `.claude/memory/MEMORY-sketchybar.md`** — 17 lines on chip geometry, brackets, `width=0` stacking, graphs, plugin sampling and pixel verification, split off 2026-08-10 because they were 63% of this section. That file is NOT auto-loaded: read it before editing anything under `sketchybar/`.
- kitty is a **manual install** (`curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin` = the `ku` alias), deliberately not the cask and deliberately absent from the Brewfile — so `brew bundle install` + `stow` leaves a fresh machine with `kitty.conf` and no terminal.
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

[2026-08-19] DECISION: Logo cycles `assets/doom/<N>_*/doom_guy_*.png` — 5s/frame, last frame of a folder holds 180s, then next folder, wrap after 4. `--reload` wipes `$TMPDIR/sketchybar_doom.state` → 0/0. Ghost/geometry unchanged; `doom.png` is revert-only.
              REASON: HUD look-around, then a long pause, then the next damage set. One file per frame so the image cache swaps.
              REJECTED: (1) Random every minute — first ask. (2) CPU-load faces — not requested. (3) Color-key only — beige halo; 1px erode cleared it. (4) Overwriting one `doom.png` — cache ignores the write.

[2026-08-14] DECISION: `front_app.icon` glyph is 18pt (`APP_ICON_SIZE`); the 28px box and the bar-wide 16pt `--default` stay. Revert: drop the `icon.font` line.
              REASON: 16pt looked small in the accent square; 18pt fills it without clipping. Isolated override so workspace/ram/wifi/clock icons do not move.
              REJECTED: (1) Bumping `--default` `icon.font` to 18 — resizes every other chip. (2) Growing `APP_ICON_WIDTH` to match — breaks the square match with `SPACE_WIDTH`.

[2026-08-14] DECISION: Logo is the Doom face (`assets/doom.png`); ghost kept commented. Both ends of the workspace row use a `SPACE_EDGE=8` spacer plus the adjacent workspace's `SPACE_GAP=2` (visible 10px). Revert: uncomment the ghost (`padding_right=0`), drop the doom `--add`, KEEP `logo_separator`.
              REASON: Pinned `width=35` swallows `padding_right`, so `LOGO_GAP` stopped pushing the row and doom-to-1 collapsed to 2px. A spacer matches `space_separator` on the app-chip side. Face is a 32px nearest-neighbour sprite at scale 0.75, centred with `image.padding_left=6`.
              REJECTED: (1) Restoring `LOGO_GAP` on the item — dead under pinned width. (2) Putting the whole 10px on `space.1` `padding_left` — makes 1-to-2 asymmetric. (3) Uncommenting the ghost AND restoring `LOGO_GAP=10` — stacks on `logo_separator` and the left gap becomes 20px.

[2026-08-14] DECISION: A plain `ram` chip — nf-cod-circuit_board glyph in AQUA + percent used, `vm_stat`-sampled — sits between the cpu and wifi clusters in its own `items/ram.sh`; `battery` is commented out in `items/status.sh`, not deleted.
              REASON: Chip order is expressed ONLY by the `source` block in `sketchybarrc`, so ram needed its own file to be positionable. Percent used matches the cpu readout and is the narrowest label; AQUA is the one palette entry no other item claims. Battery's plugin is still correct on disk, so a comment is a one-line revert.
              REJECTED: (1) `17.9G`/`17.9/32G` labels — wider chip. (2) nf-md-memory, -integrated_circuit_chip, -alpha_r_box — each tried live and rejected on sight (the last is filled where every neighbour is stroked); all kept as commented alts. (3) `memory_pressure` sampling — see the sketchybar invariant. (4) A bracket — this is a plain item, so its own padding spaces it.

[2026-08-14] DECISION: The front_app chip is two-tone — per-app glyph (`$BG0`) in an `$ACCENT` box, 2px seam, app name on `$GROUP_BG` — built as two PLAIN items, keyed off `$INFO`.
              REASON: A bracket is impossible here — it draws ONE box beneath its members and the point is two colors. Plain items make item padding the right spacing tool, so the whole seam sits on the icon half's `padding_right` and the constant equals the visible gap, not half of it. Accent ties the chip to the focused workspace and the logo.
              REJECTED: (1) A powerline-arrow seam (the user's other reference) — sharp against corner_radius=6 everywhere else. (2) Fixed green, and per-app colors — the bar's left edge would change hue every app switch. (3) Name kept in `$ACCENT` — orange text beside an orange box kills the contrast.

[2026-08-10] DECISION: `gaps.outer.top` is per-monitor — `[{ monitor."built-in" = 17 }, 47]` — and the WM/bar lifecycle commands are aliases in both shells: `ascheck`/`asreload`/`asrestart`, `sbreload`/`sbrestart`.
              REASON: The two displays need different numbers for the same 47pt clearance (see the visible-frame invariant), so undocking the Dell used to mean hand-editing the value. One config now covers both, and `asreload` alone applies it — the aliases make that one word instead of a recalled kill/sleep/open chain.
              REJECTED: (1) A single constant edited per screen — exactly what produced the oversized laptop gap. (2) `brew services` for sketchybar/borders — AeroSpace stays the single lifecycle owner. (3) Reaching for `asrestart` after a gaps edit; `asreload` suffices and leaves the daemons alone.

---

## Session History

## Session — 2026-08-19 — Doom face cycle
### Worked On
- Cycling SketchyBar logo through 42 HUD faces.
### Completed
- Knock-out+1px-erode; `plugins/doom.sh` 5s/frame, 3min folder hold, reload → 0/0. User signed off after testing.
### In Progress (with next step)
- Carried: `config.fish.bak.*`; reboot-verify daemons; media.
### Decisions Made
- [2026-08-19] sequential HUD cycle; static `doom.png` is revert-only.
### Next Session Priorities
1. Drop stray `config.fish.bak.*` before stow.
2. Reboot-verify sketchybar + borders.
