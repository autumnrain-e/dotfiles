#!/usr/bin/env bash

# Current temperature (°C) and a condition glyph from Open-Meteo.
# No API key. Location comes from IP geolocation, cached for 24h.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

LOC_FILE="${TMPDIR:-/tmp}/sketchybar_weather.loc"
NOW="$(date +%s)"

fail() {
    sketchybar --set "$NAME" \
        icon="$ICON_WEATHER_CLOUDY" \
        icon.color=0xffffffff \
        label="--" \
        label.color="$ACCENT"
    exit 0
}

# Cached "lat lon ts". Refresh once a day, or when missing.
LAT=""
LON=""
if [ -r "$LOC_FILE" ]; then
    read -r LAT LON TS <"$LOC_FILE"
    if [ -z "$TS" ] || [ $((NOW - TS)) -gt 86400 ]; then
        LAT=""
        LON=""
    fi
fi

if [ -z "$LAT" ] || [ -z "$LON" ]; then
    # ipinfo.io first (HTTPS); ip-api.com as HTTP fallback. Either is enough
    # to feed Open-Meteo; sketchybar has no CoreLocation TCC identity.
    GEO="$(curl -sf --max-time 4 "https://ipinfo.io/json" 2>/dev/null || true)"
    LAT="$(printf '%s' "$GEO" | jq -r '.loc | split(",")[0] // empty' 2>/dev/null)"
    LON="$(printf '%s' "$GEO" | jq -r '.loc | split(",")[1] // empty' 2>/dev/null)"
    if [ -z "$LAT" ] || [ -z "$LON" ]; then
        GEO="$(curl -sf --max-time 4 "http://ip-api.com/json/?fields=status,lat,lon" 2>/dev/null || true)"
        LAT="$(printf '%s' "$GEO" | jq -r 'select(.status=="success") | .lat' 2>/dev/null)"
        LON="$(printf '%s' "$GEO" | jq -r 'select(.status=="success") | .lon' 2>/dev/null)"
    fi
    case "$LAT" in
    '' | *[!0-9.+-]*) fail ;;
    esac
    case "$LON" in
    '' | *[!0-9.+-]*) fail ;;
    esac
    printf '%s %s %s\n' "$LAT" "$LON" "$NOW" >"$LOC_FILE"
fi

WX="$(curl -sf --max-time 4 \
    "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day&timezone=auto" \
    2>/dev/null)" || fail

read -r TEMP CODE IS_DAY < <(printf '%s' "$WX" | jq -r '
    .current as $c
    | if ($c.temperature_2m == null) or ($c.weather_code == null) then empty
      else "\($c.temperature_2m) \($c.weather_code) \($c.is_day // 1)"
      end' 2>/dev/null)

[ -n "$TEMP" ] && [ -n "$CODE" ] || fail

DAY=1
[ "$IS_DAY" = "0" ] && DAY=0

# WMO codes: https://open-meteo.com/en/docs  (Weather interpretation codes)
ICON="$ICON_WEATHER_CLOUDY"
case "$CODE" in
0)
    if [ "$DAY" -eq 1 ]; then ICON="$ICON_WEATHER_SUNNY"
    else ICON="$ICON_WEATHER_NIGHT"
    fi
    ;;
1 | 2)
    if [ "$DAY" -eq 1 ]; then ICON="$ICON_WEATHER_PARTLY_CLOUDY"
    else ICON="$ICON_WEATHER_NIGHT_PARTLY_CLOUDY"
    fi
    ;;
3) ICON="$ICON_WEATHER_CLOUDY" ;;
45 | 48) ICON="$ICON_WEATHER_FOG" ;;
51 | 53 | 55 | 56 | 57 | 61 | 63 | 80 | 81) ICON="$ICON_WEATHER_RAINY" ;;
65 | 66 | 67 | 82) ICON="$ICON_WEATHER_POURING" ;;
71 | 73 | 77 | 85) ICON="$ICON_WEATHER_SNOWY" ;;
75 | 86) ICON="$ICON_WEATHER_SNOWY_HEAVY" ;;
95 | 96 | 99) ICON="$ICON_WEATHER_LIGHTNING" ;;
esac

TEMP_C="$(printf '%.0f' "$TEMP" 2>/dev/null)" || fail

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color=0xffffffff \
    label="${TEMP_C}°C" \
    label.color="$ACCENT"
