#!/usr/bin/env bash

# Highlights the focused AeroSpace workspace.
# $1                 — workspace id this item represents (passed in items/spaces.sh)
# $NAME              — item name, set by sketchybar
# $FOCUSED_WORKSPACE — set by the aerospace_workspace_change trigger

source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color="$ACCENT" \
        icon.color="$BG0"
else
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color="$GROUP_BG" \
        icon.color="$FG_DIM"
fi
