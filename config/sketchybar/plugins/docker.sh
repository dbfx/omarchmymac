#!/bin/sh

source "$CONFIG_DIR/colors.sh"
if [ -x /usr/local/bin/docker ]; then
  docker_bin="/usr/local/bin/docker"
elif [ -x /opt/homebrew/bin/docker ]; then
  docker_bin="/opt/homebrew/bin/docker"
else
  docker_bin="$(command -v docker 2>/dev/null)"
fi
[ -n "$docker_bin" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }

context="$($docker_bin context show 2>/dev/null)"
[ -n "$context" ] || context="default"
short="$(printf '%s' "$context" | /usr/bin/cut -c1-14)"

if /usr/bin/pgrep -f 'Docker Desktop|com.docker.backend|orbstack' >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=on icon.color="$ACCENT_COLOR" label="$short"
else
  sketchybar --set "$NAME" drawing=on icon.color="$MUTED_COLOR" label="$short · off"
fi
