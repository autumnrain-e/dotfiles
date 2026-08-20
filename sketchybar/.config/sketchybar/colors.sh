#!/usr/bin/env bash

# Gruvbox Material Dark Hard palette for SketchyBar.
# Colors are 0xAARRGGBB — alpha FIRST, same convention as JankyBorders.
# Source of truth: kitty/.config/kitty/Gruvbox Material Dark Hard.conf

export BG0=0xff1d2021 # background
export BG1=0xff282828
export BG2=0xff32302f
export BG3=0xff3c3836

export FG=0xffd4be98     # foreground
export FG_DIM=0xff928374 # grey / bright black

export RED=0xffea6962
export GREEN=0xffa9b665
export YELLOW=0xffd8a657
export ORANGE=0xffe78a4e # accent — same value as borders active_color
export BLUE=0xff7daea3
export MAGENTA=0xffd3869b
export AQUA=0xff89b482

export TRANSPARENT=0x00000000

# Semantic aliases used by items/plugins
# BAR_BG is BG0's RGB at 20% alpha (0x33/0xff) — the bar is translucent, so the
# desktop shows through. BG0 itself stays fully opaque; aerospace.sh uses it as
# the focused-workspace icon color, where transparency would wash the digit out.
export BAR_BG=0x331d2021
export ITEM_BG="$BG2"
export GROUP_BG="$BG1"
export ACCENT="$ORANGE"
