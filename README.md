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

## Installing ROMs (ways to copy)
- **SFTP/SSH (recommended):** From your PC, SFTP to `pi@<pi-ip>` and copy ROMs into the system folders above. Keep MAME zipped; others can be unzipped. Then restart EmulationStation.
- **Network share (if enabled in RetroPie-Setup):** Copy to `\\<pi-ip>\\roms\\<system>` from Windows or `smb://<pi-ip>/roms/<system>` from macOS.
- **USB drive:** Format FAT32/exFAT; create `retropie-mount` folder on the drive, plug into Pi—RetroPie will create roms folders on the USB. Copy your ROMs there, reinsert; ES will use the USB. Remove safely.
- **Local copy (terminal on Pi):** Put ROMs somewhere (e.g., `/home/pi/downloads`), then move:
  - NES example: `mv ~/downloads/*.nes ~/RetroPie/roms/nes/`
  - PSX example: keep `.cue` + `.bin` together: `mv ~/downloads/Game.cue ~/downloads/Game.bin ~/RetroPie/roms/psx/`
- BIOS: drop required BIOS files into `/home/pi/RetroPie/BIOS/`.
- To verify: run `./rom_inventory.sh /home/pi/RetroPie/roms > inventory.csv` (from this repo) to list files/sizes/hashes.

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

## Themes, Scraper, Arcade Polish
- Themes (Install via RetroPie-Setup → Manage Packages → Manage Themes):
  - Fast: `carbon`
  - Clean/artsy: `art-book-next`
  - Box art vibe: `es-theme-nes-box`
- Scraper (CLI):
```
/opt/retropie/supplementary/scraper/scraper -thumb_only
```
- Kiosk/Arcade polish:
  - EmulationStation → UI Settings: On-Screen Help Off (optional), Enable Kiosk Mode to hide config items.
  - Boot to ES: `sudo raspi-config` → System Options → Boot / Auto-Login → Console Auto-Login (RetroPie auto-starts ES).
  - Screensaver: Video/Slideshow for attract-mode; drop MP4s into `/home/pi/.emulationstation/downloaded_media/screenshots/` or set video sources in ES.
  - Bezel packs: RetroPie-Setup → Optional packages → `lr-mame2003-plus` bezels/libretro-bezels; or download system packs and enable overlays per core.
  - Hotkeys: Hotkey=Select; in-game menu = Hotkey+X; exit game = Hotkey+Start.

## EmulationStation (ES) Config Snippets
- ES config path: `/home/pi/.emulationstation/` (configs in XML).
- Auto-start RetroArch menu entry (optional): edit `/opt/retropie/configs/all/emulationstation/es_systems.cfg` to adjust per-system commands. Backup before editing.
- Hide settings for kids: enable Kiosk Mode in ES UI; also set **Start → Other Settings → Enable Filtering** to hide empty systems.
- Kid Mode (favorites-only): ES → Start → UI Settings → Kid Mode = On (only Favorites show; great for kids). Mark games as favorites first (Start → Edit Metadata → Favorite = On).
- Screensaver video dir: ensure media in `/home/pi/.emulationstation/downloaded_media/screenshots/` or point to a custom folder in ES UI settings.
- Favorite games: mark favorites in ES (Start → Edit Metadata) to surface a Favorites system; use Kid Mode to show only these.

## Bezel Pack Links (reference)
- Libretro bezels package (RetroPie optional): install `lr-mame2003-plus` bezels / `libretro-bezels` via RetroPie-Setup → optional packages.
- For system-specific packs: search “libretro bezel pack <system>” and drop overlays into `/opt/retropie/configs/all/retroarch/overlay/`; enable in RetroArch Quick Menu → On-Screen Overlay.

## First-Boot Quick Wins (wow factor)
1) Run `bash setup.sh` (from this repo) to prep packages and folders.
2) Install theme: choose `art-book-next` in ES UI Settings → Theme Set.
3) Scrape art: run the scraper command above (needs network).
4) Enable screensaver: ES → UI Settings → Screensaver Mode = Video (or Slideshow).
5) Kiosk mode on: ES → UI Settings → Kiosk Mode = On (hide settings from kids).
6) Add bezels: enable libretro bezels via RetroPie-Setup optional packages.

## Maintenance
- Monthly: `cd ~/RetroPie-Setup && git pull && sudo ./retropie_setup.sh` (update script + installed packages).
- Backup: `/home/pi/RetroPie/` and `/boot/config.txt`.
- If input mapping breaks: delete the problematic autoconfig in `/opt/retropie/configs/all/retroarch/autoconfig/` and remap in ES.

## Notes
- Use only ROMs/BIOS you have rights to. Keep MAME dev ROMs zipped; place BIOS in `/home/pi/RetroPie/BIOS/` as required by each core.
