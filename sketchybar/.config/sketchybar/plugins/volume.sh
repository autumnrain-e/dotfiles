#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# On a volume_change event $INFO is the output volume (0-100). On the initial
# paint (routine/forced update) there is no $INFO, so ask CoreAudio directly.
VOLUME="$INFO"
if [ -z "$VOLUME" ]; then
    VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

# AppleScript answers "missing value" when the active output device exposes no
# software volume (some DACs, HDMI, AirPlay). Show the icon alone rather than a
# fake number — a real volume_change event will fill the label in later.
case "$VOLUME" in
'' | *[!0-9]*)
    sketchybar --set "$NAME" \
        icon="$ICON_VOLUME_HIGH" \
        icon.color="$FG_DIM" \
        label.drawing=off
    exit 0
    ;;
esac

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
    ICON="$ICON_VOLUME_MUTE"
    COLOR="$FG_DIM"
elif [ "$VOLUME" -lt 50 ]; then
    ICON="$ICON_VOLUME_LOW"
    COLOR="$FG"
else
    ICON="$ICON_VOLUME_HIGH"
    COLOR="$FG"
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="${VOLUME}%" \
    label.drawing=on
