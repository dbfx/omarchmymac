#!/bin/zsh
# Symlink every config in this repo into the place macOS tools read it from.
# Existing files are moved to ~/omarchmymac-backup/<timestamp>/ first.
set -eu
source "${0:A:h}/lib.sh"

stamp="$(date +%Y%m%d-%H%M%S)"
info "Linking configs from $REPO"
for pair in "${LINKS[@]}"; do
  target="${pair%%=*}"
  source_path="$REPO/${pair#*=}"

  if [[ ! -e "$source_path" ]]; then
    warn "missing in repo, skipped: ${pair#*=}"
    continue
  fi
  if [[ -L "$target" && "${target:A}" == "${source_path:A}" ]]; then
    ok "${target/#$HOME/~} already linked"
    continue
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup="$BACKUP_ROOT/$stamp${target#$HOME}"
    mkdir -p "${backup:h}"
    mv "$target" "$backup"
    warn "moved existing ${target/#$HOME/~} to ${backup/#$HOME/~}"
    # Keep runtime state (current project, timers) across the move.
    if [[ -d "$backup/state" && -d "$source_path" && ! -e "$source_path/state" ]]; then
      cp -R "$backup/state" "$source_path/state"
    fi
  fi
  mkdir -p "${target:h}"
  ln -s "$source_path" "$target"
  ok "${target/#$HOME/~} -> ${pair#*=}"
done

mkdir -p "$REPO/config/omarchy-mac/state"
