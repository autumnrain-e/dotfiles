#!/usr/bin/env bash

# Driver for the Wi-Fi section in items/wifi.sh: per-second upload/download
# rates. Attached to wifi.up and writes both halves by name.
#
# The SSID is deliberately NOT read here. It lives in plugins/wifi_ssid.sh,
# which runs only when the popup is opened.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

UP_ITEM="wifi.up"
DOWN_ITEM="wifi.down"

# mouse.exited.global (pointer leaves the whole bar) rather than plain
# mouse.exited: the section is two items, so a bare mouse.exited fires while
# the pointer merely crosses from up onto down.
if [ "$SENDER" = "mouse.exited.global" ]; then
    sketchybar --set "$UP_ITEM" popup.drawing=off
    exit 0
fi

IFACE="$(networksetup -listallhardwareports 2>/dev/null |
    awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; print $2; exit}')"
IFACE="${IFACE:-en0}"

STATE="${TMPDIR:-/tmp}/sketchybar_wifi_${IFACE}.state"

offline() {
    rm -f "$STATE"
    sketchybar --set "$UP_ITEM" icon.color="$ACCENT" label="--" label.color="$ACCENT" \
        --set "$DOWN_ITEM" icon.color="$ACCENT" label="--" label.color="$ACCENT" \
        --set "$UP_ITEM" popup.drawing=off
    exit 0
}

ifconfig "$IFACE" 2>/dev/null | grep -q "status: active" || offline

# netstat -bnI is ~5ms and needs no sample window. Read the <Link#N> row:
# Ibytes=$7 / Obytes=$10, guarded by NF >= 11 because a row missing its MAC
# shifts the fields.
read -r RX TX < <(netstat -bnI "$IFACE" 2>/dev/null |
    awk 'NF >= 11 && $3 ~ /^<Link/ { print $7, $10; exit }')

[ -n "$RX" ] && [ -n "$TX" ] || offline

NOW="$(date +%s)"
RX_RATE=""
TX_RATE=""

if [ -r "$STATE" ]; then
    read -r PREV_T PREV_RX PREV_TX <"$STATE"

    ELAPSED=$((NOW - PREV_T))

    # Over ~60s the average stops describing anything current — sleep/wake or a
    # hidden bar. Under 1s guards the div-by-zero when an event fires in the
    # same second as a poll.
    if [ "$ELAPSED" -ge 1 ] && [ "$ELAPSED" -le 60 ]; then
        D_RX=$((RX - PREV_RX))
        D_TX=$((TX - PREV_TX))

        [ "$D_RX" -lt 0 ] && D_RX=0
        [ "$D_TX" -lt 0 ] && D_TX=0

        RX_RATE=$((D_RX / ELAPSED))
        TX_RATE=$((D_TX / ELAPSED))
    fi
fi

printf '%s %s %s\n' "$NOW" "$RX" "$TX" >"$STATE"

# Every branch is capped at 8 characters, which is what lets the pinned
# label.width in items/wifi.sh stay tight. Switching to MB/s at 1000 KB/s
# rather than 1024 keeps KB/s to three digits; dropping the decimal past
# 10 MB/s keeps "123 MB/s" from needing a tenth column.
rate() {
    [ -n "$1" ] || {
        printf '%s' '--'
        return
    }
    awk -v b="$1" 'BEGIN {
        if (b < 1024)              printf "%d B/s", b
        else if (b < 1024000)      printf "%d KB/s", b / 1024
        else if (b < 10485760)     printf "%.1f MB/s", b / 1048576
        else                       printf "%d MB/s", b / 1048576
    }'
}

sketchybar --set "$UP_ITEM" icon.color="$ACCENT" label="$(rate "$TX_RATE")" label.color="$ACCENT" \
    --set "$DOWN_ITEM" icon.color="$ACCENT" label="$(rate "$RX_RATE")" label.color="$ACCENT"
