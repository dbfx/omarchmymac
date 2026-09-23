#!/bin/sh

meeting="$(/usr/bin/osascript 2>/dev/null <<'APPLESCRIPT'
tell application "Calendar"
  set nowDate to current date
  set cutoffDate to nowDate + (2 * hours)
  set bestEvent to missing value
  set bestStart to cutoffDate + 1
  repeat with cal in calendars
    try
      repeat with evt in (every event of cal whose start date ≥ nowDate and start date ≤ cutoffDate and allday event is false)
        if start date of evt < bestStart then
          set bestStart to start date of evt
          set bestEvent to evt
        end if
      end repeat
    end try
  end repeat
  if bestEvent is not missing value then
    set mins to ((bestStart - nowDate) / minutes) as integer
    return "in " & mins & "m · " & summary of bestEvent
  end if
end tell
APPLESCRIPT
)"

if [ -n "$meeting" ]; then
  sketchybar --set "$NAME" drawing=on label="$(printf '%s' "$meeting" | /usr/bin/cut -c1-32)"
else
  sketchybar --set "$NAME" drawing=off
fi

