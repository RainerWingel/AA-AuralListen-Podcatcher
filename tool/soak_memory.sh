#!/usr/bin/env bash
# M8 soak test on the device: samples the app's memory while it plays.
# Read-only (dumpsys / ps) – no taps, no audio control.
#
#   tool/soak_memory.sh [minutes=120] [interval_seconds=60] > soak.csv
#
# Start playback of a long episode first. The memory must not grow over time
# (docs/eviction.md); a slow upward trend of TOTAL PSS over 2 h is a leak.
set -euo pipefail
ADB="${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}"
PKG=io.github.rainerwingel.aapodcastguru
MINUTES="${1:-120}"
INTERVAL="${2:-60}"
END=$(( $(date +%s) + MINUTES * 60 ))

echo "time,pid,total_pss_kb,java_heap_kb,native_heap_kb,graphics_kb,threads,playing"
while [ "$(date +%s)" -lt "$END" ]; do
  PID=$("$ADB" shell pidof "$PKG" | tr -d '\r' || true)
  if [ -z "$PID" ]; then
    echo "$(date +%H:%M:%S),,,,,,,not-running"
  else
    MEM=$("$ADB" shell dumpsys meminfo "$PKG" | tr -d '\r')
    TOTAL=$(echo "$MEM" | awk '/TOTAL PSS:/ {print $3; exit}')
    JAVA=$(echo "$MEM" | awk '/Java Heap:/ {print $3; exit}')
    NATIVE=$(echo "$MEM" | awk '/Native Heap:/ {print $3; exit}')
    GFX=$(echo "$MEM" | awk '/Graphics:/ {print $2; exit}')
    THREADS=$("$ADB" shell "grep Threads /proc/$PID/status" 2>/dev/null | awk '{print $2}' | tr -d '\r')
    STATE=$("$ADB" shell dumpsys media_session | tr -d '\r' \
      | awk -v p="$PKG" '$0 ~ "package="p {f=1} f && /state=PlaybackState/ {print ($0 ~ /state=3/ ? "yes" : "no"); exit}')
    echo "$(date +%H:%M:%S),$PID,$TOTAL,$JAVA,$NATIVE,$GFX,$THREADS,${STATE:-?}"
  fi
  sleep "$INTERVAL"
done
