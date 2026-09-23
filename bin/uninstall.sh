#!/bin/zsh
# Undo what install.sh did to this Mac: remove the symlinks, put back whatever
# was there before from ~/omarchmymac-backup, and stop the bar and borders.
# Homebrew packages, ~/.zshrc.private and this repo are left alone.
#
#   bin/uninstall.sh                   restore files, stop services
#   bin/uninstall.sh --reset-defaults  also return the macOS defaults to stock
#   bin/uninstall.sh --links-only      restore files only, touch nothing running
set -eu
source "${0:A:h}/lib.sh"

reset_defaults=0 links_only=0
for arg in "$@"; do
  case "$arg" in
    --reset-defaults) reset_defaults=1 ;;
    --links-only) links_only=1 ;;
    *) print -u2 "unknown option: $arg"; exit 64 ;;
  esac
done

# Newest backup first, so the most recent copy of each file wins.
backups=()
if [[ -d "$BACKUP_ROOT" ]]; then
  backups=("${(@On)$(ls -1 "$BACKUP_ROOT")}")
fi

info "Restoring files"
for pair in "${LINKS[@]}"; do
  target="${pair%%=*}"
  relative="${target#$HOME}"
  source_path="$REPO/${pair#*=}"

  if [[ -L "$target" && "${target:A}" == "${source_path:A}" ]]; then
    rm "$target"
  elif [[ -e "$target" || -L "$target" ]]; then
    warn "${target/#$HOME/~} is not our link, left alone"
    continue
  fi

  restored=0
  for stamp in "${backups[@]}"; do
    candidate="$BACKUP_ROOT/$stamp$relative"
    if [[ -e "$candidate" || -L "$candidate" ]]; then
      mkdir -p "${target:h}"
      mv "$candidate" "$target"
      ok "${target/#$HOME/~} restored from backup $stamp"
      restored=1
      break
    fi
  done
  (( restored )) || ok "${target/#$HOME/~} removed (nothing to restore)"
done
# Drop backup folders that are now empty.
for stamp in "${backups[@]}"; do
  find "$BACKUP_ROOT/$stamp" -type d -empty -delete 2>/dev/null || true
done
[[ -d "$BACKUP_ROOT" ]] && find "$BACKUP_ROOT" -type d -empty -delete 2>/dev/null || true

if (( links_only )); then
  info "Files restored. Services and defaults were not touched."
  exit 0
fi

info "Stopping services"
brew services stop sketchybar >/dev/null 2>&1 && ok "sketchybar stopped" || warn "sketchybar was not a running service"
brew services stop borders >/dev/null 2>&1 && ok "borders stopped" || warn "borders was not a running service"
for app in AeroSpace Hammerspoon; do
  osascript -e "quit app \"$app\"" >/dev/null 2>&1 && ok "$app quit" || true
done

if (( reset_defaults )); then
  info "Returning macOS defaults to stock"
  defaults delete NSGlobalDomain _HIHideMenuBar 2>/dev/null || true
  defaults delete com.apple.dock autohide 2>/dev/null || true
  defaults delete com.apple.dock tilesize 2>/dev/null || true
  defaults delete com.apple.dock expose-group-apps 2>/dev/null || true
  defaults delete com.apple.spaces spans-displays 2>/dev/null || true
  defaults delete com.apple.WindowManager GloballyEnabled 2>/dev/null || true
  defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
  killall Dock 2>/dev/null || true
  killall SystemUIServer 2>/dev/null || true
  ok "menu bar, dock, spaces and animation settings reset (dark mode left as is)"
fi

print
info "Done. Left in place: Homebrew packages (see Brewfile), ~/.zshrc.private, and this repo."
info "If ~/.zshrc still sources shell/omarchy.zsh from the repo, remove that line before deleting the repo."
