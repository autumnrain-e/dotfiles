#!/usr/bin/env bash

# Focused-application chip: an accent box holding the app's Nerd Font glyph,
# joined flush to a grey box holding the app's name —  [󰄛][ kitty ]
#
# Deliberately NOT a bracket. A bracket draws ONE box beneath all of its
# members, which is exactly wrong here: the whole point of this chip is two
# boxes in two colors, with daylight between them. So these are two plain
# items — and for a plain item the item-level padding_left/right IS the gap
# outside its background box, which is what opens the seam. Contrast
# items/cpu.sh, wifi.sh and clock.sh: those are genuinely single elements and
# so do need a bracket.
#
# Left items are added left-to-right, so the icon half must be added FIRST.
# The gap from the workspaces is space_separator (width=8) in items/spaces.sh;
# neither half carries outer padding of its own.
#
# Only background.color/drawing are set here. corner_radius and height come
# from the --default block in sketchybarrc, which is what keeps both halves the
# same 26px box as the logo, workspace, ram and volume chips — re-specifying
# them per item is how boxes silently drift out of alignment.

# Pinned width of the glyph box, matching SPACE_WIDTH in items/spaces.sh so the
# app chip and the workspace chips share one square. Pinning is not cosmetic:
# sketchybar sizes an icon slot from the glyph's MEASURED extents rather than
# the font's advance width, so an unpinned box would visibly resize on every
# app switch as the cat gives way to the snowflake.
APP_ICON_WIDTH=28

# Inner margin on the name box. This has to be LABEL padding, not item padding
# — item padding sits outside the background and would widen the seam instead.
APP_LABEL_PAD=10

# Visible gap between the two halves. Carried entirely by the icon half's
# padding_right, with the name half's padding_left left at 0, so this number is
# the gap in pixels as-is. Splitting it across both items would work too but
# would make it 2x the value written here — the same doubling that SPACE_GAP in
# items/spaces.sh and RAM_GAP in items/ram.sh have to warn about, and there is
# no reason to import that arithmetic into a seam only one item can own.
APP_SEAM_GAP=2

# Glyph half. Seeded with the fallback glyph so the box is never empty in the
# window between startup and the first front_app_switched event; the plugin
# overwrites it from there on. Dark glyph on accent, per the two-tone contrast.
# icon.font is the only override vs the 16pt --default: the box stays 28px.
APP_ICON_SIZE=18.0
sketchybar --add item front_app.icon left \
    --set front_app.icon \
    icon="$ICON_APP_DEFAULT" \
    icon.font="$FONT_ICON:Regular:$APP_ICON_SIZE" \
    icon.color="$BG0" \
    icon.width="$APP_ICON_WIDTH" \
    icon.align=center \
    icon.padding_left=0 \
    icon.padding_right=0 \
    label.drawing=off \
    padding_left=0 \
    padding_right="$APP_SEAM_GAP" \
    background.color="$ACCENT" \
    background.drawing=on

# Name half. It owns the subscription and the script; plugins/front_app.sh sets
# both halves by name from that one event so the glyph and the name can never
# disagree. label.color is $FG, not $ACCENT as it was when this chip was a
# single box — the accent now carries the glyph half, and orange text beside an
# orange box loses the two-tone contrast. Swap it back here if you disagree.
sketchybar --add item front_app.name left \
    --subscribe front_app.name front_app_switched \
    --set front_app.name \
    icon.drawing=off \
    label.color="$FG" \
    label.padding_left="$APP_LABEL_PAD" \
    label.padding_right="$APP_LABEL_PAD" \
    padding_left=0 \
    padding_right=0 \
    background.color="$GROUP_BG" \
    background.drawing=on \
    script="$CONFIG_DIR/plugins/front_app.sh"
