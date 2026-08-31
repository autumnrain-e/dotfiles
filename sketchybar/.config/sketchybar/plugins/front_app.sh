#!/usr/bin/env bash

# Sets the focused-app name from a front_app_switched event.
#
# $INFO is the bundle's localizedName, which is not always the .app filename
# (Docker's window comes from the inner Docker Desktop.app, Chrome reports
# "Google Chrome"). Read a new app's real name with:
#   sketchybar --query front_app.name | jq -r .label.value

[ -n "$INFO" ] || exit 0

sketchybar --set "$NAME" label="$INFO"
