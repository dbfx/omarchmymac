#!/bin/sh

SID="$1"
GROUP="$2"
source "$CONFIG_DIR/colors.sh"
. "$HOME/.config/omarchy-mac/lib/workspaces.sh"

set_active() {
  sketchybar --set "$NAME" \
    background.color="$ACCENT_COLOR" \
    label.color="$BAR_COLOR"
}

set_inactive() {
  sketchybar --set "$NAME" \
    background.color="$TRANSPARENT" \
    label.color="$MUTED_COLOR"
}

# Startup/reload: mark both workspaces currently visible across the displays.
if [ -n "$VISIBLE_WORKSPACES" ]; then
  case ",$VISIBLE_WORKSPACES," in
    *",$SID,"*) set_active ;;
    *) set_inactive ;;
  esac
  exit 0
fi

# Normal switch: activate the destination. Only deactivate the previous pill
# when it is on the same monitor; otherwise it remains visible on its display.
if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
  set_active
elif [ "$SID" = "$PREV_WORKSPACE" ]; then
  previous_group="$(workspace_display "$PREV_WORKSPACE")"
  focused_group="$(workspace_display "$FOCUSED_WORKSPACE")"

  [ "$previous_group" = "$focused_group" ] && [ "$GROUP" = "$previous_group" ] && set_inactive
fi
