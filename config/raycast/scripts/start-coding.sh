#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Coding
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Omarchy Mac
# @raycast.description Pick a repo, warm Docker, open the toolchain and jump to code

/opt/homebrew/bin/hs -c 'omarchyProjectChooser()'

