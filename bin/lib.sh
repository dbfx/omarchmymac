#!/bin/zsh
# Shared helpers for the omarchmymac scripts.

REPO="${REPO:-${0:A:h:h}}"
BACKUP_ROOT="$HOME/omarchmymac-backup"

# target=source pairs. Targets are the paths macOS tools read; sources live in
# this repo. A symlink is used so edits in either place are the same file.
typeset -ga LINKS=(
  "$HOME/.config/omarchy-mac=config/omarchy-mac"
  "$HOME/.config/sketchybar=config/sketchybar"
  "$HOME/.aerospace.toml=config/aerospace/aerospace.toml"
  "$HOME/.config/borders=config/borders"
  "$HOME/.config/ghostty=config/ghostty"
  "$HOME/.config/karabiner/karabiner.json=config/karabiner/karabiner.json"
  "$HOME/.hammerspoon=config/hammerspoon"
  "$HOME/.config/btop=config/btop"
  "$HOME/.config/lazygit=config/lazygit"
  "$HOME/.config/starship.toml=config/starship.toml"
  "$HOME/.config/raycast/scripts=config/raycast/scripts"
  "$HOME/.zshrc=shell/zshrc"
)

info()  { print -P "%F{blue}==>%f $*"; }
ok()    { print -P "  %F{green}✓%f $*"; }
warn()  { print -P "  %F{yellow}!%f $*"; }
fail()  { print -P "  %F{red}✗%f $*"; }
