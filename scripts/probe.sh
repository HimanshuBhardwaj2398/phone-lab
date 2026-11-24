#!/usr/bin/env bash
# Works out how far we can get into a screenless OnePlus 6.
# Run with the phone connected, either booted normally or in fastboot
# (power off, then hold Volume Up + Power).

echo "== adb =="
adb_out=$(adb devices | tail -n +2 | grep -v '^$')
if [ -z "$adb_out" ]; then
  echo "not visible to adb"
else
  echo "$adb_out"
  if echo "$adb_out" | grep -q unauthorized; then
    echo "-> USB debugging is ON, but this Mac isn't approved yet (the approval prompt appears on the phone's screen, so a temporary screen is needed once)"
  elif echo "$adb_out" | grep -q device$; then
    echo "-> USB debugging is ON and authorized. Path 1: use adb + scrcpy."
    adb shell getprop ro.product.model
    adb shell getprop ro.build.version.release
  fi
fi

echo; echo "== fastboot =="
if [ -z "$(fastboot devices)" ]; then
  echo "not in fastboot (power off, hold Volume Up + Power, then re-run)"
else
  fastboot devices
  fastboot oem device-info 2>&1 | grep -iE 'unlocked|tampered|charger'
  ability=$(fastboot flashing get_unlock_ability 2>&1 | grep -oE 'get_unlock_ability: *[01]' | grep -oE '[01]$')
  echo "get_unlock_ability: ${ability:-unknown}"
  case "$ability" in
    1) echo "-> OEM unlocking is ON. Path 2: unlock bootloader (wipes data), then 'fastboot boot twrp.img'." ;;
    0) echo "-> OEM unlocking is OFF. Path 3: need a temporary screen to flip the toggles." ;;
  esac
fi
