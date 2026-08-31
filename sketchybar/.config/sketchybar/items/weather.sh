#!/usr/bin/env bash

# Weather: emoji + Celsius, e.g.  ☀️ 13°C
#
# Open-Meteo, no API key. The plugin picks the emoji from the WMO weather
# code and is_day, so clear nights get a moon rather than a sun.
# Apple Color Emoji is required here — the bar-wide FONT_ICON is Nerd Font,
# which has no colour emoji. icon.color is left at white so the glyphs keep
# their own colour instead of being tinted to $ACCENT.

sketchybar --add item weather right \
    --set weather \
    update_freq=1800 \
    icon="$ICON_WEATHER_CLOUDY" \
    icon.font="Apple Color Emoji:Regular:14.0" \
    icon.color=0xffffffff \
    icon.padding_left=0 \
    icon.padding_right=4 \
    label.padding_left=0 \
    label.padding_right=0 \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    script="$CONFIG_DIR/plugins/weather.sh" \
    --subscribe weather system_woke
