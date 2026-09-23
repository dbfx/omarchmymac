#!/bin/sh

source "$CONFIG_DIR/colors.sh"
state="$HOME/.config/omarchy-mac/state/build-status"
[ -r "$state" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }

IFS='|' read -r status project stamp < "$state"
now="$(date +%s)"
age=$((now - ${stamp:-0}))

case "$status" in
  RUN) color="$ACCENT_COLOR"; label="RUN · $project" ;;
  PASS) color="0xff9ece6a"; label="PASS · $project" ;;
  FAIL) color="0xfff7768e"; label="FAIL · $project" ;;
  NONE) color="$MUTED_COLOR"; label="NO TEST · $project" ;;
  *) sketchybar --set "$NAME" drawing=off; exit 0 ;;
esac

if [ "$status" != "RUN" ] && [ "$age" -gt 1800 ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on icon.color="$color" label="$label"
fi

