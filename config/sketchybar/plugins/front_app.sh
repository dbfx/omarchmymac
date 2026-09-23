#!/bin/sh

if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
  app="$INFO"
else
  app="$(/opt/homebrew/bin/aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
fi

[ -n "$app" ] || app="Desktop"
sketchybar --set "$NAME" label="$app"
