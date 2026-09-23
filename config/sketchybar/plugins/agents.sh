#!/bin/sh

source "$CONFIG_DIR/colors.sh"
codex_count="$(/usr/bin/pgrep -x codex 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')"
claude_count="$(/usr/bin/pgrep -x claude 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')"
total=$((codex_count + claude_count))

if [ "$total" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on icon.color="$ACCENT_COLOR" label="$total"
else
  sketchybar --set "$NAME" drawing=off
fi

