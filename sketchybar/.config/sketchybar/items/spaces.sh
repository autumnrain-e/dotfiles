#!/usr/bin/env bash

# Logo + AeroSpace workspace indicators.
#
# Workspaces are read from `aerospace list-workspaces --all`, so they follow
# persistent-workspaces in aerospace.toml automatically — no hardcoded list.
# Highlighting is driven by the aerospace_workspace_change custom event, which
# aerospace.toml fires via exec-on-workspace-change.
#
# Spacing: item-level padding_left/right is the gap OUTSIDE the rounded
# background (what separates one chip from the next); icon.padding_left/right
# is inside it and only makes a chip wider. Adjacent chips each contribute
# their own padding, so the visible gap between two workspaces is 2x SPACE_GAP.

# Gap outside each workspace chip; adjacent chips each contribute one, so
# the visible gap between two workspaces is 2x SPACE_GAP (4px).
SPACE_GAP=2

# Empty item on each end of the workspace row. Together with the adjacent
# workspace's SPACE_GAP this is the visible gap: 8+2=10, same on the logo
# side and the app-chip side. A spacer is required on the logo side because
# the pinned width=35 swallows the item's own padding_right (the ghost
# never hit this — its width was dynamic, so LOGO_GAP used to work).
SPACE_EDGE=8

# Fixed chip width. Digit glyphs do not all advance the same amount here (a "1"
# measures narrower than a "2"), so letting the box auto-size gives uneven
# chips. Pinning icon.width with icon.align=center makes every workspace box
# identical regardless of its label — and keeps them even if a workspace is
# ever named something wider than one character.
SPACE_WIDTH=28

# Ghost glyph — kept for revert. Uncomment this block, comment out the
# doom `--add` below, KEEP logo_separator. padding_right must stay 0:
# restoring the old LOGO_GAP=10 stacks on SPACE_EDGE and the left gap
# becomes 20px. 0 + SPACE_EDGE + SPACE_GAP = 10, matching the app-chip end.
# sketchybar --add item logo left \
#     --set logo \
#     padding_right=0 \
#     icon="$ICON_GHOST" \
#     icon.color="$YELLOW" \
#     icon.padding_left=10 \
#     icon.padding_right=10 \
#     label.drawing=off \
#     background.color="$GROUP_BG" \
#     background.corner_radius=6 \
#     background.height=26 \
#     background.drawing=on \
#     click_script="open -a 'System Settings'"

# Doom face cycle. Same GROUP_BG / 35pt chip as the ghost; each frame is a
# 32px nearest-neighbour sprite at scale 0.75 = 24pt, with 6pt left pad so
# it sits centred in the box instead of hugging the left edge.
# Assets: $CONFIG_DIR/assets/doom/<N>_<label>/doom_guy_*.png (prepared by
# scripts/prepare-doom-faces.py). plugins/doom.sh walks folder 0's frames
# every 5s, holds the last one for 3 minutes, then folder 1, wrapping after 4.
# Wiping the state file here is what makes --reload restart at folder 0 frame 0.
# Static revert: drop the script/update_freq lines and point background.image
# at assets/doom.png (the old single face; source is doom-src.png).
rm -f "${TMPDIR:-/tmp}/sketchybar_doom.state"
sketchybar --add item logo left \
    --set logo \
    padding_right=0 \
    icon.drawing=off \
    label.drawing=off \
    width=35 \
    background.color="$GROUP_BG" \
    background.drawing=on \
    background.image="$CONFIG_DIR/assets/doom/0_full_health/doom_guy_0.png" \
    background.image.drawing=on \
    background.image.scale=0.75 \
    background.image.padding_left=6 \
    update_freq=5 \
    script="$CONFIG_DIR/plugins/doom.sh" \
    click_script="open -a 'System Settings'"

# Same construction as space_separator at the other end of the row.
sketchybar --add item logo_separator left \
    --set logo_separator \
    icon.drawing=off \
    label.drawing=off \
    width="$SPACE_EDGE"

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space."$sid" left \
        --subscribe space."$sid" aerospace_workspace_change \
        --set space."$sid" \
        padding_left="$SPACE_GAP" \
        padding_right="$SPACE_GAP" \
        icon="$sid" \
        icon.font="$FONT_TEXT:$FONT_TEXT_BOLD:13.0" \
        icon.width="$SPACE_WIDTH" \
        icon.align=center \
        icon.padding_left=0 \
        icon.padding_right=0 \
        label.drawing=off \
        background.color="$GROUP_BG" \
        background.drawing=on \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done

# Breathing room between the workspaces and the focused-app name.
# width is SPACE_EDGE so this gap equals logo-to-workspace-1.
sketchybar --add item space_separator left \
    --set space_separator \
    icon.drawing=off \
    label.drawing=off \
    width="$SPACE_EDGE"
