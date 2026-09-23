#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set Desktop Theme
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🎨
# @raycast.packageName Omarchy Mac
# @raycast.description Theme Ghostty, SketchyBar and borders without changing wallpaper
# @raycast.argument1 {"type":"dropdown","placeholder":"Theme","data":[{"title":"Tokyo Night","value":"tokyo-night"},{"title":"Catppuccin Mocha","value":"catppuccin"},{"title":"Kanagawa Wave","value":"kanagawa"},{"title":"Rose Pine","value":"rose-pine"}]}

exec "$HOME/.config/omarchy-mac/bin/theme" "$1"
