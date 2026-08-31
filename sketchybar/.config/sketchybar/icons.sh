#!/usr/bin/env bash

# Nerd Font glyphs used by the bar, rendered with "Symbols Nerd Font Mono"
# (the same fallback font kitty maps its symbol_map range to).
#
# WARNING: these lines contain raw Nerd Font codepoints in the Private Use Area.
# Some editors/tools silently drop them on save. If an icon vanishes, regenerate
# this file with Python using \uXXXX escapes instead of pasting glyphs, and
# verify the bytes survived:
#   bash -c 'source icons.sh; printf %s "$ICON_LOGO"' | hexdump -C

export ICON_LOGO="󰅶"               # U+F0176 nf-md-coffee
# export ICON_LOGO=""             # U+E007  nf-pom-away (alt)
# export ICON_LOGO="󰊠"             # U+F02A0 nf-md-ghost (alt, the original logo glyph)
export ICON_CPU=""                # U+F4BC nf-oct-cpu
export ICON_RAM=""            # U+EFC5  nf-fa-memory
# export ICON_RAM="󰬙"             # U+F0B19 nf-md-alpha_r_box (alt)
# export ICON_RAM="󱤓"             # U+F1913 nf-md-integrated_circuit_chip (alt)
# export ICON_RAM="󰍛"             # U+F035B nf-md-memory (alt)
export ICON_WIFI=""               # U+F1EB nf-fa-wifi
export ICON_WIFI_OFF=""           # U+F127 nf-fa-chain_broken
export ICON_DOT=""                # U+F111 nf-fa-circle (throughput dots)
export ICON_UPLOAD="󱦲"            # U+F19B2 nf-md-arrow_up_thin
export ICON_DOWNLOAD="󱦳"            # U+F19B3 nf-md-arrow_down_thin
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

# Weather emojis (Open-Meteo WMO codes; day/night variants where they exist)
export ICON_WEATHER_SUNNY="☀️"                 # sun
export ICON_WEATHER_NIGHT="🌙"                    # crescent moon
export ICON_WEATHER_PARTLY_CLOUDY="⛅"                # sun behind cloud
export ICON_WEATHER_NIGHT_PARTLY_CLOUDY="☁️"    # cloud
export ICON_WEATHER_CLOUDY="☁️"                 # cloud
export ICON_WEATHER_RAINY="🌧"                    # cloud with rain
export ICON_WEATHER_POURING="🌧"                  # cloud with rain
export ICON_WEATHER_SNOWY="🌨"                    # cloud with snow
export ICON_WEATHER_SNOWY_HEAVY="❄️"            # snowflake
export ICON_WEATHER_LIGHTNING="⛈️"              # thunder cloud
export ICON_WEATHER_FOG="🌫"                      # fog
