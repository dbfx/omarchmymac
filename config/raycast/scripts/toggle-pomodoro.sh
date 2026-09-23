#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Pomodoro
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🍅
# @raycast.packageName Omarchy Mac

"$HOME/.config/omarchy-mac/bin/pomodoro" toggle
print "Pomodoro toggled"

