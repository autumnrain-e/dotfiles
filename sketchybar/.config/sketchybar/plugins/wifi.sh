#!/usr/bin/env bash

# Driver for the Wi-Fi chip in items/wifi.sh: per-second upload/download rates
# for the two-line readout, plus the icon's connected/offline state.
#
# The SSID is deliberately NOT read here any more. It moved to
# plugins/wifi_ssid.sh, which runs only when the popup is opened — resolving it
# costs a scutil call and sometimes a python3 fallback, which is far too much to
# repeat every 2s for a string that changes maybe twice a day.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# This script is attached to `wifi` (the icon item) and drives its siblings by
# name — $NAME only ever refers to the icon, so the others are spelled out.
ICON_ITEM="wifi"
UP_ITEM="wifi.up"
DOWN_ITEM="wifi.down"

# Dismissing the popup lives here rather than in a separate script: this is the
# only item subscribed to the mouse events, and a plugin gets $SENDER for free.
#
# mouse.exited.global (pointer leaves the whole bar) rather than plain
# mouse.exited: the chip is several items, so a bare mouse.exited fires while
# the pointer merely crosses from the icon onto the speed readout, slamming the
# popup shut halfway across the chip it was opened from.
if [ "$SENDER" = "mouse.exited.global" ]; then
    sketchybar --set "$ICON_ITEM" popup.drawing=off
    exit 0
fi

# Resolve the Wi-Fi interface instead of assuming en0 (varies across Macs).
IFACE="$(networksetup -listallhardwareports 2>/dev/null |
    awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; print $2; exit}')"
IFACE="${IFACE:-en0}"

# Previous byte counters, so a rate can be derived without the script having to
# sleep through a sample window the way the CPU plugin does.
STATE="${TMPDIR:-/tmp}/sketchybar_wifi_${IFACE}.state"

offline() {
    # Drop the counters too. Keeping them would make the first sample after
    # reconnecting a delta across the whole offline stretch.
    rm -f "$STATE"
    sketchybar --set "$ICON_ITEM" icon="$ICON_WIFI_OFF" icon.color="$FG_DIM" \
        --set "$UP_ITEM" label="offline" label.color="$FG_DIM" \
        --set "$DOWN_ITEM" label="--" label.color="$FG_DIM" \
        --set "$ICON_ITEM" popup.drawing=off
    exit 0
}

ifconfig "$IFACE" 2>/dev/null | grep -q "status: active" || offline

# netstat -bnI is ~5ms and needs no sample window, unlike iostat for the CPU.
# Read the <Link#N> row: the address rows repeat the same counters, and Ibytes /
# Obytes are fields 7 and 10 only when the row is complete — a row missing its
# MAC address shifts them, hence the NF guard rather than a bare field index.
read -r RX TX < <(netstat -bnI "$IFACE" 2>/dev/null |
    awk 'NF >= 11 && $3 ~ /^<Link/ { print $7, $10; exit }')

[ -n "$RX" ] && [ -n "$TX" ] || offline

NOW="$(date +%s)"
RX_RATE=""
TX_RATE=""

if [ -r "$STATE" ]; then
    read -r PREV_T PREV_RX PREV_TX <"$STATE"

    ELAPSED=$((NOW - PREV_T))

    # Over ~60s the average stops describing anything current — that gap means a
    # sleep/wake or a hidden bar, so seed a fresh baseline instead of drawing a
    # rate smeared across it. Under 1s guards the div-by-zero when an event
    # (wifi_change, system_woke) fires in the same second as a poll.
    if [ "$ELAPSED" -ge 1 ] && [ "$ELAPSED" -le 60 ]; then
        D_RX=$((RX - PREV_RX))
        D_TX=$((TX - PREV_TX))

        # Counters reset when the interface cycles; a negative delta is that,
        # not negative throughput.
        [ "$D_RX" -lt 0 ] && D_RX=0
        [ "$D_TX" -lt 0 ] && D_TX=0

        RX_RATE=$((D_RX / ELAPSED))
        TX_RATE=$((D_TX / ELAPSED))
    fi
fi

printf '%s %s %s\n' "$NOW" "$RX" "$TX" >"$STATE"

# Binary units, and no zero padding: the bar font is proportional, so padded
# digits would not line up anyway. items/wifi.sh pins the box width instead, so
# the chip cannot resize as the number grows.
#
# Every branch is capped at 8 characters, which is what lets that pinned width be
# tight instead of defensive. Two of the thresholds exist only for that:
# switching to MB/s at 1000 KB/s rather than 1024 keeps KB/s to three digits, and
# dropping the decimal past 10 MB/s keeps "123 MB/s" from needing a tenth column
# that would only ever matter on a link this bar will not see.
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

sketchybar --set "$ICON_ITEM" icon="$ICON_WIFI" icon.color="$BLUE" \
    --set "$UP_ITEM" label="$(rate "$TX_RATE")" label.color="$FG" \
    --set "$DOWN_ITEM" label="$(rate "$RX_RATE")" label.color="$FG"
