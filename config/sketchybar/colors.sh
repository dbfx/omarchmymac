#!/bin/sh

# The current Omarchy Mac preset owns the shared desktop palette.
if [ -r "$HOME/.config/omarchy-mac/current.sh" ]; then
  source "$HOME/.config/omarchy-mac/current.sh"
fi

# Safe fallbacks keep the bar usable while a theme is being changed.
export BAR_COLOR="${BAR_COLOR:-0xee0b0d10}"
export SURFACE_COLOR="${SURFACE_COLOR:-0xff1b1e24}"
export SURFACE_ALT_COLOR="${SURFACE_ALT_COLOR:-0xff292d35}"
export ACCENT_COLOR="${ACCENT_COLOR:-0xffffb86c}"
export TEXT_COLOR="${TEXT_COLOR:-0xffe8e9ed}"
export MUTED_COLOR="${MUTED_COLOR:-0xff858b98}"
export TRANSPARENT=0x00000000
