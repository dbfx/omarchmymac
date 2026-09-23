#!/bin/sh

logical_cpus="$(/usr/sbin/sysctl -n hw.logicalcpu 2>/dev/null)"
cpu_total="$(/bin/ps -A -o %cpu= 2>/dev/null | /usr/bin/awk '{ total += $1 } END { printf "%.0f", total }')"

if [ -n "$logical_cpus" ] && [ "$logical_cpus" -gt 0 ] 2>/dev/null; then
  cpu_used="$(/usr/bin/awk -v total="${cpu_total:-0}" -v cores="$logical_cpus" 'BEGIN { value=total/cores; if (value>100) value=100; printf "%.0f", value }')"
else
  cpu_used="--"
fi

memory_free="$(/usr/bin/memory_pressure -Q 2>/dev/null | /usr/bin/awk '/free percentage/ { gsub(/%/, "", $5); print $5; exit }')"
if [ -n "$memory_free" ]; then
  memory_used=$((100 - memory_free))
else
  memory_used="--"
fi

sketchybar --set "$NAME" label="${cpu_used}% · ${memory_used}%" \
           --set system.cpu label="${cpu_used}% used" \
           --set system.mem label="${memory_used}% used"
