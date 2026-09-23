#!/bin/zsh
# Bootstrap on a fresh Mac:
#
#   curl -fsSL https://raw.githubusercontent.com/dbfx/omarchmymac/main/boot.sh | zsh
#
# Installs the Xcode command line tools and Homebrew if missing, clones (or
# updates) the repo into ~/omarchmymac, then hands over to install.sh with
# your terminal attached so the workspace questions work when piped.
#
#   ... | zsh -s -- --defaults      skip the questions
#   ... | zsh -s -- --no-install    clone only, run install.sh yourself
#   OMARCHY_DIR=~/somewhere ... | zsh   clone elsewhere
set -eu

REPO_URL="https://github.com/dbfx/omarchmymac.git"
DIR="${OMARCHY_DIR:-$HOME/omarchmymac}"
run_install=1
install_args=()
for arg in "$@"; do
  case "$arg" in
    --no-install) run_install=0 ;;
    *) install_args+=("$arg") ;;
  esac
done

say() { print -P "%F{blue}==>%f $*"; }

[[ "$(uname -s)" == Darwin ]] || { print -u2 "This is a macOS setup."; exit 1 }
if [[ "$(uname -m)" != arm64 ]]; then
  print -u2 "The configs assume Apple Silicon (Homebrew under /opt/homebrew). Intel Macs need path edits first."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  say "Installing the Xcode command line tools (a dialog will open)"
  xcode-select --install >/dev/null 2>&1 || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  say "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ -d "$DIR/.git" ]]; then
  say "Updating $DIR"
  git -C "$DIR" pull --ff-only
else
  say "Cloning into $DIR"
  git clone "$REPO_URL" "$DIR"
fi

if (( run_install )); then
  say "Running the installer"
  exec "$DIR/install.sh" "${install_args[@]}" </dev/tty
fi
say "Cloned. Next: $DIR/install.sh"
