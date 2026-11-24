# phone-lab

Repurposing old Android phones (their compute and sensors) for personal projects, driven from a Mac over USB.

## Target hardware

- **OnePlus 6** (codename `enchilada`, Snapdragon 845, A/B partitions) with **no screen and no battery**.
- No screen means USB debugging and OEM unlocking can't be toggled on-device. Plan around fastboot / TWRP (`fastboot boot twrp.img`) and use scrcpy for display once adb works.
- Power is the first blocker: without a battery the phone may not enumerate on USB at all.

## Safety rules

- **Never touch the Pixel 7** (USB `18d1:4ee1`). It's a personal phone plugged in only to charge. Don't run adb/fastboot against it; always pass `-s <serial>` when more than one device is attached.
- Bootloader unlock wipes data. Confirm before running any `fastboot flashing unlock`, `fastboot flash`, or `erase` command.

## Layout

- `scripts/detect.sh`: polls USB (`ioreg`) plus `adb`/`fastboot` and prints the phone's state whenever it changes (EDL 9008, OnePlus, Google/AOSP ids, and so on). Ctrl-C to stop.
- `scripts/probe.sh`: one-shot check of how far we can get: adb authorized? fastboot `get_unlock_ability`? Then it prints which path applies (1: adb + scrcpy, 2: unlock + TWRP, 3: needs a temporary screen).
- `pyproject.toml`: Python 3.12+ project managed with **uv** (`uv sync`, `uv run ...`). Deps: `adbutils`, `pyserial`.

## Conventions

- Scripts are macOS-specific bash (they rely on `ioreg`). Needs `adb` and `fastboot` (Android platform-tools) on PATH.
