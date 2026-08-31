#!/usr/bin/env bash

# CPU: nf-oct-cpu glyph + percent, e.g.   12%
#
# Replaces the four-item graph cluster (plugins/cpu_graph.sh is still on disk
# as the revert path). A plain item, so item padding would be the gap — but
# the pipes in sketchybarrc own the section spacing, so padding stays 0.

sketchybar --add item cpu right \
    --set cpu \
    update_freq=5 \
    icon="$ICON_CPU" \
    icon.color="$ACCENT" \
    icon.padding_left=0 \
    icon.padding_right=4 \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/cpu.sh"
