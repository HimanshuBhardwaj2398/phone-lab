#!/usr/bin/env bash
# Polls USB and reports what state an attached Android/OnePlus phone is in.
# Usage: ./scripts/detect.sh   (Ctrl-C to stop)

classify() {
  local vid=$1 pid=$2
  case "$vid:$pid" in
    1478:36872) echo "Qualcomm EDL (9008) - emergency download mode, no Android running" ;;
    1478:*)     echo "Qualcomm device (vid 05c6, pid $(printf %04x "$pid"))" ;;
    10864:*)    echo "OnePlus device (vid 2a70, pid $(printf %04x "$pid"))" ;;
    6353:*)     echo "Google/AOSP USB id (vid 18d1, pid $(printf %04x "$pid")) - adb/fastboot/MTP" ;;
    8921:*)     echo "Oppo/Realme id (vid 22d9) - newer OnePlus firmware uses this" ;;
    4100:*)     echo "LG device (vid 1004, pid $(printf %04x "$pid"))" ;;
    *) return 1 ;;
  esac
}

last=""
while true; do
  out=""
  while read -r vid pid; do
    if c=$(classify "$vid" "$pid"); then out+="$c"$'\n'; fi
  done < <(ioreg -p IOUSB -l -w0 | awk -F' = ' '/"idVendor"/{v=$2} /"idProduct"/{print v, $2}')
  a=$(adb devices 2>/dev/null | tail -n +2 | grep -v '^$')
  f=$(fastboot devices 2>/dev/null)
  [ -n "$a" ] && out+="adb: $a"$'\n'
  [ -n "$f" ] && out+="fastboot: $f"$'\n'
  [ -z "$out" ] && out="no phone detected"
  if [ "$out" != "$last" ]; then echo "[$(date +%T)] $out"; last="$out"; fi
  sleep 1
done
