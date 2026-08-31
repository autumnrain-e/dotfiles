#!/usr/bin/env bash

# Equalizer frames for the media item while something is playing.
# Cycled from plugins/media.sh; killed on pause/stop/reload.
# Frames match josean-dev's waybar media-animation.sh.

frames=(
    "▂▄▆"
    "▄▂▆"
    "▄▆▂"
    "▆▄▂"
    "▆▂▄"
)
i=0
while :; do
    sketchybar --set media icon="${frames[$i]}"
    i=$(((i + 1) % ${#frames[@]}))
    sleep 0.1
done
