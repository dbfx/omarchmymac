#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Desktop Config
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⚙️
# @raycast.packageName Omarchy Mac
# @raycast.description Open AeroSpace, Ghostty and SketchyBar config in T3 Code

open -a "T3 Code (Nightly)" \
  "$HOME/.aerospace.toml" \
  "$HOME/.config/ghostty/config" \
  "$HOME/.config/sketchybar/sketchybarrc" \
  "$HOME/.config/omarchy-mac"
