#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Sum every process's %CPU and normalize by thread count. Cheap and instant —
# `top -l 2` would be more accurate but costs a full sampling interval on every
# tick (update_freq=5).
CORE_COUNT="$(sysctl -n machdep.cpu.thread_count)"
CPU_USAGE="$(ps -Aeo pcpu | tail -n +2 |
    awk -v cores="${CORE_COUNT:-1}" '{sum+=$1} END {printf "%.0f", sum/cores}')"

sketchybar --set "$NAME" \
    icon.color="$ACCENT" \
    label.color="$ACCENT" \
    label="${CPU_USAGE}%"
