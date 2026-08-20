#!/usr/bin/env bash

# Wi-Fi chip: the network icon beside a two-line throughput readout, with the
# network name behind a click-to-open popup.
#
#   [wifi icon]  ● 1.2 MB/s     <- upload, red dot
#                ● 340 KB/s     <- download, blue dot
#
# The SSID used to be the label here. It is now only in the popup: it is the one
# thing on this chip that essentially never changes, so it was spending the
# chip's whole width on a constant.
#
# Three items plus a bracket, in one chip:
#   wifi          the icon; owns the script, the popup, and the mouse events
#   wifi.up       upload line, overlaid on wifi.down via width=0
#   wifi.down     download line — the only one of the two with a real box
#   wifi.name     lives in the popup, not the bar (position popup.wifi)
#
# Added right-to-left like every right item, so the add order below is rightmost
# first: the text stack, then the icon to its left.

# Both lines pin the SAME inner widths, and that is what aligns the dots.
#
# wifi.up is width=0, so its icon+label group is RIGHT-anchored and extends
# leftward (the cpu cluster's caption works the same way). Left-aligning the two
# lines against each other would therefore be impossible with a variable-width
# label: "9 B/s" and "1.2 MB/s" would hang their dots at different x. Pinning
# icon.width and label.width makes both groups exactly the same width, at which
# point the right-anchored line and the boxed line have the same left edge too,
# and the dots sit in a column whatever the numbers do.
#
# It is also what stops the chip resizing — and shoving every chip left of it —
# each time a rate crosses from KB/s to MB/s.
WIFI_DOT_WIDTH=11
# Sized to the widest string plugins/wifi.sh can produce, since a fixed text
# width clips rather than grows. Its formatter is deliberately capped at 8
# characters ("999 KB/s", "9.9 MB/s", "123 MB/s"), which is what makes this 52
# rather than the ~60 a 4-digit KB/s case would have forced — and the difference
# is dead space sitting in the chip at every normal rate.
WIFI_TEXT_WIDTH=52
# Gap between dot and number, measured by eye against the rendered bar rather
# than derived: the 6pt circle's ink is far narrower than the 11px slot it is
# centred in, so the nominal padding reads as roughly half itself on screen. 4
# still had the two touching.
WIFI_DOT_GAP=7

# Matches STATUS_GAP in status.sh and SPACE_GAP in spaces.sh. Held by the two
# zero-drawing gap items below, never by a padding property — see the long note
# on CPU_GAP in items/cpu.sh for the measurements: a bracket ignores its own
# padding_left/right, swallows its members' padding into its box, and shrugs off
# background.padding_* too, so all three leave the chip flush against its
# neighbour. Only a real item holds space a bracket will not absorb.
WIFI_GAP=3

# ~9.5pt is the ceiling here, not a preference: two lines have to fit the 26px
# chip that every other item uses, and 9.5pt Helvetica is ~13px per line, so the
# pair exactly fills it. The dots are 6pt because a filled circle fills its em
# box — at label size it would read as a bullet as tall as the text.
WIFI_LINE_SIZE=9.5
WIFI_DOT_SIZE=6.0

# Extra breathing room between the wifi glyph and the text stack, stacking on top
# of the stack's own icon.padding_left. Deliberately applied to the icon item and
# not to the two lines: those two must stay geometrically IDENTICAL or the dots
# stop lining up, so nudging the stack is the icon's job.
WIFI_ICON_GAP=2

# Right-hand gap, between this chip and volume. Added FIRST so it is the
# rightmost item of the cluster; not a bracket member, or the box would just
# absorb it.
sketchybar --add item wifi.gap.right right \
    --set wifi.gap.right \
    width="$WIFI_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# Upload — the upper line, and the overlay. Added before wifi.down so it is the
