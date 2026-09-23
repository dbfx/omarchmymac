#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Window Floating
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🪟
# @raycast.packageName Omarchy Mac
# @raycast.description Toggle the previously focused AeroSpace window

/opt/homebrew/bin/aerospace layout floating tiling
print "Window layout toggled"
