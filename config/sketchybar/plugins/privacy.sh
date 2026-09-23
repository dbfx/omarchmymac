#!/bin/sh

source "$CONFIG_DIR/colors.sh"
state="$HOME/.config/omarchy-mac/state/privacy"
[ -r "$state" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }
IFS='|' read -r mic camera < "$state"

label=""
[ "$mic" = "1" ] && label="MIC"
if [ "$camera" = "1" ]; then
  [ -n "$label" ] && label="$label + CAM" || label="CAM"
fi

if [ -n "$label" ]; then
  sketchybar --set "$NAME" drawing=on icon="REC" icon.color="0xfff7768e" label="$label"
else
  sketchybar --set "$NAME" drawing=off
fi

