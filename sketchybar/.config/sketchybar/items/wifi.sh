#!/usr/bin/env bash

# Wi-Fi: one-line upload/download, no network glyph.
#
#   ↑ 13 KB/s  ↓ 1.2 MB/s
#
# Right items are added right-to-left, so wifi.down is added first (rightmost
# of the pair) and wifi.up lands to its left. wifi.up owns the sampler, the
# popup, and the mouse events; both halves toggle the SSID popup on click.
#
# mouse.exited.global, never plain mouse.exited: the section is two items, so
# a bare mouse.exited would fire as the pointer crosses from up onto down and
# shut the popup mid-section.
#
# Pipes in sketchybarrc own the section spacing, so item padding stays 0.
# label.width is pinned because a pinned width CLIPS rather than grows, and
# plugins/wifi.sh caps its formatter at 8 characters to match.

WIFI_TEXT_WIDTH=58

CLICK="\"\$CONFIG_DIR/plugins/wifi_ssid.sh\"; sketchybar --set wifi.up popup.drawing=toggle"

sketchybar --add item wifi.down right \
    --set wifi.down \
    icon="$ICON_DOWNLOAD" \
    icon.color="$ACCENT" \
    icon.padding_left=0 \
    icon.padding_right=8 \
    label.padding_left=0 \
    label.padding_right=0 \
    label.width="$WIFI_TEXT_WIDTH" \
    label.align=left \
    label="--" \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    click_script="$CLICK"

sketchybar --add item wifi.up right \
    --set wifi.up \
    update_freq=2 \
    icon="$ICON_UPLOAD" \
    icon.color="$ACCENT" \
    icon.padding_left=0 \
    icon.padding_right=8 \
    label.padding_left=0 \
    label.padding_right=10 \
    label.width="$WIFI_TEXT_WIDTH" \
    label.align=left \
    label="--" \
    padding_left=0 \
    padding_right=0 \
    background.drawing=off \
    popup.align=center \
    popup.height=30 \
    popup.y_offset=-4 \
    popup.background.color="$GROUP_BG" \
    popup.background.corner_radius=6 \
    popup.background.border_width=1 \
    popup.background.border_color="$BG3" \
    script="$CONFIG_DIR/plugins/wifi.sh" \
    click_script="$CLICK" \
    --subscribe wifi.up wifi_change system_woke mouse.exited.global

sketchybar --add item wifi.name popup.wifi.up \
    --set wifi.name \
    icon="$ICON_WIFI" \
    icon.color="$ACCENT" \
    icon.padding_left=10 \
    icon.padding_right=6 \
    label="looking up..." \
    label.padding_right=12 \
    background.drawing=off \
    click_script="sketchybar --set wifi.up popup.drawing=off"
