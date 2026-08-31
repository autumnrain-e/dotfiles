#!/usr/bin/env bash

# Highlights the focused AeroSpace workspace by recoloring the digit.
# $1                 — workspace id this item represents (passed in items/spaces.sh)
# $NAME              — item name, set by sketchybar
# $FOCUSED_WORKSPACE — set by the aerospace_workspace_change trigger

source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" icon.color="$ACCENT"
else
    sketchybar --set "$NAME" icon.color="$FG_DIM"
fi
