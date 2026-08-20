#!/usr/bin/env bash

# Clock chip: the date over the time, two centred lines, no icon.
#
#   Mon 10 Aug
#    11:07 AM
#
# Replaces the single-line `clock` chip that used to live in items/status.sh
# (commented out there, revertible by dropping the source line for this file from
# sketchybarrc). The glyph is gone because the chip is unmistakably a clock
# without it, and dropping it buys back the width the second line needs.
#
# Two items plus a bracket, in one chip:
#   clock.date   upper line, overlaid on clock.time via width=0
#   clock.time   lower line; owns the script and the update_freq
#
# THE BRACKET IS NOT OPTIONAL, even though both lines occupy the same x range and
# so a single member's box would already span the whole chip. Tried that first —
# clock.time with background.drawing=on and no bracket — and the date line
# vanished: items are DRAWN IN ADD ORDER, and the overlay has to be added first
# (a width=0 item never advances the layout cursor, so it is the *following* item
# that lands on top of it). clock.time's opaque background therefore painted over
# the sibling it was supposed to sit under. A bracket is drawn beneath all of its
# members, which is the only way round it.
#
# The cost is that a bracket ignores every padding property — its own
# padding_left/right report back null, its members' padding is swallowed into the
# box, and background.padding_* does nothing (all measured; see the CPU_GAP note
# in items/cpu.sh). So the chip's gaps come from two empty items instead.
#
# Added right-to-left like every right item, and this file is sourced BEFORE
# items/status.sh so the chip stays rightmost, where the old one was.

# Matches STATUS_GAP in status.sh and SPACE_GAP in spaces.sh, held by the two
# zero-drawing gap items below rather than by any padding property.
CLOCK_GAP=3

# This is the whole chip's inner width, not just the text's — pinned on both
# lines, and doing three jobs at once.
#
# 1. It makes the two lines share one box and centre against each other. Their
#    natural widths differ, and clock.date is right-anchored (see width=0 below),
#    so without a common pinned width the shorter time line would hang off the
#    right edge instead of sitting under the date.
# 2. It SIZES THE BRACKET. A bracket's box is the union of its members'
#    bounding_rects, and a rect excludes padding — so label.padding_left/right is
#    inert here, measured: 8/8 and 20/20 both left the box at exactly label.width
#    and did not move it either. That is why both items below set label padding to
#    0 rather than inheriting the --default block's 4/8; the inner margin is the
#    slack in this number, and a padding value would only read as a knob that
#    does nothing.
# 3. It stops the chip resizing as the strings change — though both formats are
#    FIXED-LENGTH by construction anyway (%a and %b are always 3 characters, %d
#    and %I are zero-padded to 2), so only glyph width varies.
#
# 72 = the widest string plus an 8px margin either side, matching the icon.padding
# and label.padding insets every other chip uses. Measured across all 7 weekdays
# and 12 months at the size below: the widest date is "Wed 22 May" at 55px, and
# the time tops out at 41. Re-measure before changing the font or the size — a
# pinned label width CLIPS rather than grows, so the margin is the only headroom.
CLOCK_BOX_WIDTH=72

# 9.5pt for the same reason as the wifi lines: two of them have to fit the 26px
# chip every other item uses, and 9.5pt Helvetica is ~13px per line. The offset
# splits them either side of centre. Applied to the ITEM, matching items/wifi.sh —
# label.y_offset works too, but with the box coming from the bracket there is no
# longer any background for an item offset to drag out of place.
CLOCK_LINE_SIZE=9.5
CLOCK_LINE_OFFSET=6

# Right-hand gap, between the chip and the bar's own padding_right. Added FIRST so
# it is the rightmost item; not a bracket member, or the box would absorb it.
sketchybar --add item clock.gap.right right \
    --set clock.gap.right \
    width="$CLOCK_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# The date — upper line, and the overlay. width=0 means it consumes no width and
