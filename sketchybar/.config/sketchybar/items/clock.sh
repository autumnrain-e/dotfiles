#!/usr/bin/env bash

# Clock: one line, no icon, no box. e.g.  Tuesday, August 30   4:52pm
#
# Rightmost right-item (this file is sourced first among the right cluster).
# The pipe to its left is added in sketchybarrc, not here.

sketchybar --add item clock right \
    --set clock \
    update_freq=30 \
    icon.drawing=off \
    label.color="$ACCENT" \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/clock.sh"
