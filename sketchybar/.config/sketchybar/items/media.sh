#!/usr/bin/env bash

# Now playing. sketchybar's media_change event delivers a JSON payload in $INFO
# for any app using the macOS Now Playing APIs (Music, Spotify, browsers).
# Hidden entirely when nothing is playing.

sketchybar --add item media right \
    --subscribe media media_change \
    --set media \
    icon="$ICON_MUSIC" \
    icon.color="$ACCENT" \
    label.color="$ACCENT" \
    label.max_chars=28 \
    drawing=off \
    icon.padding_left=0 \
    icon.padding_right=4 \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/media.sh"
