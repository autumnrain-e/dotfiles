#!/usr/bin/env bash

# Drives both halves of the front_app chip from one front_app_switched event.
#
# $INFO holds the focused app's name. It is the bundle's localizedName, which is
# not always the .app filename — the aliases below cover the two that differ on
# this machine (Docker's window comes from the inner Docker Desktop.app, and
# Chrome's CFBundleName is only "Chrome"). To add an app, read the name it
# actually reports while it is focused:
#   sketchybar --query front_app.name | jq -r .label.value
# then add a glyph to icons.sh and a branch here.
#
# Attached to front_app.name, but sets front_app.icon by name as well, so the
# glyph and the name are always written together and cannot drift apart.
#
# icons.sh is re-sourced because sketchybar runs every plugin as a fresh
# process — it does not inherit the config's shell.

source "$CONFIG_DIR/icons.sh"

[ "$SENDER" = "front_app_switched" ] || exit 0

case "$INFO" in
"kitty") icon="$ICON_APP_KITTY" ;;
"Helium") icon="$ICON_APP_HELIUM" ;;
"GitKraken") icon="$ICON_APP_GITKRAKEN" ;;
"Docker Desktop" | "Docker") icon="$ICON_APP_DOCKER" ;;
"Obsidian") icon="$ICON_APP_OBSIDIAN" ;;
"Microsoft Teams" | "MSTeams") icon="$ICON_APP_TEAMS" ;;
"Google Chrome" | "Chrome") icon="$ICON_APP_CHROME" ;;
"Passwords") icon="$ICON_APP_PASSWORDS" ;;
"Emacs") icon="$ICON_APP_EMACS" ;;
"Finder") icon="$ICON_APP_FINDER" ;;
"Preview") icon="$ICON_APP_PREVIEW" ;;
"Cisco Secure Client") icon="$ICON_APP_CISCO" ;;
"Elmedia Player") icon="$ICON_APP_ELMEDIA" ;;
"Microsoft Excel" | "Excel") icon="$ICON_APP_EXCEL" ;;
# Unmapped apps get the generic glyph rather than keeping the previous app's,
# which would be worse than no icon at all — it would name one app and picture
# another.
*) icon="$ICON_APP_DEFAULT" ;;
esac

sketchybar --set front_app.name label="$INFO" \
    --set front_app.icon icon="$icon"
