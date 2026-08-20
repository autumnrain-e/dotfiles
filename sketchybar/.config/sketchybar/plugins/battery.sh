#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

BATT_INFO="$(pmset -g batt)"
# BSD grep has no \d — use an explicit class.
PERCENTAGE="$(echo "$BATT_INFO" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
CHARGING="$(echo "$BATT_INFO" | grep -o 'AC Power')"

# Desktop Macs / no battery: hide the item rather than show a bogus 0%.
if [ -z "$PERCENTAGE" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "$PERCENTAGE" -ge 80 ]; then
    ICON="$ICON_BATTERY_100"
    COLOR="$GREEN"
elif [ "$PERCENTAGE" -ge 60 ]; then
    ICON="$ICON_BATTERY_75"
    COLOR="$FG"
elif [ "$PERCENTAGE" -ge 40 ]; then
    ICON="$ICON_BATTERY_50"
    COLOR="$YELLOW"
elif [ "$PERCENTAGE" -ge 20 ]; then
    ICON="$ICON_BATTERY_25"
    COLOR="$ORANGE"
else
    ICON="$ICON_BATTERY_0"
    COLOR="$RED"
fi

if [ -n "$CHARGING" ]; then
    ICON="$ICON_BATTERY_CHARGING"
    COLOR="$GREEN"
fi

sketchybar --set "$NAME" \
    drawing=on \
    icon="$ICON" \
    icon.color="$COLOR" \
    label="${PERCENTAGE}%"
