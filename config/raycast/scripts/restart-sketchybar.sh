#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart SketchyBar
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📊
# @raycast.packageName Omarchy Mac
# @raycast.description Restart the SketchyBar background service

/opt/homebrew/bin/brew services restart sketchybar >/dev/null
print "SketchyBar restarted"
