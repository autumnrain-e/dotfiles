#!/usr/bin/env bash

# Single-line clock: "Tuesday, August 30   4:52pm"
#
# One date(1) call, split on a separator — two calls would let the day and the
# time come from different seconds, which across midnight reads as yesterday's
# date beside 12:00am until the next tick.
#
# macOS BSD date has no %-d / %-I, so strip a leading zero from the hour in
# the shell, and lowercase %p (AM/PM) to match the reference layout.

IFS='|' read -r DATE_PART HOUR MIN AMPM <<< "$(date '+%A, %B %d|%I|%M|%p')"
HOUR="${HOUR#0}"
AMPM="$(printf '%s' "$AMPM" | tr '[:upper:]' '[:lower:]')"

sketchybar --set "$NAME" label="${DATE_PART}   ${HOUR}:${MIN}${AMPM}"
