#!/usr/bin/env bash

# Right-hand status cluster: volume (battery is commented out below).
#
# `cpu`, `wifi` and `clock` used to live here as plain icon+label chips. All
# three are now multi-item clusters with their own files — items/cpu.sh (graphs,
# ported from FelixKratz/dotfiles), items/wifi.sh (two-line throughput + SSID
# popup) and items/clock.sh (date over time). The old single-chip versions are
# commented out at the bottom of this file and their original plugins are intact
# or preserved in a comment, so any of them can be reverted by uncommenting the
# block and dropping the matching `source` line from sketchybarrc.
#
# Right items are added right-to-left, so what is added first is rightmost —
# which is why items/clock.sh is sourced ahead of this file. Everything here is
# event-driven where sketchybar provides an event, and polled only where it
# doesn't (cpu, and wifi as a safety net).
#
# Each item draws its own rounded chip rather than sharing one bracket. Only
# background.color and background.drawing are set per item — corner_radius and
# height come from the --default block in sketchybarrc, which is what keeps
# these boxes identical to the logo, workspace and front_app chips. Do not
# re-specify them here; a second source of truth is how they drift apart.
#
# Spacing: item-level padding_left/right is the gap OUTSIDE the chip. Adjacent
# chips each contribute their own, so the visible gap is 2x STATUS_GAP. Matches
# SPACE_GAP in spaces.sh so both clusters breathe the same.
STATUS_GAP=3

# --- Battery chip (hidden on purpose, 2026-08-14) ----------------------------
# Commented out rather than deleted: plugins/battery.sh is untouched on disk and
# still correct (it even hides itself on a machine with no battery), so this is a
# one-line revert. To bring it back, uncomment the block below — nothing else
# references it, and it lands right of volume exactly as before, because right
# items are added right-to-left and this is the first one added in this file.
#
# sketchybar --add item battery right \
#     --set battery \
#     update_freq=120 \
#     padding_left="$STATUS_GAP" \
#     padding_right="$STATUS_GAP" \
#     background.color="$GROUP_BG" \
#     background.drawing=on \
#     script="$CONFIG_DIR/plugins/battery.sh" \
#     --subscribe battery power_source_change system_woke

sketchybar --add item volume right \
    --set volume \
    padding_left="$STATUS_GAP" \
    padding_right="$STATUS_GAP" \
    background.color="$GROUP_BG" \
    background.drawing=on \
    script="$CONFIG_DIR/plugins/volume.sh" \
    --subscribe volume volume_change

# --- Previous clock chip (superseded by items/clock.sh) ----------------------
# Single chip, clock glyph + "Mon 10 Aug  11:07" on one line. The chip now shows
# the date over the time in two lines with no glyph, which needs two items — hence
# its own file, like the cpu and wifi clusters.
#
# To go back: uncomment this, remove the items/clock.sh source line from
# sketchybarrc, and restore the one-line writer in plugins/clock.sh (kept in a
# comment at the top of that file).
#
# sketchybar --add item clock right \
#     --set clock \
#     update_freq=30 \
#     icon="$ICON_CLOCK" \
#     icon.color="$BLUE" \
#     padding_left="$STATUS_GAP" \
#     padding_right="$STATUS_GAP" \
#     background.color="$GROUP_BG" \
#     background.drawing=on \
#     script="$CONFIG_DIR/plugins/clock.sh"

# --- Previous wifi chip (superseded by items/wifi.sh) ------------------------
# Single chip, icon + SSID label. The SSID now lives in a popup and the chip
# shows upload/download instead, which needs three items and a bracket — hence
# its own file, like the cpu cluster.
#
# To go back: uncomment this, remove the items/wifi.sh source line from
# sketchybarrc, and restore the SSID write at the end of plugins/wifi.sh (that
# code is intact in plugins/wifi_ssid.sh, which sets wifi.name instead).
#
# sketchybar --add item wifi right \
#     --set wifi \
#     update_freq=60 \
#     padding_left="$STATUS_GAP" \
#     padding_right="$STATUS_GAP" \
#     background.color="$GROUP_BG" \
#     background.drawing=on \
#     script="$CONFIG_DIR/plugins/wifi.sh" \
#     --subscribe wifi wifi_change system_woke

# --- Previous cpu chip (superseded by items/cpu.sh) --------------------------
# Single chip, icon + percentage, driven by plugins/cpu.sh (still on disk).
# To go back: uncomment this, and remove the items/cpu.sh source line from
# sketchybarrc. Nothing else references the graph cluster.
#
# sketchybar --add item cpu right \
#     --set cpu \
#     update_freq=5 \
#     icon="$ICON_CPU" \
#     icon.color="$GREEN" \
#     padding_left="$STATUS_GAP" \
#     padding_right="$STATUS_GAP" \
#     background.color="$GROUP_BG" \
#     background.drawing=on \
#     script="$CONFIG_DIR/plugins/cpu.sh"
