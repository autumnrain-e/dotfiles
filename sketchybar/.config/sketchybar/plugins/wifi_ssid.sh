#!/usr/bin/env bash

# Resolves the current SSID and writes it into the Wi-Fi chip's popup item.
#
# Run from the chip's click_script, immediately before the popup is toggled on,
# so the name is already in place when the box appears. It is NOT on a timer:
# the scutil + python3 path below is expensive relative to everything else in
# this bar, and an SSID changes maybe twice a day. That is the whole reason the
# throughput sampler (plugins/wifi.sh) no longer carries this code.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# The popup item declared in items/wifi.sh. Hardcoded rather than $NAME: this
# script is invoked from a click_script, where $NAME is the item that was
# clicked — any of the three that make up the chip.
POPUP_ITEM="wifi.name"

# Resolve the Wi-Fi interface instead of assuming en0 (varies across Macs).
IFACE="$(networksetup -listallhardwareports 2>/dev/null |
    awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; print $2; exit}')"
IFACE="${IFACE:-en0}"

if ! ifconfig "$IFACE" 2>/dev/null | grep -q "status: active"; then
    sketchybar --set "$POPUP_ITEM" \
        icon="$ICON_WIFI_OFF" \
        icon.color="$FG_DIM" \
        label="not connected" \
        label.color="$FG_DIM"
    exit 0
fi

# macOS 14.4+ gates SSID reads behind Location Services, and a process without
# that grant gets the literal string "<redacted>" back rather than an error --
# so an unguarded read renders "<redacted>" in the bar. sketchybar is launched
# from AeroSpace as an unbundled Homebrew binary with no TCC identity, so it can
# not hold the grant and can not prompt for it. Try the gated APIs anyway (they
# work if the permission is ever granted), then fall back to the cached scan
# record, which is not gated.
usable() { [ -n "$1" ] && [ "$1" != "<redacted>" ]; }

SSID="$(networksetup -getairportnetwork "$IFACE" 2>/dev/null |
    sed -n 's/^Current Wi-Fi Network: //p')"

if ! usable "$SSID"; then
    SSID="$(ipconfig getsummary "$IFACE" 2>/dev/null |
        awk -F' SSID : ' '/ SSID : / {print $2; exit}')"
fi

# Last resort: SystemConfiguration keeps the associated AP's scan record under
# CachedScanRecord as a hex-encoded NSKeyedArchiver plist. Its SSID_STR field is
# left intact even when every public API is redacted. Undocumented, so it is
# tried last and any failure just falls through to the generic label below.
if ! usable "$SSID"; then
    SSID="$(echo "show State:/Network/Interface/$IFACE/AirPort" | scutil 2>/dev/null |
        awk '/CachedScanRecord/{sub(/^0x/, "", $NF); print $NF}' |
        /usr/bin/python3 -c '
import binascii, plistlib, sys

blob = sys.stdin.read().strip()
if not blob:
    sys.exit(1)

def uid(ref):
    return ref.data if hasattr(ref, "data") else int(ref)

try:
    objects = plistlib.loads(binascii.unhexlify(blob))["$objects"]
    key = objects.index("SSID_STR")
    for obj in objects:
        if isinstance(obj, dict) and "NS.keys" in obj:
            keys = [uid(k) for k in obj["NS.keys"]]
            if key in keys:
                print(objects[uid(obj["NS.objects"][keys.index(key)])])
                break
except Exception:
    sys.exit(1)
' 2>/dev/null)"
fi

usable "$SSID" || SSID="connected"

sketchybar --set "$POPUP_ITEM" \
    icon="$ICON_WIFI" \
    icon.color="$BLUE" \
    label="$SSID" \
    label.color="$FG"
