#!/bin/zsh
# Regenerate the workspace blocks in aerospace.toml from workspaces.conf.
# The bar and Hammerspoon read the conf directly; AeroSpace's TOML cannot, so
# the three marked blocks are rewritten in place. Everything outside the
# markers is left alone.
set -eu
source "${0:A:h}/lib.sh"
OMARCHY_ROOT="$REPO/config/omarchy-mac"
source "$OMARCHY_ROOT/lib/workspaces.sh"

toml="$REPO/config/aerospace/aerospace.toml"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

names=("${(f)$(workspace_names)}")
(( ${#names} >= 1 && ${#names} <= 10 )) || { fail "workspaces.conf must list 1 to 10 workspaces"; exit 65 }

{
  printf "persistent-workspaces = ["
  local sep=""
  for name in "${names[@]}"; do printf "%s'%s'" "$sep" "$name"; sep=", "; done
  printf "]\n"
} > "$tmp/workspaces"

{
  print "[workspace-to-monitor-force-assignment]"
  for name in "${names[@]}"; do
    case "$(workspace_display "$name")" in
      bottom) print "    $name = '$BOTTOM_MONITOR'" ;;
      *) print "    $name = '$TOP_MONITOR'" ;;
    esac
  done
} > "$tmp/monitors"

{
  local n=0
  for name in "${names[@]}"; do
    n=$((n + 1)); local digit=$(( n % 10 ))
    print "    alt-$digit = 'workspace $name'"
  done
  n=0
  for name in "${names[@]}"; do
    n=$((n + 1)); local digit=$(( n % 10 ))
    print "    alt-shift-$digit = 'move-node-to-workspace --focus-follows-window $name'"
  done
} > "$tmp/keys"

replace_block() {
  local file="$1" start="$2" end="$3" content="$4"
  grep -qF "$start" "$file" && grep -qF "$end" "$file" || { fail "markers '$start' / '$end' missing in ${file:t}"; exit 66 }
  awk -v start="$start" -v end="$end" -v content="$content" '
    index($0, start) { print; while ((getline line < content) > 0) print line; close(content); skipping = 1; next }
    index($0, end)   { skipping = 0 }
    !skipping        { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

replace_block "$toml" "# >>> workspaces " "# <<< workspaces <<<" "$tmp/workspaces"
replace_block "$toml" "# >>> workspace-monitors " "# <<< workspace-monitors <<<" "$tmp/monitors"
replace_block "$toml" "# >>> workspace-keys " "# <<< workspace-keys <<<" "$tmp/keys"

ok "aerospace.toml: ${#names} workspaces (${(j:, :)names}); top='$TOP_MONITOR' bottom='$BOTTOM_MONITOR'"
