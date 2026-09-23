#!/bin/sh

source "$CONFIG_DIR/colors.sh"

vpn_name="$(/usr/sbin/scutil --nc list 2>/dev/null | /usr/bin/awk '/\(Connected\)/ { line=$0; sub(/^[^"]*"/, "", line); sub(/".*$/, "", line); print line; exit }')"

if [ -n "$vpn_name" ]; then
  short_name="$(printf '%s' "$vpn_name" | /usr/bin/cut -c1-14)"
  sketchybar --set "$NAME" icon="VPN" icon.color="$ACCENT_COLOR" label="$short_name"
  exit 0
fi

interface="$(/sbin/route -n get default 2>/dev/null | /usr/bin/awk '/interface:/ { print $2; exit }')"
address="$(/usr/sbin/ipconfig getifaddr "$interface" 2>/dev/null)"

if [ -n "$address" ]; then
  sketchybar --set "$NAME" icon="NET" icon.color="$MUTED_COLOR" label="$address"
else
  sketchybar --set "$NAME" icon="OFF" icon.color="$MUTED_COLOR" label.drawing=off
fi
