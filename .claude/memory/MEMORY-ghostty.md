# Dotfiles Memory — Ghostty Invariants

Domain split off `.claude/memory/MEMORY.md` on 2026-08-22, when the `ghostty` stow package
landed: the port from `kitty.conf` produced ~7 invariants at once, and MEMORY.md was already at
8,577 of 8,900 chars. Same precedent as `MEMORY-sketchybar.md`.

**This file is NOT auto-loaded** — the `load-memory` SessionStart hook injects `MEMORY.md` only.
Read it before editing anything under `ghostty/`; `.claude/rules/memory.md` carries that
trigger. Same rules as the active file's invariants: one line each, never archived, corrected in
place when they change and deleted when they stop being true.

Operational documentation — what each setting maps to and why — lives in the `ghostty` package's
own heavily-commented `config.ghostty`, and in CLAUDE.md's Ghostty section. This file is only the
traps.

---

## Config loading

- Ghostty reads its config **once, at process start**. New windows and tabs spawn from the same process and inherit the in-memory copy, so closing and reopening a *window* never picks up a file edit — the 2026-08-22 session burned ~20 minutes on exactly this. `cmd+shift+,` (`reload_config`, a default bind) re-reads in place and is the fix.
- On macOS, closing the last window is **not** quitting the app, which is why "I restarted it several times" can be true and still leave a 20-minute-old config loaded. Check with `ps -o lstart= -p <pid>` against the config mtime — process older than the file is the whole diagnosis.
- `window-width`/`window-height` apply only to **newly created** windows; a `reload_config` will not resize the current one. Font, theme, padding and keybinds do apply live.
- Config file is `~/.config/ghostty/config.ghostty`. Bare `config` (the pre-1.3 name) still loads in 1.3.1 — both tested with an isolated `XDG_CONFIG_HOME` — but the docs and `man 5 ghostty` specify `config.ghostty`, so use that.
- macOS **also** reads `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` and searches it **before** the XDG path. A 0-byte file lives there from Ghostty's first launch and is harmless, but anything written into it silently outranks the stow-managed file. One source of truth: leave it empty.
- Ghostty does **not** log to unified logging by default (`log show --predicate 'processImagePath CONTAINS "Ghostty"'` returns nothing), and running `/Applications/Ghostty.app/Contents/MacOS/ghostty` while an instance is alive just hands off to it and exits 0 with empty output. Neither is a way to debug config loading — use `ghostty +validate-config` and `ghostty +show-config` (which prints only non-default values).
- `quit-after-last-window-closed = true` is set for kitty parity (`macos_quit_when_last_window_closed yes`). It means closing the last window really does quit the app — fatal to a Claude Code session hosted in that window, which kitty never was.

## Porting from kitty.conf

- `font-codepoint-map` **inverts** kitty's `symbol_map` argument order: `<ranges>=<family>`, not `<ranges> <family>`. The comma-separated range list must stay on one line.
- kitty's two-value `window_padding_width 0 5` is *vertical horizontal* — so `window-padding-y = 0`, `window-padding-x = 5`, easy to transpose.
- `adjust-cell-height` is a **delta** from natural height, whereas kitty's `adjust_line_height 100%` meant "natural height". The correct translation is to leave it unset, not to write `100%`.
- `shell-integration-features` **merges** with the defaults rather than replacing them — verified via `+show-config`, which still reported `no-sudo,no-ssh-env,no-ssh-terminfo` when only `no-cursor` was listed. Name just what you want to flip.
- `hide_window_decorations titlebar-only` needs **two** keys: `window-decoration = auto` (kept ON) plus `macos-titlebar-style = hidden`.
- No Ghostty equivalent exists for: `cursor_trail`/`_decay`/`_start_threshold` (the one visible feature lost in the port), `cursor_blink_interval`, `cursor_stop_blinking_after`, `repaint_delay`, `input_delay`, `draw_minimal_borders`, `window_margin_width`, `enabled_layouts`. Ghostty writes cmd as `super`.
- Most of kitty's hand-written binds are already Ghostty defaults (`super+w/d/shift+d/t/k`), and `--cwd=current` is unnecessary — `split-inherit-working-directory` and `tab-inherit-working-directory` both default true. Only `ctrl+hjkl` → `goto_split` needed declaring. Check with `ghostty +list-keybinds --default`.

## Themes

- Ghostty's bundled **"Gruvbox Material Dark" is the MEDIUM variant** (background `#282828`, palette 3 `#d8a657`, palette 8 `#7c6f64`), not the hard one this repo uses everywhere. The hard variant is a local `ghostty/.config/ghostty/themes/Gruvbox Material Dark Hard`, translated 1:1 from the kitty conf.
- `~/.config/ghostty/themes/` is searched **before** the app's bundled themes, so a local file wins even when the names are similar. `theme = <name>` matches the filename exactly; spaces are fine and are what Ghostty itself ships.
- Palette 3 must stay `#e78a4e` — the same orange as JankyBorders' `active_color` and SketchyBar's `$ACCENT`. Background `#1d2021` matches the SketchyBar bar background. The bundled theme's `#d8a657` would desync all three.
- Ghostty's bundled **"Everforest Dark Hard" is genuine Everforest** (`#1e2326`), so the Everforest revert is a one-line `theme =` with no file. Note kitty's own `Everforest Dark Hard.conf` is *not* — kitty's theme picker overwrote its contents with the Gruvbox Material palette while keeping the filename, so CLAUDE.md's "Everforest kept on disk but inactive" is false for kitty.
