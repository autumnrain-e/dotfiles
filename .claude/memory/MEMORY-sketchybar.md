# Dotfiles Memory — SketchyBar Invariants

Domain split off `.claude/memory/MEMORY.md` on 2026-08-10, per the `memory-log` skill: the
SketchyBar invariants alone had grown to ~4,400 chars of an 8,900-char budget, ~63% of the
Invariants section, and the programme keeps producing more every session.

**This file is NOT auto-loaded** — the `load-memory` SessionStart hook injects `MEMORY.md` only.
Read it before editing anything under `sketchybar/`; `.claude/rules/memory.md` carries that
trigger. Same rules as the active file's invariants: one line each, never archived, corrected in
place when they change and deleted when they stop being true. Entries below are verbatim from
`MEMORY.md`.

Operational documentation — what each chip is and how to reload the bar — lives in CLAUDE.md's
SketchyBar section, not here. This file is only the traps.

---

## Chip geometry & spacing

- sketchybar chip geometry (`background.corner_radius`/`height`) belongs ONLY in the `--default` block; items set just `background.color` + `background.drawing=on`. Re-specifying per item is how boxes silently drift out of alignment.
- sketchybar: item-level `padding_left/right` is the gap OUTSIDE an item's background box; `icon.padding_*`/`label.padding_*` sit inside it and stack with `icon.width`. Chips that visually touch need item padding, not icon padding.
- sketchybar a pinned item `width=N` swallows that item's own `padding_left/right` for layout: the next item is placed at origin+N, not origin+N+padding. Dynamic width (query shows `-1`) still honours padding. The logo hit this — `width=35` ate `LOGO_GAP=10`; space it with a non-drawing spacer (`logo_separator`) instead.
- sketchybar `label.width`/`icon.width` CLIP rather than grow, so pin them only against a formatter whose output width is capped. `bounding_rects` excludes an item's padding, so rect widths won't match your padding arithmetic.
- sketchybar sizes an icon slot from measured glyph extents, not the font's advance width — even in monospace Berkeley Mono, `1` renders ~3px narrower than `2`. Pin `icon.width` + `icon.align=center` for uniform chips.
- Verify chip gaps by pixel, never by eye or by an upscaled screenshot: two touching chips read as ONE merged run of their combined width. Downsample a retina capture exactly once (`-resize WxH!`) — upscaling then downsampling blurs edges out of the exact-colour test and invents 3px errors.

## Brackets & stacking

- A sketchybar BRACKET cannot be spaced by padding — its own `padding_*` is ignored (reports `null`), its members' padding is swallowed into the box, and `background.padding_*` does nothing. All four routes measured. Space a cluster with a NON-member item: `width=3`, every `drawing=off`, added first in the file for its right edge / last for its left. A member's padding buys no INNER margin either (8/8 vs 20/20 both left the box at exactly `label.width`, unmoved) — the inset has to be slack in a pinned `label.width`/`icon.width`.
- sketchybar brackets draw ONE box spanning several items — right when the items are genuinely one element (the cpu cluster), wrong when they merely sit adjacent (workspace chips, which each need their own box). A multi-COLOR chip therefore rules a bracket out entirely (the front_app icon/name pair): one box cannot be two colors, so those must be plain items, which in turn makes item padding the correct way to space them.
- sketchybar items are DRAWN IN ADD ORDER, so a stacked chip REQUIRES a bracket: the box-owning member is necessarily added after the `width=0` overlay, and its opaque background paints straight over it. A bracket draws beneath all of its members, which is the only way round it.
- sketchybar `width=0` is the stacking primitive: the item takes no space AND never advances the layout cursor, so the next item overlaps it. Such an item's label is right-anchored and extends LEFT, so add it BEFORE the item it should overlay; its `padding_right` then shifts only itself.
- sketchybar `label.y_offset` shifts the text without moving the item's own background; item `y_offset` moves both. Stack two lines with item offsets when a bracket owns the box, label offsets when the item does.
- sketchybar `graph` items take width as a POSITIONAL arg to `--add`, are fed `--push <name> <0.0-1.0>` (fraction, not percent), and plot inside their background rect — so `background.drawing=on` is mandatory and `background.height` is the plot height.

## Items, events & queries

- `sketchybar --reload` is ASYNCHRONOUS: a plugin invoked on the next line fails with `[!] Set: Item not found`. Sequence it as a separate call.
- sketchybar `--query <item>` nests `click_script`/`script` under `.scripting` and `bounding_rects` at top level — not under `.geometry`; `icon.font`/`label.font` are flat `Family:Style:Size` strings, not objects. The item's OWN background is the mirror image: it IS under `.geometry.background`, so a top-level `.background.color` reads `null` and looks like the item has no box when it does.
- The name sketchybar reports in `$INFO` on `front_app_switched` is the bundle's `localizedName`, NOT the `.app` filename: Docker's window belongs to the INNER `Docker Desktop.app` so it reports "Docker Desktop", and Chrome reports "Google Chrome" though its `CFBundleName` is only "Chrome". Read the real one with `sketchybar --query front_app.name | jq -r .label.value` rather than assuming the bundle name.
- Resolve `nf-md-*` names in the installed Symbols Nerd Font cmap (fontTools), not from historical MDI numbers: `nf-md-microsoft_excel` is U+F138F here; U+F01D8 is `md-dots_horizontal`.
- A sketchybar popup on a multi-item chip must subscribe `mouse.exited.global`, never plain `mouse.exited` — the latter fires as the pointer crosses between that chip's own items and shuts the popup mid-chip.
- sketchybar caches `background.image` by path: overwriting a PNG in place can keep the old bitmap. Swap to a different path (or `--reload`) to force a re-read; the doom cycle uses one file per frame for that reason.
- White-keyed sprite sheets still have an opaque beige fringe (white mixed into skin). Color-key alone misses it — `scripts/prepare-doom-faces.py` flood-fills desaturated light pixels, 4-connected-erodes 1px, then flood-fills again.

## Sampling in plugins

- `iostat -c 2 -w 1` needs `-n 0` or each attached disk prepends 3 columns and silently shifts `us/sy/id`. macOS has no `kern.cp_time`. `top -l 2 -n 0` reads the same figures but burns ~0.57s CPU per sample vs ~0.00s for iostat.
- `netstat -bnI <iface>` gives byte counters in ~5ms with no sample window (unlike `iostat` for CPU) — read the `<Link#N>` row, `Ibytes`=$7 / `Obytes`=$10, guarded by `NF >= 11` because a row missing its MAC shifts the fields. Diff against a state file and cap its age, or a sleep/wake smears the average.
- `vm_stat` gives memory counters instantly with no sample window; usage = (active + wired + compressor-occupied) x page size / `hw.memsize`, and inactive/speculative MUST be excluded or the chip sits near full forever. `memory_pressure` is the trap: ~0.22s per tick, and its "System-wide memory free percentage" counts inactive as free — it read 85% free at the same moment vm_stat read 55% used.
- macOS 14.4+ gates SSID reads behind Location Services and returns the literal string `<redacted>` rather than an error. It is non-empty, so it silently defeats `${VAR:-default}` guards. Unbundled binaries (sketchybar, launched from AeroSpace) have no TCC identity and can neither hold nor prompt for the grant.
