#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Memory used as a percentage of installed RAM, in Activity Monitor's sense:
# active + wired + compressor-occupied pages. Inactive and speculative pages are
# cached data the kernel hands back on demand, so counting them as used would
# peg the chip near full permanently.
#
# vm_stat is a single instant counter read (~5ms, no sample window) — unlike the
# cpu sampler, which has to spend a real second inside iostat. Deliberately NOT
# `memory_pressure`: measured here it costs ~0.22s per tick, and its "System-wide
# memory free percentage" counts inactive pages as free — it reported 85% free
# on the same machine, at the same moment, that this reports 56% used.
#
# Field indices, from vm_stat's own output (the trailing "." on each count is
# harmless — awk coerces "871664." to 871664):
#   ... (page size of 16384 bytes)          -> $8
#   Pages active:                  871664.  -> $3
#   Pages wired down:              157875.  -> $4
#   Pages occupied by compressor:  144690.  -> $5
RAM_USAGE="$(vm_stat 2>/dev/null | awk -v total="$(sysctl -n hw.memsize)" '
    /page size of/                  { page   = $8 }
    /^Pages active/                 { active = $3 }
    /^Pages wired down/             { wired  = $4 }
    /^Pages occupied by compressor/ { comp   = $5 }
    END {
        # Guard the divisor: awk yields inf rather than failing on a divide by
        # zero, and inf would print as a nonsense label instead of an error.
        if (total <= 0 || page <= 0) exit
        printf "%.0f", (active + wired + comp) * page * 100 / total
    }')"

# vm_stat missing or unparseable — show the glyph dimmed with a placeholder
# rather than a bogus number or a silently stale one.
case "$RAM_USAGE" in
'' | *[!0-9]*)
    sketchybar --set "$NAME" icon.color="$FG_DIM" label="--"
    exit 0
    ;;
esac

# macOS runs memory hot by design — a healthy machine sits well above half, and
# the compressor absorbs a lot before anything actually swaps — so these
# thresholds sit much higher than the cpu chip's 70/30/10.
#
# The resting colour is AQUA rather than FG: it is the one palette entry no other
# item claims (clock and wifi take BLUE, media MAGENTA, the logo YELLOW, wifi's
# upload dot RED), so the chip is identifiable at a glance without competing with
# its neighbours. Only the ICON is coloured — the label inherits FG from the
# --default block, which is what every other chip does.
if [ "$RAM_USAGE" -ge 90 ]; then
    COLOR="$RED"
elif [ "$RAM_USAGE" -ge 80 ]; then
    COLOR="$ORANGE"
elif [ "$RAM_USAGE" -ge 65 ]; then
    COLOR="$YELLOW"
else
    COLOR="$AQUA"
fi

sketchybar --set "$NAME" \
    icon.color="$COLOR" \
    label="${RAM_USAGE}%"
