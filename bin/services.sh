#!/bin/zsh
# Start (or restart) the background pieces of the desktop.
set -eu
source "${0:A:h}/lib.sh"

info "Starting services"
brew services restart sketchybar >/dev/null && ok "sketchybar (launchd via brew services)"
brew services restart borders >/dev/null && ok "borders (launchd via brew services)"

open -ga AeroSpace && ok "AeroSpace (start-at-login is set in aerospace.toml)"
open -ga Hammerspoon && ok "Hammerspoon (autoLaunch is set in init.lua)"
open -ga "Karabiner-Elements" && ok "Karabiner-Elements"

# Hammerspoon's command-line client is what the bar and Raycast scripts use.
if [[ ! -x /opt/homebrew/bin/hs ]]; then
  warn "hs CLI missing: open the Hammerspoon console and run  hs.ipc.cliInstall(\"/opt/homebrew\")"
fi
