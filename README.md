# RetroPie Arcade Setup (Pi 400)

## Install RetroPie
1) Update OS
```
sudo apt update && sudo apt full-upgrade -y && sudo reboot
```
2) Install RetroPie setup script
```
sudo apt install -y git dialog
cd ~
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
```
3) Run setup
```
sudo ./retropie_setup.sh
```
- Choose **Basic Install** (core + emulators).
- Later updates: `cd ~/RetroPie-Setup && git pull && sudo ./retropie_setup.sh` (Update script, then Update installed packages).

## Controllers & Arcade Controls
- First boot in EmulationStation: hold a button → map directions, ABXY, L/R, Start/Select, set **Hotkey = Select**.
- Gamepads
  - USB: plug-and-play.
  - Bluetooth: `bluetoothctl` → `power on` → `agent on` → `scan on` → `pair` / `trust` / `connect <MAC>` → `quit`.
    - PS4/PS5: hold Share+PS to pair. Xbox One/Series: hold Pair.
- Arcade stick/buttons
  - USB encoder (Xin-Mo/Zero Delay): shows as gamepad—map in ES.
  - GPIO wiring: RetroPie-Setup → Manage Packages → drivers → install `mk_arcade_joystick_rpi`; configure per its README, then map in ES.

## ROM & BIOS Layout (create folders)
```
/home/pi/RetroPie/roms/nes
/home/pi/RetroPie/roms/snes
/home/pi/RetroPie/roms/megadrive   # or genesis
/home/pi/RetroPie/roms/psx
/home/pi/RetroPie/roms/n64
/home/pi/RetroPie/roms/psp
/home/pi/RetroPie/roms/mame-libretro
/home/pi/RetroPie/BIOS
```
- Keep MAME ROMs zipped. Others can be unzipped for faster loads.
- PSX: use .cue+.bin pairs; place BIOS in `/home/pi/RetroPie/BIOS/`.
  - Common BIOS: `scph1001.bin` (US), `scph5501.bin` (US), `scph5502.bin` (EU), `scph5500.bin` (JP). Check hashes in RetroArch → Information → Core Info → Firmware.
- N64: `.z64/.n64/.v64`; no BIOS needed.
- PSP: `.iso/.cso`; no BIOS needed.
- After copying ROMs/BIOS: Restart EmulationStation (Start → Quit → Restart EmulationStation).

## Performance Tweaks (Pi 400)
- GPU memory split: `sudo raspi-config` → Performance → GPU Memory = **256** (3D) or **128** (2D). Reboot.
- Shaders: keep light or off. Good light options: `zfast_crt.glsl`, `crt-pi.glslp`, `sharp-bilinear`. Turn off for 3D systems.
- N64: use **lr-mupen64plus-next**; plugin rice/glide64; resolution 640x480 or lower; shaders off.
- PSP: PPSSPP; rendering res 1x; frameskip 1–2 if needed; buffer effects off.
- PSX: runahead = 1 frame if smooth; otherwise off.
- Audio: RetroArch → Settings → Audio → Output = `alsathread`; Latency ~64–128 ms if crackle.
- Optional overclock (watch temps, ensure cooling; edit `/boot/config.txt`):
```
over_voltage=2
arm_freq=1950
gpu_freq=600
force_turbo=0
```
Monitor temps: `watch -n 2 vcgencmd measure_temp`

## Themes & Scraper
- Themes: RetroPie-Setup → Manage Packages → Manage Themes. Lightweight: `carbon`, `simple`, `art-book-next`.
- Scraper: Start → Scraper in ES; or install CLI scraper (RetroPie-Setup → optional → scraper), then run:
```
/opt/retropie/supplementary/scraper/scraper -thumb_only
```

## Maintenance
- Monthly: `cd ~/RetroPie-Setup && git pull && sudo ./retropie_setup.sh` (update script + installed packages).
- Backup: `/home/pi/RetroPie/` and `/boot/config.txt`.
- If input mapping breaks: delete the problematic autoconfig in `/opt/retropie/configs/all/retroarch/autoconfig/` and remap in ES.

## Notes
- Use only ROMs/BIOS you have rights to. Keep MAME dev ROMs zipped; place BIOS in `/home/pi/RetroPie/BIOS/` as required by each core.
