#!/bin/sh

status="$(/usr/bin/lsappinfo info -only StatusLabel -app Slack 2>/dev/null)"
unread="$(printf '%s' "$status" | /usr/bin/sed -n 's/.*"label"="\([^"]*\)".*/\1/p')"

case "$unread" in
  ""|0) sketchybar --set "$NAME" drawing=off ;;
  *) sketchybar --set "$NAME" drawing=on label="$unread" ;;
esac