# further RIGHT of the two, which is what puts it above wifi.down rather than
# above the icon: a
# zero-width item never advances the layout cursor, so the next item is drawn at
# the same x and the two share a right edge.
#
# Red matches cpu.sys in the cpu cluster, blue below matches cpu.user, so the
# bar's two live meters use one colour language.
sketchybar --add item wifi.up right \
    --set wifi.up \
    width=0 \
    y_offset=6 \
    icon="$ICON_DOT" \
    icon.font="$FONT_ICON:Regular:$WIFI_DOT_SIZE" \
    icon.color="$RED" \
    icon.width="$WIFI_DOT_WIDTH" \
    icon.align=center \
    icon.padding_left=8 \
    icon.padding_right="$WIFI_DOT_GAP" \
    label.font="$FONT_TEXT:$FONT_TEXT_BOLD:$WIFI_LINE_SIZE" \
    label.width="$WIFI_TEXT_WIDTH" \
    label.align=left \
    label.padding_left=0 \
    label.padding_right=8 \
    label="--"

# Download — the lower line, and the item whose box the bracket measures from.
# Identical inner geometry to wifi.up by construction; only y_offset and the dot
# colour differ.
sketchybar --add item wifi.down right \
    --set wifi.down \
    y_offset=-6 \
    icon="$ICON_DOT" \
    icon.font="$FONT_ICON:Regular:$WIFI_DOT_SIZE" \
    icon.color="$BLUE" \
    icon.width="$WIFI_DOT_WIDTH" \
    icon.align=center \
    icon.padding_left=8 \
    icon.padding_right="$WIFI_DOT_GAP" \
    label.font="$FONT_TEXT:$FONT_TEXT_BOLD:$WIFI_LINE_SIZE" \
    label.width="$WIFI_TEXT_WIDTH" \
    label.align=left \
    label.padding_left=0 \
    label.padding_right=8 \
    label="--" \
    click_script="\"\$CONFIG_DIR/plugins/wifi_ssid.sh\"; sketchybar --set wifi popup.drawing=toggle"

# The icon, and the item that owns everything behavioural: one script drives all
# three labels, and the popup hangs off this item.
#
# Only mouse.exited.global is subscribed, never plain mouse.exited — the chip is
# three items, so moving the pointer from the icon onto the readout is an "exit"
# of this item and would shut the popup halfway across the chip that opened it.
# Leaving the bar entirely is the honest "mouse is off it" signal.
sketchybar --add item wifi right \
    --set wifi \
    update_freq=2 \
    icon="$ICON_WIFI" \
    icon.color="$BLUE" \
    label.drawing=off \
    icon.padding_right="$WIFI_ICON_GAP" \
    popup.align=center \
    popup.height=30 \
    popup.y_offset=-4 \
    popup.background.color="$GROUP_BG" \
    popup.background.corner_radius=6 \
    popup.background.border_width=1 \
    popup.background.border_color="$BG3" \
    script="$CONFIG_DIR/plugins/wifi.sh" \
    click_script="\"\$CONFIG_DIR/plugins/wifi_ssid.sh\"; sketchybar --set wifi popup.drawing=toggle" \
    --subscribe wifi wifi_change system_woke mouse.exited.global

# The popup's only content. Resolved on click by plugins/wifi_ssid.sh rather
# than on a timer, so the expensive scutil/python fallback runs when the name is
# actually being looked at. Clicking it dismisses, same as clicking the chip.
sketchybar --add item wifi.name popup.wifi \
    --set wifi.name \
    icon="$ICON_WIFI" \
    icon.color="$BLUE" \
    icon.padding_left=10 \
    icon.padding_right=6 \
    label="looking up..." \
    label.padding_right=12 \
    background.drawing=off \
    click_script="sketchybar --set wifi popup.drawing=off"

# Left-hand gap, between this chip and the cpu cluster. Added LAST so it is the
# leftmost item; its 3px meets cpu.gap.right's 3px for a 6px gap, the same total
# two plain chips get from their own padding.
sketchybar --add item wifi.gap.left right \
    --set wifi.gap.left \
    width="$WIFI_GAP" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

# One box behind the three bar items. A bracket is right here for the same
# reason it is right for the cpu cluster and wrong for the workspace chips:
# these three genuinely are one element. Only colour/drawing are set —
# corner_radius and height come from the --default block in sketchybarrc.
#
# The gap items are not members; a member spacer would fall inside the box.
sketchybar --add bracket wifi.group wifi wifi.up wifi.down \
    --set wifi.group \
    background.color="$GROUP_BG" \
    background.drawing=on
