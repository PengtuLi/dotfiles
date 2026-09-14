#!/bin/sh
# Match hwmon by chip name so indices don't break across kernel updates.
find_temp() {
  for h in /sys/class/hwmon/hwmon*; do
    [ -r "$h/name" ] || continue
    [ "$(cat "$h/name")" = "$1" ] || continue
    [ -r "$h/temp1_input" ] && { cat "$h/temp1_input"; return 0; }
  done
  return 1
}

cpu=$(find_temp k10temp || find_temp coretemp || echo 0)
gpu=$(find_temp amdgpu || find_temp nouveau || echo 0)
cpu_c=$((cpu / 1000))
gpu_c=$((gpu / 1000))

max=$cpu_c
[ "$gpu_c" -gt "$max" ] && max=$gpu_c
class=normal
[ "$max" -ge 80 ] && class=warning
[ "$max" -ge 95 ] && class=critical

printf '{"text": "CPU %s°C | GPU %s°C", "class": "%s"}\n' "$cpu_c" "$gpu_c" "$class"
