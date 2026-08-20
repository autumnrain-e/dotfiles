#!/usr/bin/env bash

# Sampler for the cpu.* cluster in items/cpu.sh. Runs on cpu.percent's
# update_freq and feeds all four items in a single sketchybar call.
#
# Upstream (FelixKratz/dotfiles) does this in a compiled mach helper reading
# host_statistics() CPU tick deltas. There is no shell equivalent on macOS —
# kern.cp_time is FreeBSD-only and absent here — so this samples over a real
# one-second window instead.

source "$CONFIG_DIR/colors.sh"

# Load that fills the 26px plot. Upstream is literal (100), which wastes most of
# the box: everyday load sits under 30% and never leaves the bottom few pixels.
# At 60 the axis maxes out at 60% and normal variation is actually legible;
# anything above is clamped flat to the top rather than drawn outside the box.
#
# NOTE this is per-series, not per-total. The two graphs are plotted
# independently, so it takes one series at 60% to fill the height — a 60% total
# split 40 user / 20 sys tops out around two thirds. The label is the number to
# read for an exact figure; the graph is for shape.
CPU_GRAPH_FULL_SCALE=60

# -c 2 -w 1 : two samples one second apart. Row 2 is the delta over that second;
#             row 1 is the average since boot and is discarded.
# -n 0      : suppress the per-disk columns. WITHOUT THIS the field indices are
#             wrong — each attached drive prepends three columns (KB/t, tps,
#             MB/s), so us/sy/id shift right and awk silently reads disk
#             throughput as CPU load.
#
# Deliberately not `top -l 2 -n 0`, which reports the same figures with decimal
# precision: measured here, top burns ~0.57s of CPU per sample versus ~0.00s for
# iostat, which spends its second asleep. Paying 30% of a core to draw a CPU
# meter is self-defeating; the cost is integer-percent granularity, which is
# about a quarter of a pixel on a 26px-tall graph.
read -r USER_PCT SYS_PCT USER_FRAC SYS_FRAC < <(
    iostat -c 2 -w 1 -n 0 2>/dev/null | tail -1 |
        awk -v full="${CPU_GRAPH_FULL_SCALE:-100}" '
            # Guard the divisor: a full-scale of 0 would be a division by zero,
            # and awk yields inf rather than failing, which plots as garbage.
            BEGIN { if (full <= 0) full = 100 }
            function scaled(pct) { return pct / full > 1 ? 1 : pct / full }
            { printf "%d %d %.4f %.4f", $1, $2, scaled($1), scaled($2) }
        '
)

# iostat missing or output unparseable — draw a flat line rather than leave the
# graph frozen on stale data.
: "${USER_PCT:=0}" "${SYS_PCT:=0}" "${USER_FRAC:=0}" "${SYS_FRAC:=0}"

TOTAL=$((USER_PCT + SYS_PCT))

# Same thresholds as upstream, mapped onto the Gruvbox palette.
if [ "$TOTAL" -ge 70 ]; then
    COLOR="$RED"
elif [ "$TOTAL" -ge 30 ]; then
    COLOR="$ORANGE"
elif [ "$TOTAL" -ge 10 ]; then
    COLOR="$YELLOW"
else
    COLOR="$FG"
fi

# Busiest process. -c prints the accounting name only (no path, no args) and -r
# sorts by CPU, so row 2 of the output is the winner. Apple's daemons are all
# named com.apple.something — the prefix is pure noise at this width.
TOP_PROC="$(/bin/ps -Aceo pcpu,comm -r 2>/dev/null | sed -n '2p' |
    awk '{ $1=""; sub(/^ +/, ""); print }')"
TOP_PROC="${TOP_PROC#com.apple.}"

# Truncate to fit above the percentage. cpu.top has width=0, so an overlong name
# would spill past the bracket and collide with the wifi chip. ASCII dots only —
# a real ellipsis is a non-ASCII glyph and this file is written as plain text.
if [ "${#TOP_PROC}" -gt 11 ]; then
    TOP_PROC="${TOP_PROC:0:10}.."
fi

# Graphs take a 0.0–1.0 fraction, not a percentage.
sketchybar --push cpu.user "$USER_FRAC" \
    --push cpu.sys "$SYS_FRAC" \
    --set cpu.percent label="${TOTAL}%" label.color="$COLOR" \
    --set cpu.top label="$TOP_PROC"
