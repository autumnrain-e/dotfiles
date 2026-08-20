# Dotfiles Memory — Archive

Overflow from `.claude/memory/MEMORY.md`, per the archiving rules in the `memory-log` skill.
Never read automatically; kept only for manual review.

Two kinds of content live here, under separate headings: Session History blocks aged out by the
4-entry cap or by the size ceiling, and Decisions Log entries that were superseded or that
recorded a one-off change which has fully shipped. Archived decisions are stored **verbatim**.

---

## Decisions Log — Archived

*Relocated 2026-08-20 to stay under the 8,900-char ceiling. Fully shipped (user signed off 2026-08-19); cycle behaviour is in CLAUDE.md's Doom logo section. Verbatim.*

[2026-08-19] DECISION: Logo cycles `assets/doom/<N>_*/doom_guy_*.png` — 5s/frame, last frame of a folder holds 180s, then next folder, wrap after 4. `--reload` wipes `$TMPDIR/sketchybar_doom.state` → 0/0. Ghost/geometry unchanged; `doom.png` is revert-only.
              REASON: HUD look-around, then a long pause, then the next damage set. One file per frame so the image cache swaps.
              REJECTED: (1) Random every minute — first ask. (2) CPU-load faces — not requested. (3) Color-key only — beige halo; 1px erode cleared it. (4) Overwriting one `doom.png` — cache ignores the write.

*Relocated 2026-08-14 (late) to make room for the app-chip decision under the 8,900-char ceiling. Both are fully-shipped one-off chip changes, documented in CLAUDE.md's SketchyBar section; the structural fact behind the clock entry (a stacked chip REQUIRES a bracket, because items draw in add order) already survives as an invariant in `MEMORY-sketchybar.md`. Verbatim.*

[2026-08-10] DECISION: SketchyBar left logo is `ICON_GHOST` (nf-md-ghost U+F02A0), not the previous coffee cup; workspace `SPACE_GAP=2` (4px visible between chips).
              REASON: Ghost reads cleaner on the bar than nf-md-coffee; coffee had been kept only to match starship. `SPACE_GAP` 3→2 (visible 6→4) looks tighter without the chips touching — confirmed live after reload.
              REJECTED: (1) Keeping coffee for starship parity — bar and prompt no longer need a shared mascot. (2) `SPACE_GAP=3` — too loose once the ghost was in. (3) `nf-md-ghost-outline` — solid glyph preferred on sight.

[2026-08-10] DECISION: The clock chip is two centred lines — date over time (`Mon 10 Aug` / `11:07 AM`) — beside the 16pt calendar glyph, wrapped in a `clock.group` bracket in its own `items/clock.sh`.
              REASON: One line spent the chip's width on a string that reads fine stacked, and stacking buys room for a 12-hour AM/PM clock. The bracket is structural, not cosmetic: it is the only way to fill *behind* an overlaid `width=0` line. Both formats are fixed-length, so one pinned 72px label width holds the box still and centres the lines on each other.
              REJECTED: (1) No bracket, `clock.time` owning the box — add-order draw painted over the date. (2) Regular-weight date — washed out, and would be the bar's only non-bold label. (3) A 14pt icon — the calendar glyph's day-cell grid mushes. (4) No glyph at all — shipped that way first, the icon won on looks.

*Relocated 2026-08-14 to stay under the 8,900-char ceiling. Fully shipped: the Brewfile carries `felixkratz/formulae/borders` and CLAUDE.md documents the deliberate kitty exception, which also survives as an invariant in the active file. Verbatim.*

[2026-08-10] DECISION: `borders` is added to the Brewfile as `felixkratz/formulae/borders`; kitty stays a manual curl install and stays out of it.
              REASON: borders was brew-installed but never dumped, so a fresh machine ran AeroSpace's `after-startup-command` against a missing binary. kitty is the opposite case — the curl installer is the route upstream supports, and the cask would have to take over `/Applications/kitty.app` from it. The gap is now documented in CLAUDE.md instead of being an oversight.
              REJECTED: `cask "kitty"` — version parity was not the objection (installed and cask were both 0.48.2), the uninstall-and-adopt dance and diverging from upstream were.

*Relocated 2026-08-10 to reclaim room. Standing policy, fully shipped, and stated in CLAUDE.md's
kitty/WezTerm and Fastfetch sections — the hard dependency is fastfetch's animated `fma.gif`
rendering through kitty `icat`. Verbatim.*

[2026-08-07] DECISION: Keep kitty as the default terminal; keep the `wezterm/` package on disk as a documented inactive fallback.
              REASON: Hard dependency on kitty's graphics protocol — fastfetch's animated `fma.gif` renders through kitty `icat`, and WezTerm implements only parts of that protocol without the animation frame extensions. Yazi's image previews lean on it too.
              REJECTED: Switching to WezTerm — its wins (SSH/TLS multiplexing, Lua config) do not apply here: the multiplexer is unused and `kitty.conf` is adequate. Reconsider if persistent remote sessions without tmux become a need.

*Relocated 2026-08-10 to reclaim room under the 8,900-char ceiling. All three fully shipped. The
cpu-cluster entry is also superseded on its own terms: it was logged "on trial" and the user
accepted it this session, so the trial framing no longer describes reality — the replacement
decision for the wifi chip in the active file records the acceptance. The facts worth keeping (the
CoreText style-fallback trap, the Location-Services SSID gate, the iostat sampling quirk) all
survive as invariants in the active file. Verbatim.*

