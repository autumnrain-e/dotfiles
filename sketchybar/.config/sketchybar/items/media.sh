#!/usr/bin/env bash

# Now playing. sketchybar's media_change event delivers a JSON payload in $INFO
# for any app using the macOS Now Playing APIs (Music, Spotify, browsers).
# Hidden entirely when nothing is playing.

sketchybar --add item media right \
    --subscribe media media_change \
    --set media \
    icon="$ICON_MUSIC" \
    icon.color="$MAGENTA" \
    label.color="$FG_DIM" \
    label.max_chars=28 \
    drawing=off \
    script="$CONFIG_DIR/plugins/media.sh"