# never advances the layout cursor, so clock.time is drawn at the same x and the
# two share a right edge. Its label is right-anchored as a result, which is what
# makes the pinned label.width above load-bearing rather than cosmetic.
#
# Bold, like every other label in the bar. $FONT_TEXT_REGULAR here was tried and
# rejected — it was meant to let the time read as the primary line, but the date
# just looked washed out beside it, and it would have been the one Regular-weight
# label in the whole config.
sketchybar --add item clock.date right \
    --set clock.date \
    width=0 \
    y_offset="$CLOCK_LINE_OFFSET" \
    icon.drawing=off \
    label.font="$FONT_TEXT:$FONT_TEXT_BOLD:$CLOCK_LINE_SIZE" \
    label.width="$CLOCK_BOX_WIDTH" \
    label.align=center \
    label.padding_left=0 \
    label.padding_right=0 \
    label="--"

# The time — lower line, and the item that owns the behaviour: one date(1) call in
# the plugin feeds both labels. Identical inner geometry to clock.date by
# construction; only y_offset differs. update_freq=30 carries over from the old
# single-line chip.
sketchybar --add item clock.time right \
    --set clock.time \
    update_freq=30 \
    y_offset="-$CLOCK_LINE_OFFSET" \
    icon.drawing=off \
    label.font="$FONT_TEXT:$FONT_TEXT_BOLD:$CLOCK_LINE_SIZE" \
    label.width="$CLOCK_BOX_WIDTH" \
    label.align=center \
    label.padding_left=0 \
    label.padding_right=0 \
    label="--" \
    script="$CONFIG_DIR/plugins/clock.sh"

# The calendar glyph, to the LEFT of the text stack — hence added after the two
# lines, since right items are placed right-to-left.
#
# ON TRIAL: the chip shipped without a glyph (it is unmistakably a clock without
# one, and the width bought the second line). Revert = delete this item and drop
# clock.icon from the bracket member list at the bottom.
#
# Geometry is carried entirely by icon.width, with icon.padding_* left at 0: the
# bracket measures its members' bounding_rects, and a rect excludes padding (see
# the CLOCK_BOX_WIDTH note), so padding here would move the glyph without moving
# the box and the chip edge would cut straight through the ink.
#
# icon.align=right puts ALL of that slack on the left, which is what makes it the
# chip's left inset. The gap on the other side of the glyph then comes from the
# text stack's own centring slack — (72 - 55) / 2 — so the two sides land on
# roughly the same 8px without a second knob.
#
# icon.font is deliberately NOT set: it inherits the 16pt from the --default block,
# like every other icon in the bar. 14pt was tried first, on the theory that 16
# would loom over two 9.5pt text lines, and rejected — the calendar glyph is a grid
# of day cells, and at 14pt they mush together. Leaving the font unset is also what
# keeps this chip's glyph from becoming a second source of truth for icon size.
#
# 23 = the glyph's 15px natural width at 16pt plus the 8px inset. Re-measure it if
# the glyph or the default icon size ever changes; at 14pt this was 21.
CLOCK_ICON_WIDTH=23

sketchybar --add item clock.icon right \
    --set clock.icon \
    icon="$ICON_CALENDAR" \
    icon.color="$BLUE" \
    icon.width="$CLOCK_ICON_WIDTH" \
    icon.align=right \
    icon.padding_left=0 \
    icon.padding_right=0 \
    label.drawing=off

# Left-hand gap, between the chip and battery. Added LAST so it is the leftmost
# item; its 3px meets battery's own padding_right for a 6px gap, the same total
# two plain chips get from their padding.
sketchybar --add item clock.gap.left right \
    --set clock.gap.left \
    width="$CLOCK_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# One box behind both lines — and, per the note at the top of this file, the only
# way to get a fill under the overlaid line rather than over it. Only
# colour/drawing are set; corner_radius and height come from the --default block
# in sketchybarrc, which keeps this box identical to every other chip's.
#
# The gap items are not members: a bracket's box is the union of its members'
# rects, so a member spacer would sit inside the box instead of outside it.
sketchybar --add bracket clock.group clock.icon clock.date clock.time \
    --set clock.group \
    background.color="$GROUP_BG" \
    background.drawing=on
