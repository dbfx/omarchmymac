#!/bin/zsh
# Doctor: report what is installed, linked and running. Never changes anything.
source "${0:A:h}/lib.sh"
problems=0

info "Binaries"
for b in sketchybar borders aerospace hs starship fzf zoxide eza bat btop lazygit jq; do
  if command -v "$b" >/dev/null; then ok "$b"; else fail "$b not found"; problems=$((problems+1)); fi
done

info "Apps"
for a in AeroSpace Hammerspoon Karabiner-Elements Ghostty Raycast; do
  if [[ -d "/Applications/$a.app" ]]; then ok "$a"; else fail "$a.app missing"; problems=$((problems+1)); fi
done
for a in "Google Chrome" Zen Slack "T3 Code (Nightly)"; do
  [[ -d "/Applications/$a.app" ]] && ok "$a" || warn "$a.app missing (used by workspaces and session restore)"
done

info "Font"
if fc-list 2>/dev/null | grep -qi "JetBrainsMonoNerdFont" || ls ~/Library/Fonts /Library/Fonts 2>/dev/null | grep -qi "JetBrainsMonoNerdFont"; then
  ok "JetBrainsMono Nerd Font"
else fail "JetBrainsMono Nerd Font missing"; problems=$((problems+1)); fi

info "Links"
for pair in "${LINKS[@]}"; do
  target="${pair%%=*}"; source_path="$REPO/${pair#*=}"
  if [[ -L "$target" && "${target:A}" == "${source_path:A}" ]]; then ok "${target/#$HOME/~}"
  else fail "${target/#$HOME/~} is not linked to ${pair#*=}"; problems=$((problems+1)); fi
done

info "Workspaces"
source "$REPO/config/omarchy-mac/lib/workspaces.sh" 2>/dev/null
stale=0
for name in $(OMARCHY_ROOT="$REPO/config/omarchy-mac" workspace_names); do
  grep -q "= 'workspace $name'" "$REPO/config/aerospace/aerospace.toml" || stale=1
done
(( stale )) && { fail "aerospace.toml is out of date: run bin/render.sh"; problems=$((problems+1)); } || ok "aerospace.toml matches workspaces.conf ($(OMARCHY_ROOT="$REPO/config/omarchy-mac" workspace_names | paste -sd, -))"

info "Services"
for p in sketchybar borders AeroSpace Hammerspoon Karabiner-Core-Service Karabiner-Console-User-Server; do
  if pgrep -x "$p" >/dev/null; then ok "$p running"; else fail "$p not running"; problems=$((problems+1)); fi
done

info "macOS defaults"
[[ "$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null)" == 1 ]] && ok "menu bar auto-hide" || { fail "menu bar auto-hide off"; problems=$((problems+1)); }
[[ "$(defaults read com.apple.dock autohide 2>/dev/null)" == 1 ]] && ok "dock auto-hide" || warn "dock auto-hide off"
[[ "$(defaults read NSGlobalDomain AppleInterfaceStyle 2>/dev/null)" == Dark ]] && ok "dark mode" || warn "light mode"

info "Shell"
[[ -f ~/.zshrc.private ]] && ok "~/.zshrc.private present" || warn "~/.zshrc.private missing (copy shell/zshrc.private.example)"
grep -qE "TOKEN=[A-Za-z0-9]" "$REPO/shell/zshrc" 2>/dev/null && { fail "a token is inline in shell/zshrc"; problems=$((problems+1)); } || ok "no tokens in tracked shell files"

info "Manual permissions (System Settings > Privacy & Security)"
print "  Accessibility: AeroSpace, Hammerspoon, Karabiner-Elements"
print "  Input Monitoring: Karabiner-Elements (and approve its driver extension)"
print "  Raycast > Extensions > Script Commands: add ~/.config/raycast/scripts"

(( problems == 0 )) && info "All good" || { info "$problems problem(s)"; exit 1 }
