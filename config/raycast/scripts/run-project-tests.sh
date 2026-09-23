#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Run Project Tests
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ✅
# @raycast.packageName Omarchy Mac
# @raycast.description Run the active repo's detected test command

"$HOME/.config/omarchy-mac/bin/project-test"
print "Tests passed"

