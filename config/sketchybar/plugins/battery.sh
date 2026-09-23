#!/bin/sh

percentage="$(pmset -g batt | /usr/bin/grep -Eo '[0-9]+%' | /usr/bin/head -1)"
charging="$(pmset -g batt | /usr/bin/grep -c 'AC Power')"

[ -n "$percentage" ] || exit 0

if [ "$charging" -gt 0 ]; then
  icon="PWR"
else
  icon="BAT"
fi

sketchybar --set "$NAME" icon="$icon" label="$percentage"
