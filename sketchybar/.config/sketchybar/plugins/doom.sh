#!/usr/bin/env bash

# Cycles the logo chip through assets/doom/<N>_<label>/doom_guy_*.png.
#
# On sketchybar --reload the item file wipes the state, so we always start at
# folder 0 frame 0. Routine ticks advance one frame; non-last frames use
# update_freq=5, the last frame of a folder holds for 180s, then the next
# folder starts at frame 0. After folder 4 it wraps to 0.
#
# Faces are already knocked-out 32px sprites (scripts/prepare-doom-faces.py);
# this script only swaps background.image. Distinct paths, so no cache-bust.

ASSETS="$CONFIG_DIR/assets/doom"
STATE="${TMPDIR:-/tmp}/sketchybar_doom.state"
FRAME_SEC=5
HOLD_SEC=180

folders=()
while IFS= read -r dir; do
    folders+=("$dir")
done < <(find "$ASSETS" -mindepth 1 -maxdepth 1 -type d | sort)

nfolders=${#folders[@]}
if [ "$nfolders" -eq 0 ]; then
    exit 0
fi

load_frames() {
    frames=()
    while IFS= read -r png; do
        frames+=("$png")
    done < <(find "$1" -maxdepth 1 -name 'doom_guy_*.png' | sort -V)
}

folder_idx=0
frame_idx=0
if [ -f "$STATE" ]; then
    read -r folder_idx frame_idx < "$STATE"
fi

# Guard a stale state file (folder renamed, count changed).
if [ "$folder_idx" -ge "$nfolders" ] || [ "$folder_idx" -lt 0 ]; then
    folder_idx=0
    frame_idx=0
fi

load_frames "${folders[$folder_idx]}"
nframes=${#frames[@]}
if [ "$nframes" -eq 0 ]; then
    exit 0
fi
if [ "$frame_idx" -ge "$nframes" ] || [ "$frame_idx" -lt 0 ]; then
    frame_idx=0
fi

# Init / forced refresh keeps the current frame. Only the timer advances,
# otherwise a reload would skip frame 0 the moment the item is added.
if [ -f "$STATE" ] && [ "$SENDER" = "routine" ]; then
    frame_idx=$((frame_idx + 1))
    if [ "$frame_idx" -ge "$nframes" ]; then
        folder_idx=$(((folder_idx + 1) % nfolders))
        frame_idx=0
        load_frames "${folders[$folder_idx]}"
        nframes=${#frames[@]}
        if [ "$nframes" -eq 0 ]; then
            exit 0
        fi
    fi
fi

printf '%s %s\n' "$folder_idx" "$frame_idx" > "$STATE"

if [ "$frame_idx" -eq $((nframes - 1)) ]; then
    freq="$HOLD_SEC"
else
    freq="$FRAME_SEC"
fi

sketchybar --set "$NAME" \
    background.image="${frames[$frame_idx]}" \
    update_freq="$freq"