[2026-08-07] DECISION: SketchyBar text font → Helvetica (`Regular`/`Bold`), every label bold; family style names lifted into `$FONT_TEXT_REGULAR`/`$FONT_TEXT_BOLD` beside `$FONT_TEXT`.
              REASON: The hardcoded `:Bold:` in front_app.sh/spaces.sh matched no Berkeley Mono face, so those two items had silently rendered Helvetica since the package was written. Pairing each family with its real style names makes a future font swap fail visibly instead of silently. Helvetica was then picked deliberately over the alternatives on looks.
              REJECTED: Berkeley Mono `Bold Condensed` (Bold face installed this session, verified resolving) and Fira Code (no Bold on disk). Both compared live via screenshots. Diverges from the Berkeley Mono typography CLAUDE.md documents for kitty/nvim — update that.

[2026-08-07] DECISION: Recover the Wi-Fi SSID by decoding `SSID_STR` from the hex `CachedScanRecord` NSKeyedArchiver blob under `State:/Network/Interface/<if>/AirPort` in `scutil`, tried only after `networksetup` and `ipconfig`.
              REASON: Those two are Location-Services-gated; the cached scan record is not. Keeping them first means the plugin upgrades itself if the grant ever becomes possible, and the blob being undocumented is contained by falling through to a generic "connected" label.
              REJECTED: (1) `sudo wdutil info` — works, but needs a NOPASSWD sudoers entry for a cosmetic label. (2) Signed app bundle with `NSLocationUsageDescription` — the sanctioned route, absurd weight for one label. (3) Just showing "connected" — discards information that is recoverable.

[2026-08-08] DECISION: Replaced the cpu chip with FelixKratz's graph cluster (`items/cpu.sh` + `plugins/cpu_graph.sh`) — user/sys graphs, percentage, busiest-process caption, in one bracket. Old chip commented out in `status.sh`; `plugins/cpu.sh` untouched.
              REASON: On trial — kept trivially revertible because the user may not like it. A bracket is correct here (unlike the workspace chips) since the four items genuinely are one element.
              REJECTED: (1) Porting upstream's compiled mach helper — a build step and a vendored binary, which this repo deliberately avoids for sketchybar/borders. (2) `top -l 2 -n 0` as the sampler — measured at ~0.57s CPU per sample vs ~0.00s for `iostat`; ~30% of a core to draw a CPU meter.

*Relocated 2026-08-08 to reclaim room under the 8,900-char ceiling. Fully shipped; the two facts
worth keeping (brackets draw ONE box behind several items; the Berkeley-Mono-vs-Helvetica style
trap) both survive as invariants in the active file. Verbatim.*

[2026-08-07] DECISION: Restyled the SketchyBar left cluster — Apple logo → coffee glyph (U+F0176 nf-md-coffee, matching starship) in `$YELLOW`; `$GROUP_BG` chips behind the logo, each workspace, and front_app; bar to 20% alpha via `BAR_BG=0x331d2021`.
              REASON: Reuses the exact vars the right-hand status bracket already uses, so the whole bar retints from `colors.sh` together. `BAR_BG` was decoupled from `BG0` because `aerospace.sh` uses `BG0` as the focused-workspace digit color, where alpha would wash it out.
              REJECTED: (1) `blur_radius=30` behind the translucent bar — tried live, disliked, reverted. (2) A bracket around the workspace chips — brackets draw ONE box behind several items; these need separate boxes. (3) Hardcoding `#D8A657` — already `$YELLOW` in colors.sh.

*Relocated 2026-08-07 (midday) to reclaim room under the 8,900-char ceiling. Both record one-off
changes that have fully shipped, and the one-lifecycle-owner rule they establish is documented in
CLAUDE.md's Workflow Rules. Verbatim.*

