#!/bin/sh

state="$HOME/.config/omarchy-mac/state/current-project"
if [ ! -r "$state" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

project="$(head -n 1 "$state")"
if [ ! -d "$project" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

name="$(basename "$project")"
branch="$(/usr/bin/git -C "$project" branch --show-current 2>/dev/null)"
[ -n "$branch" ] || branch="detached"
dirty=""
/usr/bin/git -C "$project" diff --quiet --ignore-submodules -- 2>/dev/null || dirty="*"

sketchybar --set "$NAME" drawing=on label="$name · $branch$dirty"

