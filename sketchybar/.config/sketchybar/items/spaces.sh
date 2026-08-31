#!/usr/bin/env bash

# Logo + AeroSpace workspace indicators.
#
# Workspaces are read from `aerospace list-workspaces --all`, so they follow
# persistent-workspaces in aerospace.toml automatically — no hardcoded list.
# Highlighting is driven by the aerospace_workspace_change custom event, which
# aerospace.toml fires via exec-on-workspace-change.
#
# No boxes: the digit IS the item. Focused workspace turns $ACCENT; the rest
# stay $FG_DIM. Spacing is icon padding, not item padding — there is no
# background for item padding to sit outside of.

# Empty item on each end of the workspace row, so the logo and the app chip
# keep a consistent gap from the numbers. A future pinned-width logo would
# swallow its own padding_right; the spacer keeps both ends expressed the
# same way.
SPACE_EDGE=8

# Logo chip: a single static Nerd Font glyph ($ICON_LOGO, nf-fa-canadian_maple_leaf), no
# script and no timer. Width is deliberately dynamic — one fixed glyph never
# re-measures, and a pinned width would swallow this item's own padding_right.
# padding_right stays 0 so it does not stack on SPACE_EDGE.
sketchybar --add item logo left \
    --set logo \
    padding_right=0 \
    icon="$ICON_LOGO" \
    icon.color="$YELLOW" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.drawing=off \
    background.drawing=off \
    click_script="open -a 'System Settings'"

sketchybar --add item logo_separator left \
    --set logo_separator \
    icon.drawing=off \
    label.drawing=off \
    width="$SPACE_EDGE"

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space."$sid" left \
        --subscribe space."$sid" aerospace_workspace_change \
        --set space."$sid" \
        icon="$sid" \
        icon.font="$FONT_TEXT:$FONT_TEXT_BOLD:13.0" \
        icon.color="$FG_DIM" \
        icon.padding_left=6 \
        icon.padding_right=6 \
        label.drawing=off \
        background.drawing=off \
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
