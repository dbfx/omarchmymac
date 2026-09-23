#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Mac
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔄
# @raycast.packageName Omarchy Mac
# @raycast.description Restart macOS after showing a confirmation
# @raycast.needsConfirmation true

/usr/bin/osascript -e 'tell application "System Events" to restart'
