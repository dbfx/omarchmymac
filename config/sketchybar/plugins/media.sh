#!/bin/sh

state="$HOME/.config/omarchy-mac/state/media"
[ -r "$state" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }
IFS='|' read -r player playing track artist < "$state"

if [ -z "$player" ] || [ -z "$track" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

label="$track"
[ -n "$artist" ] && label="$track · $artist"
label="$(printf '%s' "$label" | /usr/bin/cut -c1-34)"
[ "$playing" = "1" ] || label="PAUSED · $label"
sketchybar --set "$NAME" drawing=on label="$label"

