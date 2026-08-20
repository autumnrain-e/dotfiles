#!/usr/bin/env bash

# Nerd Font glyphs used by the bar, rendered with "Symbols Nerd Font Mono"
# (the same fallback font kitty maps its symbol_map range to).
#
# WARNING: these lines contain raw Nerd Font codepoints in the Private Use Area.
# Some editors/tools silently drop them on save. If an icon vanishes, regenerate
# this file with Python using \uXXXX escapes instead of pasting glyphs, and
# verify the bytes survived:
#   bash -c 'source icons.sh; printf %s "$ICON_GHOST"' | hexdump -C

export ICON_GHOST="󰊠"             # U+F02A0 nf-md-ghost
export ICON_CPU=""                # U+F4BC nf-oct-cpu
export ICON_RAM=""                # U+EABE nf-cod-circuit_board
# export ICON_RAM="󰬙"             # U+F0B19 nf-md-alpha_r_box (alt)
# export ICON_RAM="󱤓"             # U+F1913 nf-md-integrated_circuit_chip (alt)
# export ICON_RAM="󰍛"             # U+F035B nf-md-memory (alt)
export ICON_WIFI=""               # U+F1EB nf-fa-wifi
export ICON_WIFI_OFF=""           # U+F127 nf-fa-chain_broken
export ICON_DOT=""                # U+F111 nf-fa-circle (throughput dots)
export ICON_UPLOAD="󰕒"            # U+F0552 nf-md-upload (swap for ICON_DOT in items/wifi.sh)
export ICON_DOWNLOAD="󰇚"          # U+F01DA nf-md-download (ditto)
export ICON_VOLUME_HIGH=""        # U+F028 nf-fa-volume_up
export ICON_VOLUME_LOW=""         # U+F027 nf-fa-volume_down
export ICON_VOLUME_MUTE=""        # U+F026 nf-fa-volume_off
export ICON_BATTERY_100=""        # U+F240 nf-fa-battery_full
export ICON_BATTERY_75=""         # U+F241 nf-fa-battery_three_quarters
export ICON_BATTERY_50=""         # U+F242 nf-fa-battery_half
export ICON_BATTERY_25=""         # U+F243 nf-fa-battery_quarter
export ICON_BATTERY_0=""          # U+F244 nf-fa-battery_empty
export ICON_BATTERY_CHARGING=""   # U+F0E7 nf-fa-bolt
export ICON_CLOCK="󱛡"              # U+F16E1 nf-md-calendar_clock_outline
export ICON_CALENDAR=""           # U+F073 nf-fa-calendar
export ICON_MUSIC=""              # U+F001 nf-fa-music

# --- Application icons (front_app chip) --------------------------------------
# One glyph per app, matched in plugins/front_app.sh against the name macOS
# reports in $INFO on a front_app_switched event.
#
# That name is the bundle's localizedName, which is NOT always the .app
# filename: Docker's window belongs to the INNER Docker Desktop.app, so it
# reports "Docker Desktop", and Chrome reports "Google Chrome" even though its
# CFBundleName is only "Chrome". Read the name an app actually reports with:
#   sketchybar --query front_app.name | jq -r .label.value
export ICON_APP_KITTY="󰄛"                # U+F011B nf-md-cat
export ICON_APP_HELIUM="󰜗"               # U+F0717 nf-md-snowflake
export ICON_APP_GITKRAKEN=""             # U+F2AC  nf-fa-gitkraken
export ICON_APP_DOCKER=""                # U+F21F  nf-fa-docker
export ICON_APP_OBSIDIAN=""              # U+E6BB  nf-custom-obsidian
export ICON_APP_TEAMS="󰊻"                # U+F02BB nf-md-microsoft_teams
export ICON_APP_CHROME=""                # U+F268  nf-fa-chrome
export ICON_APP_PASSWORDS="󱕴"            # U+F1574 nf-md-key_chain
export ICON_APP_EMACS=""                 # U+E632  nf-custom-emacs
export ICON_APP_FINDER="󰀶"               # U+F0036 nf-md-apple_finder
export ICON_APP_PREVIEW="󰈈"             # U+F0208 nf-md-eye
export ICON_APP_CISCO=""               # U+F1E6  nf-fa-plug
export ICON_APP_ELMEDIA=""             # U+F144  nf-fa-circle_play
export ICON_APP_EXCEL="󱎏"              # U+F138F nf-md-microsoft_excel
export ICON_APP_DEFAULT="󰘔"              # U+F0614 nf-md-application_outline (any unmapped app)
# export ICON_APP_DEFAULT="󰣆"            # U+F08C6 nf-md-application (filled alt)
