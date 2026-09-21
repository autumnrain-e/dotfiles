# Dotfiles Memory

## Invariants & Gotchas

- **SketchyBar invariants live in `.claude/memory/MEMORY-sketchybar.md`** — geometry, brackets, `width=0` stacking, graphs, plugin sampling, pixel verification (split off 2026-08-10). NOT auto-loaded: read it before editing anything under `sketchybar/`.
- **Ghostty invariants live in `.claude/memory/MEMORY-ghostty.md`** — config read once at startup, the two config paths, kitty→ghostty translation traps, bundled-theme variants (split off 2026-08-22). NOT auto-loaded: read it before editing anything under `ghostty/`.
- **Neovim invariants live in `.claude/memory/MEMORY-nvim.md`** — LazyVim extras failures, Mason name mapping, image.nvim badge patch, font verification (created 2026-09-21 from the deleted `.claude/tasks/lessons.md`). NOT auto-loaded: read it before editing anything under `nvim/`.
- CLAUDE.md is structure + how-to-operate ONLY; reasons and traps live here and in the domain files, never copied into CLAUDE.md (the 2026-09-21 rewrite removed 17 KB that contradicted memory).
- kitty is a **manual install** (the `ku` alias = upstream `installer.sh`), deliberately not the cask and absent from the Brewfile, so `brew bundle install` + `stow` leaves a fresh machine with `kitty.conf` and no kitty. Ghostty **is** in the Brewfile (2026-08-22), so a fresh machine gets a terminal — just not that one.
- `brew install --cask --adopt <app>` takes ownership of an already-installed app **in place** when the versions match — no uninstall, the running app untouched — and cannot be combined with `--force` (which deletes and reinstalls). It also links artifacts a manual install misses (ghostty: man pages, fish completions).
- `brew bundle check` flags OUTDATED formulae with the same "needs to be installed or updated" line as missing ones, so its failure list is not an inventory of what the Brewfile is missing (79 outdated on 2026-08-10). Check an entry against `brew outdated`/`brew list` before believing it.
- kitty has been granted macOS Accessibility access; anything launched from a kitty window inherits it.
- AeroSpace `on-window-detected` rules never re-fire on an already-open window, so they cannot fix live runtime state (a float toggle, a stuck layout).
- AeroSpace per-workspace runtime state — root container `h_accordion`, per-window `floating` — is invisible in the config and is the usual cause of "tiling broke" — check `window-layout` via `aerospace list-windows` first.
- macOS "Move focus to next window" dead-ends after one hop in kitty: its patched-GLFW Cocoa layer never restacks `NSWindow`s and tiled windows never overlap, so the z-order list freezes. Use `alt-h`/`alt-l`.
- `~/.config/aerospace` is a tree-folded stow *directory* symlink (same inode) — repo edits are live, no re-stow needed.
- Nerd Font PUA glyphs must be written to config files via Python `\uXXXX` escapes — pasted glyphs are silently dropped or corrupted; `nf-md-*` glyphs above U+FFFF (e.g. U+F16E1) need the 8-digit `\U` form.
- "Symbols Nerd Font Mono" is required by kitty's `symbol_map` and every sketchybar icon, is **not** a system font, and kitty falls back silently with no error if it is missing. Cask: `font-symbols-only-nerd-font`.
- The hook-injected `MEMORY.md` must stay under **8,900 chars** — past that the harness silently substitutes a preview while the hook still reports `success`. Verify: `bash .claude/hooks/load-memory.sh | wc -m`. Domain files are read on demand and exempt.
- AeroSpace measures gaps from the monitor's VISIBLE frame, and a notched built-in display's ~30pt menu-bar reserve is already excluded from it — so a top gap stacks on top of that. Current bar is 32px, so the target is 40pt (32+8): `[{ monitor."built-in" = 10 }, 40]` (10+30=40 on the notch).
- Per-monitor gaps re-resolve on monitor hot-plug (re-docking restored the value untouched; an `asreload` also ran, not cleanly isolated). `aerospace reload-config` DOES apply gaps live. Only `after-startup-command` needs a real restart — and `open -a AeroSpace` on a running app merely activates it, so kill AeroSpace, sketchybar and borders first or the daemons stay dead.
- CoreText matches font style names EXACTLY; an unmatched style falls back to **Helvetica** silently, and `sketchybar --query` echoes the requested string, not the resolved font, so never reveals the swap.
- Berkeley Mono here is the *Condensed* cut — faces are `Condensed`/`Medium Condensed`/`Bold Condensed`; there is no plain `Bold`.
- kitty `launch --location=hsplit|vsplit` works only under `enabled_layouts splits` (set); the default `tall` layout ignores the hint silently. `vsplit` = left/right panes, `hsplit` = top/bottom.
- Yazi config = overrides only: 26.5.6 rejected a pasted full default (`$schema` key; `[plugin]` fetchers need `group`) and `yazi --version` shows the parse error. `use_lscolors` does not exist. `[filetype]` colours filename TEXT, `[icon]` the GLYPH — directories need both; `[icon] prepend_conds` needs `text` (U+E5FF via Python).
- `aerospace focus --window-id` moves focus to that window's OWN workspace, so `--workspace focused` then lists only it and other windows look "vanished" — use `list-windows --all`. `enable on --fail-if-noop` exits 2 silently; secure input blocks hotkeys — check `ioreg -l -d 1 -k IOConsoleUsers | grep kCGSSessionSecureInputPID`.
- Claude Code skills must be `.claude/skills/<name>/SKILL.md`; a flat `.claude/skills/<name>.md` is never loaded.

