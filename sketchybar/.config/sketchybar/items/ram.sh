#!/usr/bin/env bash

# RAM: nf-fa-memory glyph + percent used.
#
# A plain single item. The pipes in sketchybarrc own the section spacing, so
# padding stays 0. It lives in its own file purely for ORDER: right items are
# added right-to-left, and sketchybarrc sources this between wifi and cpu.

sketchybar --add item ram right \
    --set ram \
    update_freq=15 \
    icon="$ICON_RAM" \
    icon.color="$ACCENT" \
    icon.padding_left=0 \
    icon.padding_right=4 \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/ram.sh" \
    --subscribe ram system_woke
