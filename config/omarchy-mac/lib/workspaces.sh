#!/bin/sh
# Shared reader for workspaces.conf. Plain POSIX sh so /bin/sh plugins, bash
# and zsh can all source it. Command substitution is used for splitting so the
# loops behave the same in zsh.

OMARCHY_ROOT="${OMARCHY_ROOT:-$HOME/.config/omarchy-mac}"
WORKSPACES="web:top:w code:top:c term:top:t misc:top:m chat:bottom:h scratch:bottom:s"
TOP_MONITOR="Smart M80C"
BOTTOM_MONITOR="Built-in Retina Display"
if [ -r "$OMARCHY_ROOT/workspaces.conf" ]; then
  . "$OMARCHY_ROOT/workspaces.conf"
fi

workspace_entries() { printf '%s\n' "$WORKSPACES" | tr ' ' '\n' | grep -v '^$'; }

workspace_names() { workspace_entries | cut -d: -f1; }

# workspace_display <name>  -> top | bottom
workspace_display() { workspace_entries | grep "^$1:" | cut -d: -f2; }

# workspace_key <name>  -> leader key
workspace_key() { workspace_entries | grep "^$1:" | cut -d: -f3; }

# workspaces_on <top|bottom>  -> names, one per line
workspaces_on() { workspace_entries | grep ":$1:" | cut -d: -f1; }
