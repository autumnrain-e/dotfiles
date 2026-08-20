#!/usr/bin/env bash

# CPU graph cluster — ported from FelixKratz/dotfiles (.config/sketchybar/items/cpu.sh).
#
# Four items that read as one chip:
#   cpu.user / cpu.sys   overlapping history graphs — user load and system load
#   cpu.percent          combined load, recolored by threshold
#   cpu.top              name of the busiest process, stacked above the percent
#
# Upstream drives these from a compiled mach helper (helper/cpu.h) that reads
# host_statistics() tick deltas. This port keeps the layout but feeds it from
# plugins/cpu_graph.sh instead, so there is no build step and nothing vendored —
# consistent with how the rest of this package treats sketchybar and borders.
#
# THE STACKING TRICK IS width=0. An item with zero width consumes no horizontal
# space, so the next item is placed at the same x and the two overlap:
#   - cpu.sys (width=0) is overdrawn by cpu.user, giving one two-tone graph
#   - cpu.top (width=0) is overdrawn by cpu.percent, separated vertically by
#     their y_offsets rather than horizontally
# Both pairs are therefore ONE visual element built from two items.
#
# Added right-to-left like every other right item, so the add order below is
# rightmost first: percent/top land on the right of the graph.

# Plot width in px. Upstream uses 75; this bar carries more items, so it is
# trimmed to keep the right cluster from crowding the workspace list.
CPU_GRAPH_WIDTH=62

# Matches STATUS_GAP in status.sh and SPACE_GAP in spaces.sh, so this chip
# breathes like the rest of the bar. Adjacent chips each contribute their own,
# so the visible gap between two of them is 2x this.
#
# A BRACKET CANNOT BE SPACED BY PADDING. All three obvious routes were tried and
# measured against the rendered bar, and all three are silent no-ops — which is
# why this chip shipped flush against the wifi chip:
#   - item padding_left/right on the bracket: ignored outright (set it to 20 and
#     nothing moves; --query even reports it back as null)
#   - padding on the member items: the bracket grows its box to swallow it, so
#     the chip gets wider and the gap never appears
#   - background.padding_left/right on the bracket: no pixel effect either
# So the gap is a pair of real ITEMS with nothing drawn in them, below. Layout
# space held by a non-member item is the one thing the bracket will not absorb.
#
# Plain items (volume, battery, clock) are the opposite case: their background
# excludes their own padding, so there item padding IS the correct mechanism.
CPU_GAP=3

# Right margin between the text stack and the chip edge. Both items need it, but
# they need it through DIFFERENT properties, because their boxes differ:
#   cpu.top     is width=0 and has no box, so item padding_right moves its
#               anchor — and, since a zero-width item never advances the layout
#               cursor, it shifts nothing else.
#   cpu.percent has the fixed box the bracket measures itself from. Item padding
#               there would pull the bracket's right edge in with it and cancel
#               the margin out, so the inset must happen inside the box via
#               label.padding_right.
# Same number either way; that is what lands the two labels on one right edge.
CPU_TEXT_INSET=8

# Right-hand gap. Added FIRST, so it is the rightmost item of this cluster and
# therefore lands between the chip and the wifi chip beside it. Deliberately NOT
# a member of cpu.group — adding it there would only make the box wider.
sketchybar --add item cpu.gap.right right \
    --set cpu.gap.right \
    width="$CPU_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# Busiest-process name, overlaid above the percentage. Regular weight and small:
# it is a caption for the number, not a peer of it.
#
# Added FIRST so it is the rightmost item. A zero-width item's label is
# RIGHT-anchored and extends leftward (measured, not assumed — its bounding rect
# reports the label's own width sitting to the left of the anchor), so anchoring
# it here is what puts it over the percentage rather than over the graph.
#
# padding_right is the chip's internal right margin: it is applied to this item
# only, and because the item is zero-width the layout cursor then hands the same
# right edge to cpu.percent, so caption and number share one right alignment.
#
# 7.5pt is a constraint, not taste. This chip is 26px where upstream's is 30px,
# and caption + number must both fit — 9pt over 12pt measured ~27px and the two
# glyph boxes collided. Helvetica also has no Semibold or Heavy face installed
# (upstream uses both) and CoreText substitutes silently, so this sticks to the
# two styles sketchybarrc actually verified.
sketchybar --add item cpu.top right \
    --set cpu.top \
    width=0 \
    y_offset=6 \
    padding_right="$CPU_TEXT_INSET" \
    icon.drawing=off \
    label.font="$FONT_TEXT:$FONT_TEXT_REGULAR:7.5" \
    label.color="$FG_DIM" \
    label.padding_left=0 \
    label.padding_right=0 \
    label=""

# The percentage, and the only item with a script — one sampler feeds all four.
# update_freq=2 matches upstream; the sampler blocks ~1s per run, so this is a
# 50% duty cycle on a command that costs no measurable CPU (see cpu_graph.sh).
#
# Width is fixed rather than fitted so the chip does not resize as the number
# goes 9% -> 100%, which would jitter every chip to its left. Right-aligned to
# share cpu.top's edge; the slack falls on the left, against the graph.
sketchybar --add item cpu.percent right \
    --set cpu.percent \
    update_freq=2 \
    y_offset=-4 \
    width=52 \
    padding_right=0 \
    icon.drawing=off \
    label.font="$FONT_TEXT:$FONT_TEXT_BOLD:12.0" \
    label.align=right \
    label.padding_left=0 \
    label.padding_right="$CPU_TEXT_INSET" \
    label="--" \
    script="$CONFIG_DIR/plugins/cpu_graph.sh"

# System load — filled, drawn first, so user load overlays it.
#
# background.drawing/color here are NOT chip decoration: a graph plots inside
# its background rect, so this is the plot area, and the fill must be
# transparent to let the bracket's chip show through. Height is deliberately
# left unset so it inherits the 26px default and the plot fills the chip exactly
# — the same single-source-of-truth rule the other chips follow.
sketchybar --add graph cpu.sys right "$CPU_GRAPH_WIDTH" \
    --set cpu.sys \
    width=0 \
    graph.color="$RED" \
    graph.fill_color="$RED" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=on \
    background.color="$TRANSPARENT"

# User load — line only, over the filled system graph.
sketchybar --add graph cpu.user right "$CPU_GRAPH_WIDTH" \
    --set cpu.user \
    graph.color="$BLUE" \
    graph.fill_color="$TRANSPARENT" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=on \
    background.color="$TRANSPARENT"

# Left-hand gap — the mirror of cpu.gap.right, added LAST so it is the leftmost
# item of the cluster and separates the chip from media.
sketchybar --add item cpu.gap.left right \
    --set cpu.gap.left \
    width="$CPU_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# One box behind all four. A bracket is right here precisely because these items
# ARE one element — unlike the workspace chips, which needed separate boxes.
# Only color/drawing are set; corner_radius and height come from --default.
#
# The two gap items are not listed: a bracket's box is the union of its members'
# rects, so a member spacer would be inside the box instead of outside it.
sketchybar --add bracket cpu.group cpu.top cpu.percent cpu.sys cpu.user \
    --set cpu.group \
    background.color="$GROUP_BG" \
    background.drawing=on
