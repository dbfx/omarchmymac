#!/bin/sh

if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  volume="$INFO"
else
  volume="$(osascript -e 'output volume of (get volume settings)')"
fi

muted="$(osascript -e 'output muted of (get volume settings)')"
if [ "$muted" = "true" ] || [ "$volume" = "0" ]; then
  icon="MUTE"
else
  icon="VOL"
fi

sketchybar --set "$NAME" icon="$icon" label="${volume}%"
