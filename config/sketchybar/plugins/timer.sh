#!/bin/sh

source "$CONFIG_DIR/colors.sh"
state="$HOME/.config/omarchy-mac/state/pomodoro-end"
[ -r "$state" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }

end="$(head -n 1 "$state")"
now="$(date +%s)"
remaining=$((end - now))
if [ "$remaining" -le 0 ]; then
  rm -f "$state"
  sketchybar --set "$NAME" drawing=on icon.color="0xff9ece6a" label="DONE"
  exit 0
fi

minutes=$(((remaining + 59) / 60))
sketchybar --set "$NAME" drawing=on icon.color="$ACCENT_COLOR" label="${minutes}m"