## Decisions Log

[2026-09-21] DECISION: Docs are layered — CLAUDE.md = structure + how to operate; memory = why, REJECTED alternatives, traps. `.claude/tasks/lessons.md` + the `update-lessons` skill deleted, facts folded into MEMORY.md, `MEMORY-sketchybar.md` and a new `MEMORY-nvim.md`; CLAUDE.md cut 33→19 KB, SketchyBar section rewritten for the flat bar.
              REASON: CLAUDE.md contradicted memory every session (39px/47pt vs 32px/40pt, Helvetica vs Noto) and lessons.md was a fourth gotcha store nothing loaded. One home per fact.
              REJECTED: Native Auto Memory instead (no decision log, no conflict flagging); a domain file per tiny package — kitty/yazi fit here.

[2026-09-21] DECISION: Native Auto Memory stays OFF, but the documented reason is now curation and structure, not portability; `memory-log` skill and `memory-upgrade.md` reworded.
              REASON: `autoMemoryDirectory` can point native memory inside a repo, so "machine-local, not shared via git" was disprovable and weakened the rule it defended.
              REJECTED: Enabling it aimed at `.claude/memory/` — a second, unstructured writer to the same truth.

[2026-09-15] DECISION: Python in Neovim is `basedpyright` + `ruff` (Mason `ensure_installed` and `vim.lsp.enable`) plus the `python` treesitter parser, declared in the existing plugin specs.
              REASON: Matches how the other languages are listed. basedpyright covers types/completion; ruff covers lint/format. Ruff hover is disabled so basedpyright owns `K`.
              REJECTED: pyright alone (no lint/format); pylsp; LazyVim `lang.python` extra (extras imports have already failed here for mini.icons and aerial).

[2026-08-22] DECISION: `ghostty` is a new stow package ported from `kitty.conf`, carrying its own `themes/Gruvbox Material Dark Hard` instead of Ghostty's bundled Gruvbox Material Dark. kitty stays the documented default; ghostty is additive.
              REASON: The bundled theme is the MEDIUM variant (`#282828`), and its palette 3 would break the accent orange shared with JankyBorders and SketchyBar. `~/.config/ghostty/themes/` is searched before app resources, so a local file wins on a similar name.
              REJECTED: (1) `theme = Gruvbox Material Dark` — wrong variant, desyncs three tools. (2) Replacing the kitty package — kitty's conf is untouched and still default. (3) One theme file shared by both terminals — formats differ (`color3` vs `palette = 3=`).

---

## Session History

## Session — 2026-09-21 — Docs layering, lessons fold
### Worked On
- Native Auto Memory vs this protocol; CLAUDE.md rewrite; lessons fold.
### Completed
- CLAUDE.md rewritten (structure/how-to only; flat-bar SketchyBar, Ghostty, AeroSpace, emacs/cliamp/raycast); README corrected.
- `MEMORY-nvim.md` created; lessons.md + `update-lessons` deleted; `update-claude-md`, `nvim-colorscheme`, `memory-log`, runbook fixed.
- `gc` deduped: gulp one is now `gclean` (fish + zsh); `cliamp/resume.json` gitignored; whole tree committed.
### In Progress (with next step)
- None.
### Decisions Made
- [2026-09-21] docs layering; [2026-09-21] native-memory rationale.
### Next Session Priorities
1. `opencode/`: add a theme or drop the package.
2. `kitty/.config/kitty/kitty-terminal.png` (1.1 MB, untracked, unreferenced): use in README or delete.
