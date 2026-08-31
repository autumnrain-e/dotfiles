#!/usr/bin/env bash

# Now playing via media-control (MediaRemote). SketchyBar's media_change
# event is deprecated on macOS 26 and does not fire.
#
# Playing: equalizer bars (plugins/media_anim.sh) + title.
# Paused: nf-fa-pause + title.
# Stopped: hidden, along with sep.cpu so the pipe does not dangle.
#
# updates=on is required: the item starts drawing=off, and the --default
# updates=when_shown would mean the script never runs to un-hide it.
# update_freq=1 polls media-control get; that is cheap without artwork.
#
# Right items are added right-to-left, and this file is sourced last, so the
# chip sits immediately left of CPU: media | cpu | ram | weather | clock.

MEDIA_ICON_WIDTH=32

sketchybar --add item media right \
    --subscribe media system_woke \
    --set media \
    updates=on \
    update_freq=1 \
    icon="$ICON_PAUSE" \
    icon.color="$ACCENT" \
    icon.width="$MEDIA_ICON_WIDTH" \
    icon.align=center \
    icon.padding_left=0 \
    icon.padding_right=4 \
    label.color="$ACCENT" \
    label.max_chars=28 \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    drawing=off \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/media.sh"
