#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reload AeroSpace
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🧩
# @raycast.packageName Omarchy Mac
# @raycast.description Reload the AeroSpace configuration

/opt/homebrew/bin/aerospace reload-config
print "AeroSpace reloaded"
