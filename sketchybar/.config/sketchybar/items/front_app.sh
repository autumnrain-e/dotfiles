#!/usr/bin/env bash

# Focused-application name, no glyph and no box. The gap from the workspaces
# is space_separator in items/spaces.sh.

sketchybar --add item front_app.name left \
    --subscribe front_app.name front_app_switched \
    --set front_app.name \
    icon.drawing=off \
    label.color="$ACCENT" \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/front_app.sh"
