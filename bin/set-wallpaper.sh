#!/bin/zsh
# Set the desktop picture on every display. Themes never touch the wallpaper;
# this is the one place it changes.
set -eu
source "${0:A:h}/lib.sh"

picture="${1:-$REPO/config/omarchy-mac/wallpapers/tokyo-night.png}"
[[ -f "$picture" ]] || { fail "no such file: $picture"; exit 64 }
osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"${picture:A}\""
ok "wallpaper: ${picture:t}"
