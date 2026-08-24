#!/usr/bin/env bash

# Logo + AeroSpace workspace indicators.
#
# Workspaces are read from `aerospace list-workspaces --all`, so they follow
# persistent-workspaces in aerospace.toml automatically — no hardcoded list.
# Highlighting is driven by the aerospace_workspace_change custom event, which
# aerospace.toml fires via exec-on-workspace-change.
#
# Spacing: item-level padding_left/right is the gap OUTSIDE the rounded
# background (what separates one chip from the next); icon.padding_left/right
# is inside it and only makes a chip wider. Adjacent chips each contribute
# their own padding, so the visible gap between two workspaces is 2x SPACE_GAP.

# Gap outside each workspace chip; adjacent chips each contribute one, so
# the visible gap between two workspaces is 2x SPACE_GAP (4px).
SPACE_GAP=2

# Empty item on each end of the workspace row. Together with the adjacent
# workspace's SPACE_GAP this is the visible gap: 8+2=10, same on the logo
# side and the app-chip side. The logo's own padding_right could carry that
# gap now that its width is dynamic again, but the spacer stays: it keeps
# both ends of the row expressed the same way, and a future pinned-width
# logo would swallow its own padding_right (as the doom chip's width=35 did).
SPACE_EDGE=8

# Fixed chip width. Digit glyphs do not all advance the same amount here (a "1"
# measures narrower than a "2"), so letting the box auto-size gives uneven
# chips. Pinning icon.width with icon.align=center makes every workspace box
# identical regardless of its label — and keeps them even if a workspace is
# ever named something wider than one character.
SPACE_WIDTH=28

# Logo chip: a single static Nerd Font glyph ($ICON_LOGO, nf-md-coffee), no
# script and no timer. This replaced the doom face-cycle animation (plugin,
# sprite assets and prep script all deleted 2026-08-24); icons.sh keeps the
# pom-away and ghost glyphs commented below ICON_LOGO to swap back to.
#
# Width is deliberately dynamic — one fixed glyph never re-measures, so there
# is nothing to pin against, and a pinned width would swallow this item's own
# padding_right (which is why the doom chip needed logo_separator). The 10pt
# icon padding is inside the background box and just sizes the chip.
#
# padding_right must stay 0: it stacks on SPACE_EDGE, so the left gap would
# otherwise be 20px. 0 + SPACE_EDGE + SPACE_GAP = 10, matching the app-chip
# end of the row. Chip geometry (corner_radius, height) comes from the
# --default block in sketchybarrc — never re-specify it per item.
sketchybar --add item logo left \
    --set logo \
    padding_right=0 \
    icon="$ICON_LOGO" \
    icon.color="$YELLOW" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.drawing=off \
    background.color="$GROUP_BG" \
    background.drawing=on \
    click_script="open -a 'System Settings'"

# Same construction as space_separator at the other end of the row.
sketchybar --add item logo_separator left \
    --set logo_separator \
    icon.drawing=off \
    label.drawing=off \
    width="$SPACE_EDGE"

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space."$sid" left \
        --subscribe space."$sid" aerospace_workspace_change \
        --set space."$sid" \
        padding_left="$SPACE_GAP" \
        padding_right="$SPACE_GAP" \
        icon="$sid" \
        icon.font="$FONT_TEXT:$FONT_TEXT_BOLD:13.0" \
        icon.width="$SPACE_WIDTH" \
        icon.align=center \
        icon.padding_left=0 \
        icon.padding_right=0 \
        label.drawing=off \
        background.color="$GROUP_BG" \
        background.drawing=on \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done

# Breathing room between the workspaces and the focused-app name.
# width is SPACE_EDGE so this gap equals logo-to-workspace-1.
sketchybar --add item space_separator left \
    --set space_separator \
    icon.drawing=off \
    label.drawing=off \
    width="$SPACE_EDGE"
