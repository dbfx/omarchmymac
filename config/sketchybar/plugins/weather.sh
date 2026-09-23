#!/bin/sh

# wttr.in uses the network's approximate location, avoiding a stored location
# or an Apple WeatherKit developer credential.
weather="$(/usr/bin/curl -fsS --max-time 5 'https://wttr.in/?format=%c%20%t' 2>/dev/null | /usr/bin/tr -d '\n')"
[ -n "$weather" ] || weather="--"

sketchybar --set "$NAME" label="$weather"
