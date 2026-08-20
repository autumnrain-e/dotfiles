#!/usr/bin/env bash

# $INFO on a media_change event is JSON: { "state": "...", "title": "...",
# "artist": "...", "album": "...", "app": "..." }. Requires jq (in the Brewfile).

STATE="$(echo "$INFO" | jq -r '.state // "stopped"' 2>/dev/null)"

if [ "$STATE" != "playing" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

TITLE="$(echo "$INFO" | jq -r '.title // empty' 2>/dev/null)"
ARTIST="$(echo "$INFO" | jq -r '.artist // empty' 2>/dev/null)"

if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    LABEL="$TITLE — $ARTIST"
else
    LABEL="${TITLE:-$ARTIST}"
fi

if [ -z "$LABEL" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

sketchybar --set "$NAME" drawing=on label="$LABEL"
