#!/usr/bin/env bash

# RAM chip: circuit-board glyph + percent used, e.g.   55%
#
# A plain single item, not a cluster — so unlike the cpu, wifi and clock chips it
# needs no bracket and no gap items, and its own item-level padding IS the right
# spacing mechanism here: a plain item's background excludes its padding, whereas
# a bracket swallows its members' padding into the box (see the long CPU_GAP note
# in items/cpu.sh for those measurements).
#
# It lives in its own file purely for ORDER. Right items are added right-to-left,
# so a chip's position is decided by where sketchybarrc sources it: this file
# sits between items/wifi.sh and items/cpu.sh, which lands ram between the cpu
# and wifi chips. Folding it into status.sh would park it beside volume instead.

# Matches STATUS_GAP in status.sh, SPACE_GAP in spaces.sh, and CPU_GAP/WIFI_GAP.
# Adjacent chips each contribute their own, so the visible gap is 2x this.
RAM_GAP=3

# Memory moves far slower than CPU and the sampler is a single instant vm_stat
# read (no sampling window to pay for), so 15s is plenty; system_woke catches the
# jump across a sleep. The label is left unpinned, like volume and battery — it
# only changes width crossing 100%, and pinning it would clip rather than grow.
#
# Only background.color/drawing are set: corner_radius and height come from the
# --default block in sketchybarrc, which is what keeps this box identical to the
# volume, workspace and front_app chips. Do not re-specify them here.
sketchybar --add item ram right \
    --set ram \
    update_freq=15 \
    icon="$ICON_RAM" \
    icon.color="$AQUA" \
    padding_left="$RAM_GAP" \
    padding_right="$RAM_GAP" \
    background.color="$GROUP_BG" \
    background.drawing=on \
    script="$CONFIG_DIR/plugins/ram.sh" \
    --subscribe ram system_woke
