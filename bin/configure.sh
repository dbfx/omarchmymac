#!/bin/zsh
# Ask which workspaces this Mac should have and which monitors they live on,
# write workspaces.conf, and render the AeroSpace config from it.
#
#   bin/configure.sh             interactive (defaults are Dave's layout)
#   bin/configure.sh --defaults  keep the existing conf, or write the defaults
set -eu
source "${0:A:h}/lib.sh"
conf="$REPO/config/omarchy-mac/workspaces.conf"

DEFAULT_WORKSPACES="web:top:w code:top:c term:top:t misc:top:m chat:bottom:h scratch:bottom:s"
DEFAULT_TOP="Smart M80C"
DEFAULT_BOTTOM="Built-in Retina Display"

# Existing answers become the new defaults so re-running is safe.
if [[ -r "$conf" ]]; then
  source "$conf"
  DEFAULT_WORKSPACES="${WORKSPACES:-$DEFAULT_WORKSPACES}"
  DEFAULT_TOP="${TOP_MONITOR:-$DEFAULT_TOP}"
  DEFAULT_BOTTOM="${BOTTOM_MONITOR:-$DEFAULT_BOTTOM}"
fi

# Prefer the monitors actually attached right now.
if command -v aerospace >/dev/null && aerospace list-monitors >/dev/null 2>&1; then
  detected=("${(f)$(aerospace list-monitors --format '%{monitor-name}' 2>/dev/null)}")
  for m in "${detected[@]}"; do
    [[ "$m" == Built-in* ]] && DEFAULT_BOTTOM="$m" || DEFAULT_TOP="$m"
  done
fi

validate() {
  local spec="$1" names=() keys=() entry name display key
  local entries=("${(s: :)spec}")
  (( ${#entries} >= 1 && ${#entries} <= 10 )) || { fail "give 1 to 10 workspaces"; return 1 }
  for entry in "${entries[@]}"; do
    name="${entry%%:*}"; display="${${entry#*:}%%:*}"; key="${entry##*:}"
    [[ "$entry" == *:*:* && "$name" =~ '^[a-z0-9]+$' ]] || { fail "'$entry' is not name:display:key with a lowercase name"; return 1 }
    [[ "$display" == top || "$display" == bottom ]] || { fail "'$entry': display must be top or bottom"; return 1 }
    [[ "$key" =~ '^[a-z0-9]$' ]] || { fail "'$entry': key must be one letter or digit"; return 1 }
    (( ${names[(Ie)$name]} )) && { fail "workspace '$name' listed twice"; return 1 }
    (( ${keys[(Ie)$key]} )) && { fail "key '$key' used twice"; return 1 }
    names+=("$name"); keys+=("$key")
  done
}

WORKSPACES="$DEFAULT_WORKSPACES"
TOP_MONITOR="$DEFAULT_TOP"
BOTTOM_MONITOR="$DEFAULT_BOTTOM"

# Interactive when stdin is a terminal (or OMARCHY_INTERACTIVE=1 for tests);
# otherwise keep the existing answers so a piped install never hangs.
if [[ "${1:-}" != "--defaults" && ( -t 0 || "${OMARCHY_INTERACTIVE:-}" == 1 ) ]]; then
  info "Workspaces"
  print "  Each workspace is name:display:key. display is top (external monitor) or"
  print "  bottom (MacBook screen); key is the letter after Caps+W. Alt+1.. follow the order."
  print "  Default: $DEFAULT_WORKSPACES"
  while true; do
    read -r "answer?  Use this set? [Y/n] " || answer=""
    case "${answer:l}" in
      ""|y|yes) break ;;
      n|no)
        read -r "spec?  Workspaces: " || { spec=""; print; }
        [[ -z "$spec" ]] && break
        if validate "$spec"; then WORKSPACES="$spec"; break; fi
        ;;
    esac
  done

  info "Monitors (names as 'aerospace list-monitors' prints them)"
  read -r "top?  Top / external monitor [$DEFAULT_TOP]: " || top=""
  read -r "bottom?  Bottom / built-in monitor [$DEFAULT_BOTTOM]: " || bottom=""
  TOP_MONITOR="${top:-$DEFAULT_TOP}"
  BOTTOM_MONITOR="${bottom:-$DEFAULT_BOTTOM}"
else
  validate "$WORKSPACES"
fi

cat > "$conf" <<CONF
# Workspaces for this Mac. Written by bin/configure.sh; edit freely, then run
# bin/render.sh so AeroSpace picks up the change. The bar and Hammerspoon read
# this file directly.
#
# Each workspace is name:display:key
#   name     lowercase letters/digits, what AeroSpace calls the workspace
#   display  top (external monitor) or bottom (MacBook screen); with a single
#            screen everything lands on it
#   key      the letter after Caps+W that jumps to it
# Alt+1, Alt+2, ... follow this order (up to ten workspaces).
WORKSPACES="$WORKSPACES"

# Monitor names exactly as \`aerospace list-monitors\` prints them.
TOP_MONITOR="$TOP_MONITOR"
BOTTOM_MONITOR="$BOTTOM_MONITOR"
CONF
ok "wrote ${conf/#$HOME/~}"
"$REPO/bin/render.sh"
