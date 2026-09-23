#!/bin/zsh
# macOS settings the desktop relies on. Safe to re-run.
set -eu
source "${0:A:h}/lib.sh"

info "Applying macOS defaults"

# The menu bar auto-hides; SketchyBar takes its place and steps aside when it
# slides back down (see the watcher at the end of config/hammerspoon/init.lua).
defaults write NSGlobalDomain _HIHideMenuBar -bool true
ok "menu bar auto-hide"

# Dark appearance to match the themes.
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' >/dev/null
ok "dark mode"

# The Dock is replaced by AeroSpace workspaces and the Raycast launcher.
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock expose-group-apps -bool true
ok "dock hidden"

# One space per display, no Stage Manager: AeroSpace owns window placement.
defaults write com.apple.spaces spans-displays -bool true
defaults write com.apple.WindowManager GloballyEnabled -bool false
ok "spaces span displays, Stage Manager off (takes effect after logout)"

# Snappier window operations under a tiling manager.
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
ok "window animations off"

killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
