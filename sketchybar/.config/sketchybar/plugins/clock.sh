#!/usr/bin/env bash

# Feeds both lines of the clock chip (items/clock.sh).
#
# Runs from clock.time, the line that owns the box and the update_freq, and names
# its sibling explicitly: $NAME would only ever reach one of the two.
#
# One date(1) call, split on a separator, rather than two calls — two would let
# the day and the time come from different seconds, which across midnight reads
# as yesterday's date beside 12:00 AM until the next tick.
#
# Both formats are fixed-length by construction (%a/%b are always 3 characters,
# %d/%I are zero-padded to 2), which is what lets items/clock.sh pin label.width
# without risking a clip. %I not %H for the 12-hour reading with %p.
#
# Previous single-chip version, kept for the revert path documented in
# items/status.sh:
#   sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"

DATETIME="$(date '+%a %d %b|%I:%M %p')"

sketchybar --set clock.date label="${DATETIME%%|*}" \
           --set clock.time label="${DATETIME##*|}"
