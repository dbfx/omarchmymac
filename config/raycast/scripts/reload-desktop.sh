#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reload Desktop
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ♻️
# @raycast.packageName Omarchy Mac
# @raycast.description Reload AeroSpace, SketchyBar, Ghostty and borders

/opt/homebrew/bin/aerospace reload-config
/opt/homebrew/bin/sketchybar --reload
current_theme="$(<"$HOME/.config/omarchy-mac/current-theme")"
"$HOME/.config/omarchy-mac/bin/theme" "$current_theme"
print "Desktop reloaded"
