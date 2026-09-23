#!/bin/sh

# Pin workspace pills to displays by monitor name (from workspaces.conf).
# sketchybar fires
# display_change before AeroSpace has registered a newly connected monitor, so
# wait (briefly) until both agree on the display count before assigning.
. "$HOME/.config/omarchy-mac/lib/workspaces.sh"

sketchybar_displays() {
  sketchybar --query displays 2>/dev/null | /usr/bin/grep -c '"arrangement-id"'
}

aerospace_monitors() {
  /opt/homebrew/bin/aerospace list-monitors --format '%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null
}

monitor_state=""
attempt=0
while [ "$attempt" -lt 40 ]; do
  monitor_state="$(aerospace_monitors)"
  aerospace_count="$(printf '%s\n' "$monitor_state" | /usr/bin/grep -c .)"
  if [ "$aerospace_count" -gt 0 ] && [ "$aerospace_count" -eq "$(sketchybar_displays)" ]; then
    break
  fi
  attempt=$((attempt + 1))
  sleep 0.5
done

top_display="$(printf '%s\n' "$monitor_state" | /usr/bin/awk -F'|' -v top="$TOP_MONITOR" '$1 == top { print $2; exit }')"
bottom_display="$(printf '%s\n' "$monitor_state" | /usr/bin/awk -F'|' -v bottom="$BOTTOM_MONITOR" '$1 == bottom { print $2; exit }')"

# Laptop-only mode: keep all workspaces reachable on the one available bar.
if [ -z "$top_display" ]; then
  top_display="$bottom_display"
fi
if [ -z "$bottom_display" ]; then
  bottom_display="$top_display"
fi

[ -n "$top_display" ] || exit 0
[ -n "$bottom_display" ] || exit 0

for sid in $(workspaces_on top); do
  sketchybar --set "workspace.$sid" display="$top_display"
done
for sid in $(workspaces_on bottom); do
  sketchybar --set "workspace.$sid" display="$bottom_display"
done
sketchybar --set project display="$top_display"
