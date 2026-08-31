#!/usr/bin/env bash

# Now playing via media-control (https://github.com/ungive/media-control).
# SketchyBar's built-in media_change event is deprecated on macOS 26 and does
# not fire here (26.6.2). media-control talks to MediaRemote directly.
#
# Playing: a 0.1s equalizer loop in plugins/media_anim.sh writes the icon.
# Paused: nf-fa-pause, title stays. Nothing now-playing: hide, including the pipe.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

FONT_ICON="${FONT_ICON:-Symbols Nerd Font Mono}"
FONT_TEXT="${FONT_TEXT:-Noto Sans Mono}"
FONT_TEXT_REGULAR="${FONT_TEXT_REGULAR:-Regular}"
MEDIA_CTL="/opt/homebrew/bin/media-control"

PID_FILE="${TMPDIR:-/tmp}/sketchybar_media_anim.pid"

stop_anim() {
    if [ -r "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE")"
        rm -f "$PID_FILE"
        if [ -n "$pid" ]; then
            kill "$pid" 2>/dev/null
            i=0
            while [ "$i" -lt 10 ] && kill -0 "$pid" 2>/dev/null; do
                sleep 0.05
                i=$((i + 1))
            done
            kill -9 "$pid" 2>/dev/null
        fi
    fi
}

start_anim() {
    if [ -r "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE")"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return
        fi
    fi
    stop_anim
    # nohup + redirect so the plugin's exit does not SIGHUP the loop.
    /usr/bin/nohup "$CONFIG_DIR/plugins/media_anim.sh" >/dev/null 2>&1 &
    echo $! >"$PID_FILE"
}

hide() {
    stop_anim
    sketchybar --set "$NAME" drawing=off --set sep.cpu drawing=off
    exit 0
}

DATA="$("$MEDIA_CTL" get --no-artwork 2>/dev/null)" || hide
[ -n "$DATA" ] && [ "$DATA" != "null" ] || hide

PLAYING="$(printf '%s' "$DATA" | jq -r '.playing // false' 2>/dev/null)"
TITLE="$(printf '%s' "$DATA" | jq -r '.title // empty' 2>/dev/null)"
ARTIST="$(printf '%s' "$DATA" | jq -r '.artist // empty' 2>/dev/null)"

case "$TITLE" in
null) TITLE="" ;;
esac
case "$ARTIST" in
null) ARTIST="" ;;
esac

if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    LABEL="$TITLE — $ARTIST"
else
    LABEL="${TITLE:-$ARTIST}"
fi

if [ "$PLAYING" = "true" ]; then
    start_anim
    sketchybar --set "$NAME" \
        drawing=on \
        icon.font="$FONT_TEXT:$FONT_TEXT_REGULAR:13.0" \
        icon.color="$ACCENT" \
        label="$LABEL" \
        label.drawing=on \
        --set sep.cpu drawing=on
elif [ -n "$LABEL" ]; then
    stop_anim
    sketchybar --set "$NAME" \
        drawing=on \
        icon="$ICON_PAUSE" \
        icon.font="$FONT_ICON:Regular:16.0" \
        icon.color="$ACCENT" \
        label="$LABEL" \
        label.drawing=on \
        --set sep.cpu drawing=on
else
    hide
fi