[2026-08-04] DECISION: Added a `borders/` stow package (executable `bordersrc`) and launch JankyBorders from AeroSpace via `after-startup-command = ['exec-and-forget borders']`, with no CLI arguments.
              REASON: Bare `borders` reads `bordersrc`, so all appearance lives in one version-controlled file, and borders starts with the WM and inherits its accessibility permissions (enabling the more compatible `ax_focus` path).
              REJECTED: (1) `brew services start borders` — a second independent lifecycle for a daemon only useful alongside the WM. (2) Inlining options in `after-startup-command` (the README's example) — puts appearance config in the WM file and makes runtime `borders <opt>=<val>` tweaks diverge from the persisted config.

[2026-08-05] DECISION: Added a `sketchybar/` stow package (bash: `sketchybarrc` + `items/` + `plugins/` + `colors.sh` + `icons.sh`), launched from AeroSpace's `after-startup-command` with the absolute path `/opt/homebrew/bin/sketchybar`.
              REASON: Extends the [2026-08-04] one-lifecycle-owner rule to the second WM-adjacent daemon. Absolute path because that exec environment has no Homebrew in PATH.
              REJECTED: (1) `brew services` — same reason as borders. (2) Lua config via FelixKratz/SbarLua — needs building a Lua module from source and breaks on sketchybar upgrades; bash is dependency-free and matches the `bordersrc` precedent.

*Relocated 2026-08-07 during the memory-protocol migration. The four `2026-05-29` entries record
one-off changes that have fully shipped; the `2026-08-07` entry was superseded by the migration
itself. All five are verbatim.*

[2026-05-29] DECISION: Switched the active Neovim colorscheme from Everforest Dark Hard to Gruvbox Material (`sainnhe/gruvbox-material`), configured with hard background, italics off, and transparent background level 2.
              REASON: User requested the change to Gruvbox Material.
              REJECTED: Deleting `everforest.lua` (the nvim-colorscheme skill's default) — user explicitly asked to keep all other colorscheme files. Instead, `everforest.lua` was made `lazy = true` and its `vim.cmd("colorscheme ...")` call removed so only one theme is active and there is no conflict.

[2026-05-29] DECISION: Added `mason-org/mason-lspconfig.nvim` with an `ensure_installed` list (cssls, emmet_ls, html, lua_ls, taplo, ts_ls, yamlls) to `nvim/plugins/mason.lua`.
              REASON: After the Neovim 0.11→0.12 upgrade, no language servers were installed (Mason bin/ only had shfmt/stylua/tree-sitter), so `vim.lsp.enable(...)` in lsp.lua failed to spawn servers → `_transport.lua:68` "not executable" error, no diagnostics/intellisense. CLAUDE.md claimed servers were "auto-installed via Mason" but nothing actually wired that up. mason-lspconfig's ensure_installed makes it true and reproducible on fresh installs. Verified: lua_ls attaches and diagnostics/intellisense work.
              REJECTED: (1) Migrating to Neovim 0.12's built-in vim.pack — the guide's author explicitly recommends LazyVim users NOT migrate (no clean 1:1 path); the bug was missing binaries, not the plugin manager. (2) Manual one-off `:MasonInstall` only — not reproducible on a fresh machine. Did run it once to unblock immediately, but kept the declarative ensure_installed as the durable fix.

[2026-05-29] DECISION: Removed the `$schema` header lines and the entire `[plugin]` block (fetchers/spotters/preloaders/previewers) from `yazi/.config/yazi/yazi.toml`, and the `$schema` header from `keymap.toml`.
              REASON: Yazi 26.5.6 (current Homebrew build, a breaking release) refused to start — `"$schema"` is no longer an accepted top-level key ("must be a kebab-cased string"), and `[plugin]` fetchers now require a `group` field. The config was a near-verbatim copy of an older Yazi's default file, so every breaking change broke it. Yazi merges user config over built-in defaults, so the `[plugin]` block was 100% default duplication — removing it loses nothing and stays upgrade-proof. Verified `yazi --version` starts cleanly.
              REJECTED: (1) Adding `group` fields / hand-patching each broken default entry — fragile, would break again on the next release. (2) Keeping the full default config — that is the root cause of the breakage. Keep only genuine overrides.

[2026-05-29] DECISION: Documented Yazi's active flavor as `gruvbox-material` in CLAUDE.md (previously `everforest-medium`), with the `[filetype]`/`[icon]` green overrides noted as commented-out/inactive.
              REASON: The live `theme.toml` had drifted to `gruvbox-material` (matching the Neovim colorscheme switch) with the directory-green overrides commented out, but CLAUDE.md and lessons still described everforest-medium as active. Docs now match reality.
              REJECTED: Reverting theme.toml back to everforest-medium to match the docs — the gruvbox-material choice is intentional and consistent with the Neovim theme; the docs were stale, not the config.

[2026-08-07] DECISION: Tightened the memory protocol's Session History cap from 6 entries to 3, and raised the active-file size target from ~150 lines / 5 KB to ~250 lines / 20 KB. Archived the 2026-05-29 block to `MEMORY_archive.md`.
              REASON: MEMORY.md had reached 162 lines / 20.5 KB — 4× the old 5 KB target — and the overage was structural, not verbosity. The Decisions Log is append-only and keep-forever by design, so at ~1 KB per entry it alone passes 10 KB around the tenth decision, making 5 KB unreachable no matter how terse the sessions are. Only Session History is compressible, so the cap is the lever that actually works; the target now reflects what the design can achieve.
              REJECTED: Splitting the Decisions Log into a separate `DECISIONS.md` — cleanest on paper and keeps both halves genuinely small, but it means editing `.claude/rules/memory-protocol.md` structure plus the `@` include in CLAUDE.md, and it separates the decisions from the sessions that reference them by date. Revisit if the Decisions Log alone passes ~20 KB.

*Relocated 2026-08-07 (evening) to bring MEMORY.md back under the 8,900-char ceiling — it had
reached 8,829. All four record one-off changes that have fully shipped and are documented in
CLAUDE.md; their durable facts were promoted to `## Invariants & Gotchas` in the same edit.
Verbatim.*

[2026-08-05] DECISION: Added `cask "font-symbols-only-nerd-font"` to the Brewfile and corrected CLAUDE.md's font claim.
              REASON: `kitty.conf` maps its whole symbol range to "Symbols Nerd Font Mono", but no Nerd Font was installed. Kitty falls back silently with no error, so the gap went unnoticed; sketchybar's icons would have rendered as tofu. The glyphs-only cask is the minimal fix and is exactly the family kitty already references.
              REJECTED: (1) A fully-patched Nerd Font as primary — would displace Berkeley Mono, the deliberate primary typeface. (2) Emoji/ASCII labels in sketchybar — inconsistent with the rest of the setup.

[2026-08-07] DECISION: Commented out the `f = ['layout floating tiling', 'mode main']` service-mode binding in aerospace.toml, with an explanatory block for future re-enabling.
              REASON: Likely cause of "new kitty window covers the old instead of tiling right" — the existing window was `floating`, so the workspace had zero tiled nodes and the new window filled it. Removing the toggle removes the footgun; recovery is `aerospace layout tiling`.
              REJECTED: (1) Commenting out the whole `alt-shift-semicolon` service-mode entry — would also lose `esc` (reload-config) and `r` (flatten-workspace-tree). (2) An `on-window-detected` rule pinning kitty to tiling — verified a no-op.

[2026-08-07] DECISION: Use AeroSpace's `alt-h`/`alt-l` for cross-window focus instead of macOS's "Move focus to next window" (Hyper+N).
              REASON: The macOS shortcut cycles one kitty window then dead-ends permanently, while working indefinitely in Helium. AeroSpace's focus is spatial and app-agnostic, so it behaves identically everywhere.
              REJECTED: (1) Binding `focus --wrap-around dfs-next` to the same chord — the system swallows the keystroke first, so it would also need unbinding in System Settings. (2) Mapping kitty's `next_os_window` — keeps focus handling app-specific.

[2026-08-07] DECISION: Migrated to the standardized memory-protocol layout — `.claude/rules/memory.md` (trigger) + `memory-log` skill (write procedure) + a `load-memory` SessionStart hook + `autoMemoryEnabled: false`; MEMORY.md moved to `.claude/memory/`. Supersedes the cap-3 / 20 KB entry, archived verbatim.
              REASON: The old `@`-import double-loaded the protocol (`.claude/rules/*.md` already auto-loads) and did not survive `/compact`; the hook does. Budget is now ≤8,900 chars — the hooks reference caps hook output at 10,000 characters, so the old 20 KB target would have silently stopped injecting while still reporting `success`.
              REJECTED: Trusting the runbook's 2026-08-06 field measurement (24,358 B injected fine) over the documented cap — the conflict is unresolved, so budget under the stricter number.

*Relocated 2026-08-07 (late) to reclaim room under the 8,900-char ceiling. Both record one-off
changes that have fully shipped, and both are already documented operationally in CLAUDE.md —
the workspace-event wiring under SketchyBar's "AeroSpace integration" bullet, and the gap value
under "Bar height vs. gaps". Only the REJECTED reasoning was unique to these entries. Verbatim.*

[2026-08-05] DECISION: Drive SketchyBar's workspace indicators from AeroSpace's `exec-on-workspace-change` hook firing a custom `aerospace_workspace_change` event, enumerating workspaces via `aerospace list-workspaces --all`.
              REASON: AeroSpace workspaces are not macOS Spaces, so sketchybar's built-in `space_change` event never fires. Enumerating at config time means the bar follows `persistent-workspaces` with no duplicated list to keep in sync.
              REJECTED: (1) Hardcoding workspaces 1-5 — silently wrong the moment persistent-workspaces changes. (2) Polling `--focused` on an `update_freq` — wasteful and visibly laggy versus the event.

[2026-08-05] DECISION: Set `gaps.outer.top = 47` (39px bar + 8px) with a full-width bar at `position=top` and the macOS menu bar set to auto-hide.
              REASON: AeroSpace does not treat the sketchybar window as reserved screen space, so without a matching top gap tiled windows sit underneath it. 8px matches the existing inner gaps.
              REJECTED: (1) Keeping the macOS menu bar visible — sketchybar's right cluster collides with the menu bar extras. (2) Floating/rounded bar via `margin`+`y_offset` — kept commented out in `sketchybarrc` (needs `gaps.outer.top ≈ 55`); full-width is better-tested.

*Relocated 2026-08-10 (late) to reclaim room for the clock-chip and per-monitor-gap entries.
Fully shipped and accepted, and documented operationally in CLAUDE.md's SketchyBar "Wi-Fi cluster"
bullet. The facts worth keeping (the `netstat -bnI` sampling recipe, the pinned-width clipping
rule, the `mouse.exited.global` trap, padding being inert on a bracket) all already stand as
invariants in the active file. Verbatim.*

[2026-08-10] DECISION: Wi-Fi chip shows a two-line up/down throughput readout (red dot = upload, blue = download) with the SSID moved into a click-opened popup; the cpu cluster is accepted off trial. Both clusters get their gaps from empty `*.gap.left`/`*.gap.right` items.
              REASON: The SSID spent the chip's entire width on a string that changes twice a day, and resolving it costs a `scutil` + python3 fallback — so `plugins/wifi_ssid.sh` now runs from `click_script` only, not every 2s. Throughput is the thing actually worth a glance.
              REJECTED: (1) Arrow glyphs instead of dots — pre-wired in `icons.sh` as `ICON_UPLOAD`/`ICON_DOWNLOAD`, dots preferred on looks. (2) Keeping the SSID as the label. (3) Every padding route for the gaps — all measured as no-ops on a bracket.

---

## Session History — Archived

*Aged out 2026-08-19: not by the 4-block cap but by the size ceiling after the
doom-cycle write. Verbatim.*

## Session — 2026-08-17 — Excel app glyph
### Worked On
- Front_app icon for Microsoft Excel.
### Completed
- `Microsoft Excel`/`Excel` → U+F138F.
### In Progress (with next step)
- Carried: `config.fish.bak.*`; reboot-verify daemons; media.
### Decisions Made
- None. Cmap trap in MEMORY-sketchybar.
### Next Session Priorities
1. Drop stray `config.fish.bak.*` before stow.
2. Reboot-verify sketchybar + borders.
3. More app glyphs; media; volume %.

## Session — 2026-08-14 — 18pt app-chip glyph
### Worked On
- Bumped only the focused-app Nerd Font glyph to 18pt; left the 28px box and bar default at 16pt.
### Completed
- `APP_ICON_SIZE=18.0` on `front_app.icon`; confirmed live via `--query` (`18.00` / width 28).
### In Progress (with next step)
- Carried: stray `config.fish.bak.*`; reboot-verify sketchybar + borders autostart; media chip / volume % label.
### Decisions Made
- [2026-08-14] 18pt app-chip glyph; box and `--default` stay 28px / 16pt.
### Next Session Priorities
1. Deal with the stray `config.fish.bak.*` before it gets stowed.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Add app glyphs as new apps come up; `media` chip; volume % label.

*Aged out 2026-08-14: not by the 4-block cap but by the size ceiling after the
18pt app-glyph write. The Doom-logo decision stays in the active log. Verbatim.*

## Session — 2026-08-14 — Doom logo chip
### Worked On
- Replaced the ghost logo with a Doom-face image chip; matched both ends of the workspace row.
### Completed
- Ghost commented in `items/spaces.sh`; `assets/doom.png` (32px) + `doom-src.png` (512).
- `logo_separator` width=`SPACE_EDGE=8`; doom→1 and last-workspace→app both 10px (`bounding_rects`).
- Revert: uncomment ghost (`padding_right=0`), drop the doom `--add`, keep `logo_separator`.
### In Progress (with next step)
- Carried: stray `config.fish.bak.*`; reboot-verify sketchybar + borders autostart; media chip / volume % label.
### Decisions Made
- [2026-08-14] Doom face logo; `SPACE_EDGE` spacers at both ends of the workspace row.
### Next Session Priorities
1. Deal with the stray `config.fish.bak.*` before it gets stowed.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Add app glyphs as new apps come up; `media` chip; volume % label.

*Aged out 2026-08-14: not by the 4-block cap (only 2 blocks) but by the size
ceiling — the active file measured 9,409 chars against the 8,900 limit after the
Doom-logo write. The two-tone front_app decision stays in the active log. Verbatim.*

## Session — 2026-08-14 (late) — Two-tone app chip
### Worked On
- Rebuilt the front_app chip as an icon box + name box, with per-app Nerd Font glyphs.
### Completed
- `front_app` split into `front_app.icon` (accent box, `$BG0` glyph, pinned 28px) + `front_app.name`; `APP_SEAM_GAP=2` sits wholly on the icon half so the constant IS the visible gap.
- 11 `ICON_APP_*` glyphs appended to `icons.sh` via Python escapes, each codepoint byte-verified and checked against the font's cmap first.
- All 10 names driven through the real plugin plus the unmapped fallback; seam confirmed at 2px by `bounding_rects` AND pixel scan. Redundant per-item geometry dropped; CLAUDE.md updated.
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; media chip / volume % label.
- Still uncommitted from earlier: `completions/grok.fish`, `fish_variables`, and the untracked `config.fish.bak.1786030770` that `stow` would link into `~/.config/fish/`.
### Decisions Made
- [2026-08-14] two-tone front_app chip, two plain items, seam on the icon half.
### Next Session Priorities
1. Deal with the stray `config.fish.bak.*` before it gets stowed.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Add app glyphs as new apps come up; `media` chip; volume % label.

*Aged out 2026-08-14 (late): not by the 4-block cap (only 2 blocks) but by the size
ceiling — the active file measured 9,007 chars against the 8,900 limit after the app-chip
write, with both decision entries already inside the ~800-char budget. Verbatim.*

## Session — 2026-08-14 — RAM chip added, battery hidden
### Worked On
- New SketchyBar RAM chip; hiding battery; right-cluster reading order.
### Completed
- `items/ram.sh` + `plugins/ram.sh` (percent used, vm_stat sampler, AQUA icon escalating at 65/80/90); four glyphs trialled live before settling on nf-cod-circuit_board, each written via Python escape and byte-verified.
- `battery` item commented out in `items/status.sh`; `plugins/battery.sh` untouched, revert is one uncomment.
- Order now `media | cpu | ram | wifi | volume | clock`; verified by `bounding_rects` — all four gaps still exactly 6px — plus a screenshot.
- CLAUDE.md SketchyBar section updated (order line, RAM chip, hidden battery).
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; media chip / volume % label.
- Uncommitted from before this session: modified `completions/grok.fish` + `fish_variables`, and an untracked `fish/.config/fish/config.fish.bak.1786030770` that `stow` would link into `~/.config/fish/`.
### Decisions Made
- [2026-08-14] plain `ram` chip in its own file; battery commented, not deleted.
### Next Session Priorities
1. Deal with the stray `config.fish.bak.*` in the fish package before it gets stowed.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Decide on a `media` chip; volume percentage label.

<!-- Most recent archived session first -->

*Aged out 2026-08-14 by the size ceiling, not the 4-entry cap: the RAM-chip session pushed the active file to 10,856 chars. Both fully shipped and documented in CLAUDE.md's SketchyBar and AeroSpace sections; their decision entries stay in the active log. Verbatim.*

## Session — 2026-08-10 — Ghost logo + tighter workspace gaps
### Worked On
- Left logo glyph and workspace chip spacing in SketchyBar.
### Completed
- `ICON_COFFEE` → `ICON_GHOST` (nf-md-ghost U+F02A0) via Python write; `spaces.sh` logo item updated; live after `sketchybar --reload`.
- `SPACE_GAP` 3→2 (visible gap 6→4px); kept after side-by-side look.
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; media chip / volume % label.
### Decisions Made
- [2026-08-10] ghost logo + `SPACE_GAP=2`.
### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Decide on a `media` chip; volume percentage label.

## Session — 2026-08-10 (late) — Two-line clock chip + per-monitor gaps
### Worked On
- Redesigning the date/time chip; WM/bar restart aliases; the oversized top gap on the laptop screen.
### Completed
- New `items/clock.sh` (date over time, calendar glyph, `clock.group` bracket) and `plugins/clock.sh` feeding both labels from one `date` call; old chip commented out in `status.sh`, revertible.
- Chip pixel-verified: 95px box, 8-10px insets, all four right-cluster gaps still 6px.
- AeroSpace + SketchyBar alias blocks in `config.fish` and `.zprofile`, both syntax-checked; `sbrestart` run-tested for a single instance.
- `gaps.outer.top` per-monitor: laptop window edge 77pt → 47pt. Re-docking the Dell picked the 47 fallback up on its own (user ran `asreload` too, so not cleanly isolated) — no per-screen editing either way.
- `borders` added to the Brewfile (it was brew-installed but never dumped); kitty stays out by choice.
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; media chip / volume % label.
### Decisions Made
- [2026-08-10] two-line clock chip; per-monitor top gap plus lifecycle aliases; `borders` into the Brewfile, kitty deliberately left out.
### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Decide on a `media` chip; volume percentage label.

*Aged out 2026-08-10 (late) at 98% of the 8,900-char ceiling, to keep headroom for the next
session. Fully shipped and accepted; its decision entry is archived above and the chip itself is
documented in CLAUDE.md's SketchyBar section. Verbatim.*

## Session — 2026-08-10 — Wi-Fi throughput chip + real chip gaps
### Worked On
- Wi-Fi chip redesign (two stacked rate lines + SSID popup); cpu and wifi chips rendering flush against each other.
### Completed
- `items/wifi.sh`, rewritten `plugins/wifi.sh` (netstat byte deltas), new `plugins/wifi_ssid.sh` (click only).
- Dots aligned by pinning identical `icon.width`/`label.width` on both lines; the 8-char rate cap is what holds the box at 52px.
- Chip gaps: four empty `*.gap.*` items, after all four padding routes measured as no-ops; every right-cluster gap pixel-verified at 6px.
- 2px nudge between wifi glyph and text stack, applied to the icon item so the two lines stay identical.
- CPU cluster accepted off trial; CLAUDE.md + lessons.md updated; 4 decisions and 1 session archived.
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; media chip / volume % label; kitty absent from Brewfile.
### Decisions Made
- [2026-08-10] Wi-Fi throughput chip, SSID popup, gap items, cpu cluster accepted.
### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Decide on a `media` chip; volume percentage label.
3. Add kitty to the Brewfile.

*Aged out 2026-08-10 (late) to make room for the clock-chip session block under the 8,900-char
ceiling. The cluster was accepted off trial on 2026-08-10; its decision entry is archived above.*

## Session — 2026-08-08 — CPU graph cluster
### Worked On
- Ported FelixKratz's cpu graph cluster into `items/cpu.sh` + `plugins/cpu_graph.sh`.
### Completed
- Four items in one bracket (two overlapping graphs, percent, busiest process); shell `iostat` sampler, no build step.
- `CPU_GRAPH_FULL_SCALE=60` rather than upstream's 100 — everyday load never left the bottom few pixels.
### Decisions Made
- [2026-08-08] cpu graph cluster (archived 2026-08-10 on acceptance).
### Next Session Priorities
1. Live with it for a day, then keep or revert.

*Aged out 2026-08-10 to make room for the 2026-08-08 and 2026-08-10 blocks under the 8,900-char
ceiling. Its SSID work has since been superseded — that chain now lives in `plugins/wifi_ssid.sh`
and runs on click only.*

## Session — 2026-08-07 (late) — SSID recovery + uniform chips
### Worked On
- Wi-Fi label rendering literal `<redacted>`; bar-wide font/geometry audit; status bracket split into per-item chips.
### Completed
- `wifi.sh`: sentinel guarded at every step, `CachedScanRecord` fallback added; real SSID renders.
- Icon size unified to 16pt from the `--default` block; logo's redundant per-item override dropped.
- `status.sh`: bracket → five chips (cpu/wifi/volume/battery/clock); all boxes verified 26px by pixel measurement, not by eye.
- Clock glyph → `nf-md-calendar_clock_outline` (U+F16E1), codepoint confirmed in the installed TTF before writing.
- Archived both 2026-08-05 decisions; headroom back to ~1.5k.
### In Progress (with next step)
- `media` is now the only bar text without a chip — two lines in `items/media.sh` if wanted.
- `ICON_CALENDAR` is unreferenced but deliberately kept as a palette entry.
- Carried: reboot-verify sketchybar + borders autostart; Obsidian float on ws1; kitty absent from Brewfile.
### Decisions Made
- [2026-08-07] SSID recovery via the `CachedScanRecord` fallback.
### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Decide on a `media` chip; volume percentage label.
3. Add kitty to the Brewfile.

*Aged out 2026-08-07 (late): the file exceeded the 8,900-char ceiling. Its font work is
still recorded in the active Decisions Log entry of the same date. Verbatim.*

## Session — 2026-08-07 (midday) — Bar font resolution
### Worked On
- Chased why SketchyBar's bold labels never looked like Berkeley Mono; compared Fira Code / Berkeley Mono / Helvetica live via screenshots.
### Completed
- Diagnosed the silent CoreText → Helvetica fallback with a CTFontDescriptor probe; `--query` had masked it all along.
- Style names lifted into `$FONT_TEXT_REGULAR`/`$FONT_TEXT_BOLD`; hardcoded `:Bold:` removed from front_app.sh + spaces.sh.
- Landed Helvetica; all status labels (cpu/wifi/volume/battery/clock) and media now bold via the `--default` block.
### In Progress (with next step)
- Uncommitted: sketchybarrc, front_app.sh, spaces.sh — commit next.
- CLAUDE.md still documents Berkeley Mono for sketchybar; needs updating.
- Carried: reboot-verify sketchybar + borders autostart; Obsidian float on ws1; kitty absent from Brewfile.
### Decisions Made
- [2026-08-07] SketchyBar font → Helvetica + style-name vars.
### Next Session Priorities
1. Commit the font change; update CLAUDE.md typography + SketchyBar sections.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Volume percentage label; Obsidian float; kitty Brewfile call.


*Aged out 2026-08-07 (midday) by the size ceiling, not the 4-entry cap; its open
items were carried into the midday block. Verbatim.*

## Session — 2026-08-07 (evening) — SketchyBar restyle
### Worked On
- Iterative visual restyle of the SketchyBar left cluster, one change at a time, verified live via `--query` after each.
### Completed
- Apple logo → coffee glyph U+F0176 in `$YELLOW`; `click_script` to System Settings preserved.
- Bar to 20% alpha (`BAR_BG=0x331d2021`); `blur_radius=30` trialled then reverted at user's call.
- `$GROUP_BG` chips on the logo, all 5 workspaces (focused stays `$ACCENT`), and front_app.
- Uniform 28px workspace chips via pinned `icon.width` + `icon.align=center`; `SPACE_GAP=3`, `LOGO_GAP=10`.
### In Progress (with next step)
- Carried: reboot-verify sketchybar + borders autostart; volume item still icon-only.
- Carried: Obsidian float on ws1; kitty missing from Brewfile.
### Decisions Made
- [2026-08-07] SketchyBar left-cluster restyle.
### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Resolve the Obsidian float; decide kitty Brewfile adoption.
3. Give the volume item a percentage label.

*Aged out 2026-08-07 (evening) by the size ceiling, not the 4-entry cap; its open
items were carried into the evening block. Verbatim.*

## Session — 2026-08-07
### Worked On
- Two AeroSpace/kitty window-management complaints; kitty vs WezTerm; memory-protocol migration.
### Completed
- Diagnosed "new kitty window covers the old" as a stray `floating` window, not a tiling defect; removed the service-mode `f` float toggle. Committed `4966c9d`.
- Traced the Hyper+N focus dead-end to kitty's patched-GLFW Cocoa layer; settled on `alt-h`/`alt-l`.
- Migrated the memory protocol to the runbook layout; archived 5 decisions and 2 session blocks.
### In Progress (with next step)
- Obsidian on workspace 1 still floating. Next: quit/reopen, re-check `window-layout`, add an `on-window-detected` rule only if it returns `floating` unprompted.
- kitty missing from the Brewfile. Next: decide `brew install --cask kitty --adopt` vs leaving it manual.
- Carried: reboot-verify sketchybar + borders autostart; volume item still icon-only.
### Decisions Made
- 4 × [2026-08-07]: float-toggle removal; `alt-h`/`alt-l` focus; keep kitty over WezTerm; memory-protocol migration.
### Next Session Priorities
1. Confirm the memory hook injects in a fresh session via `/context`.
2. Reboot-verify sketchybar + borders autostart, single instance each.
3. Resolve the Obsidian float; decide kitty Brewfile adoption; `.gitignore` for `cliamp/*.log` + `history.toml`.


## Session — 2026-08-05
### Worked On
- Installing SketchyBar and building a stow package for it, wired into AeroSpace.
- Diagnosing AeroSpace no longer tiling after the WM restart.

### Completed
- New `sketchybar/` package: `sketchybarrc`, `colors.sh`, `icons.sh`, 4 `items/`, 8 `plugins/` — all `100755`. Stowed. Bar: apple · workspaces · front_app | media · cpu · wifi · volume · battery · clock.
- `aerospace.toml`: sketchybar added to `after-startup-command` (absolute path), new `exec-on-workspace-change` hook, `gaps.outer.top` 8 → 47. `reload-config --dry-run` clean.
- Verified live: bar 39px/top, all item labels populate, workspace highlight follows focus (`space.2` icon `0xff1d2021` vs `space.1` `0xff928374` — proves the event chain).
- Brewfile: `felixkratz/formulae` tap + sketchybar + `font-symbols-only-nerd-font`.
- Fixed the tiling bug: workspace 1's root container was stuck in `h_accordion` (per-workspace runtime state, invisible in config) → `aerospace layout tiles horizontal vertical`. Also un-floated the Teams window.
- Docs: CLAUDE.md SketchyBar section + structure map + testing commands; lessons.md gained Fonts / AeroSpace / SketchyBar sections.
- Committed as `883213d` (21 files, +817/−3).

### Corrections to previously-documented claims
- **No Nerd Font was ever installed.** `kitty.conf:71` maps its whole symbol range to `Symbols Nerd Font Mono`, which was absent — CoreText fell back silently, so the gap went unnoticed for as long as that line existed.
- **"Borders exits with AeroSpace" was false.** The login-time `borders` (PID 1016) survived `killall AeroSpace` + relaunch. Restarting AeroSpace now requires `killall sketchybar borders` first, or the new launch is a no-op against a stale daemon.
- **A hotkey-registration theory for the tiling bug was wrong.** Hotkeys were fine the whole time; the accordion root layout was the entire defect. Recorded in lessons.md as a red herring to avoid.

### In Progress (with next step)
- Autostart still unverified across a real reboot (carried from 2026-08-04, now covering both daemons). Next step: after the next login, `pgrep -lf "sketchybar|borders"` and confirm each comes up exactly once without a terminal.
- Volume item renders icon-only: `osascript` returns `missing value` for output volume on the current audio device. Next step: press a volume key and confirm the label populates from the `volume_change` event.

### Decisions Made
- 4 × [2026-08-05] entries: sketchybar package + AeroSpace launch; workspace-indicator event wiring; `gaps.outer.top = 47` + menu-bar auto-hide; `font-symbols-only-nerd-font`.

### Next Session Priorities
1. Reboot-verify sketchybar + borders autostart, single instance each.
2. Decide `.gitignore` for `cliamp/*.log` + `history.toml`; decide whether `memory-upgrade.md` should be tracked.
3. Commit or discard the pre-existing fastfetch / fish / kitty / starship / wezterm edits.
4. Carried over: trim remaining `yazi.toml` default duplication; decide if the `everforest-medium` flavor dir stays on disk.

## Session — 2026-08-04
### Worked On
- Setting up JankyBorders (`borders` 1.9.0, already installed via Homebrew) and wiring it to autostart.
- Reconciling stale theme claims in CLAUDE.md.

### Completed
- New `borders/` stow package: executable `bordersrc` (round, width 5.0, hidpi off, active `0xFFE78A4E`, inactive `0xFFDDC7A1`). Stowed.
- `aerospace.toml:12` → `after-startup-command = ['exec-and-forget borders']`; `reload-config --dry-run` clean.
- Diagnosed "dies when I close the terminal": `borders &` is a shell child (SIGHUP); the hook had never fired since AeroSpace was already running. Stopgap: `nohup ... & disown`.
- CLAUDE.md: `borders`/`aerospace`/`yazi` added to structure map; new JankyBorders Details section; Testing Changes + workflow rule.
- CLAUDE.md theme fix: "Everforest across all tools" was stale for *every* tool — Kitty already includes `Gruvbox Material Dark Hard.conf` (kitty.conf:71). Font size 17pt → 18pt.

### In Progress (with next step)
- Autostart is wired but unverified end-to-end — the hook only fires on AeroSpace start. Next step: after the next login/reboot, run `pgrep -lf borders` to confirm it came up without a terminal. If not, swap line 12 to the absolute path `/opt/homebrew/bin/borders` (AeroSpace's exec PATH may not include Homebrew).

### Decisions Made
- [2026-08-04] `borders/` stow package + bordersrc + AeroSpace `after-startup-command` launch (brew services rejected).

### Next Session Priorities
1. Confirm borders autostarts after reboot; fall back to the absolute path if not.
2. Consider documenting the other undocumented stow packages in CLAUDE.md: `cliamp/`, `opencode/`, `raycast/`, and a real AeroSpace section.
3. Carried over: trim remaining `yazi.toml` sections that duplicate Yazi defaults; decide whether the `everforest-medium` flavor dir stays on disk.

## Session — 2026-05-29
### Worked On
- Fixed Yazi failing to launch on Yazi 26.5.6 (breaking release).
- Synced docs/lessons to the current Yazi `gruvbox-material` flavor.

### Completed
- Removed `$schema` header + `[plugin]` block from `yazi.toml`; removed `$schema` from `keymap.toml`. Verified `yazi --version` starts clean.
- Updated CLAUDE.md Yazi section + lessons to document gruvbox-material and the Yazi 26.5.6 config-compat lesson.

### In Progress (with next step)
- (none)

### Decisions Made
- [2026-05-29] Yazi 26.5.6 config compat (remove $schema + [plugin]).
- [2026-05-29] Document Yazi gruvbox-material flavor in CLAUDE.md.

### Next Session Priorities
1. Consider trimming the remaining `yazi.toml` sections that still duplicate Yazi defaults (keep only true overrides) for full upgrade-resilience.
2. Confirm the `everforest-medium` flavor dir is still wanted on disk or can be removed.
