#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Older macOS versions expose this state directly. On newer versions Apple
# keeps Focus private, so the item remains a reliable shortcut to Focus settings.
active="$(defaults -currentHost read com.apple.notificationcenterui doNotDisturb 2>/dev/null)"
if [ "$active" = "1" ]; then
  sketchybar --set "$NAME" icon.color="$ACCENT_COLOR" background.border_width=1 background.border_color="$ACCENT_COLOR"
else
  sketchybar --set "$NAME" icon.color="$MUTED_COLOR" background.border_width=0
fi
