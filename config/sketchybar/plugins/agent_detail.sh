#!/bin/sh

process="$1"
source "$CONFIG_DIR/colors.sh"
count="$(/usr/bin/pgrep -x "$process" 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')"

if [ "$count" -gt 0 ]; then
  sketchybar --set "$NAME" icon.color="$ACCENT_COLOR" label="$count running"
else
  sketchybar --set "$NAME" icon.color="$MUTED_COLOR" label="idle"
fi

