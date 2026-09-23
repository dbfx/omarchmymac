#!/bin/zsh
# Set up the whole desktop on a Mac. Every step is idempotent; re-run freely.
#
#   ./install.sh                 everything
#   ./install.sh --skip-brew     skip Homebrew packages
#   ./install.sh --skip-defaults skip macOS defaults
#   ./install.sh --skip-wallpaper
#   ./install.sh --defaults      no questions: keep workspaces.conf as it is
set -eu
REPO="${0:A:h}"
source "$REPO/bin/lib.sh"

skip_brew=0 skip_defaults=0 skip_wallpaper=0 use_defaults=0
for arg in "$@"; do
  case "$arg" in
    --skip-brew) skip_brew=1 ;;
    --skip-defaults) skip_defaults=1 ;;
    --skip-wallpaper) skip_wallpaper=1 ;;
    --defaults) use_defaults=1 ;;
    *) print -u2 "unknown option: $arg"; exit 64 ;;
  esac
done

if (( ! skip_brew )); then
  if ! command -v brew >/dev/null; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  info "Installing packages from Brewfile"
  brew bundle --file "$REPO/Brewfile" --no-upgrade
fi

"$REPO/bin/link.sh"

if (( use_defaults )); then
  "$REPO/bin/configure.sh" --defaults
else
  "$REPO/bin/configure.sh"
fi

info "Shell"
if [[ -f "$HOME/.zshrc.private" ]]; then
  ok "~/.zshrc.private present"
else
  install -m 600 "$REPO/shell/zshrc.private.example" "$HOME/.zshrc.private"
  warn "created ~/.zshrc.private from the example; fill in your tokens"
fi
mkdir -p "$HOME/Code" && ok "~/Code exists (project chooser scans it)"

(( skip_defaults )) || "$REPO/bin/macos-defaults.sh"

"$REPO/bin/services.sh"

if (( ! skip_wallpaper )); then
  current="$(osascript -e 'tell application "System Events" to get picture of first desktop' 2>/dev/null || true)"
  case "$current" in
    */omarchy-mac/wallpapers/*|*/omarchmymac/config/omarchy-mac/wallpapers/*) ok "wallpaper already from this repo" ;;
    *) "$REPO/bin/set-wallpaper.sh" ;;
  esac
fi

info "Applying theme: $(cat "$REPO/config/omarchy-mac/current-theme")"
"$REPO/config/omarchy-mac/bin/theme" "$(cat "$REPO/config/omarchy-mac/current-theme")"

print
"$REPO/bin/check.sh" || true
print
info "Grant Accessibility to AeroSpace, Hammerspoon and Karabiner-Elements, then log out and back in once."
