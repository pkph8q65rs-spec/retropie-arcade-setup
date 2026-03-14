#!/usr/bin/env bash
set -euo pipefail

# setup.sh: Installer for RetroPie on DietPi (Pi 400 target).
# Usage: bash setup.sh
# Run as root on DietPi. No ROMs/BIOS are installed. You must add your own.
# External drive must be mounted at /media/roms, /media/roms2, /media/extra before running.

# Config
REPO_URL="https://github.com/pkph8q65rs-spec/retropie-arcade-setup.git"
INSTALL_DIR="/root/retropie-arcade-setup"
RETROPIE_SETUP_DIR="/root/RetroPie-Setup"
RETROPIE_DIR="/root/RetroPie"
ROMS_DIR="/media/roms"
ROMS2_DIR="/media/roms2"

log() { echo "[setup] $*"; }

check_drive() {
  log "Checking external drive is mounted..."
  if ! mountpoint -q "$ROMS_DIR"; then
    echo "ERROR: $ROMS_DIR is not mounted. Please mount your external drive first." >&2
    echo "Run: mount /dev/sda2 /media/roms" >&2
    exit 1
  fi
  log "External drive found at $ROMS_DIR."
}

ensure_packages() {
  log "Updating apt and installing prerequisites..."
  apt update
  apt install -y git dialog samba
}

clone_repo() {
  if [ -d "$INSTALL_DIR/.git" ]; then
    log "Repo exists at $INSTALL_DIR; pulling latest..."
    git -C "$INSTALL_DIR" pull --ff-only
  else
    log "Cloning repo to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
  fi
}

install_retropie_setup() {
  if [ -d "$RETROPIE_SETUP_DIR" ]; then
    log "RetroPie-Setup exists; updating..."
    git -C "$RETROPIE_SETUP_DIR" pull --ff-only
  else
    log "Cloning RetroPie-Setup..."
    git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git "$RETROPIE_SETUP_DIR"
  fi
}

create_dirs() {
  log "Creating all ROM/BIOS folders on external drive..."
  mkdir -p \
    "$ROMS_DIR/3do" \
    "$ROMS_DIR/amiga" \
    "$ROMS_DIR/amiga600" \
    "$ROMS_DIR/amiga1200" \
    "$ROMS_DIR/amstradcpc" \
    "$ROMS_DIR/apple2" \
    "$ROMS_DIR/apple2gs" \
    "$ROMS_DIR/arcade" \
    "$ROMS_DIR/atari800" \
    "$ROMS_DIR/atari2600" \
    "$ROMS_DIR/atari5200" \
    "$ROMS_DIR/atari7800" \
    "$ROMS_DIR/atarijaguar" \
    "$ROMS_DIR/atarilynx" \
    "$ROMS_DIR/atarist" \
    "$ROMS_DIR/c64" \
    "$ROMS_DIR/cavestory" \
    "$ROMS_DIR/coleco" \
    "$ROMS_DIR/daphne" \
    "$ROMS_DIR/dreamcast" \
    "$ROMS_DIR/famicom" \
    "$ROMS_DIR/fba" \
    "$ROMS_DIR/fds" \
    "$ROMS_DIR/gamegear" \
    "$ROMS_DIR/gb" \
    "$ROMS_DIR/gba" \
    "$ROMS_DIR/gbc" \
    "$ROMS_DIR/genesis" \
    "$ROMS_DIR/intellivision" \
    "$ROMS_DIR/mame-advmame" \
    "$ROMS_DIR/mame-libretro" \
    "$ROMS_DIR/mame-mame4all" \
    "$ROMS_DIR/mastersystem" \
    "$ROMS_DIR/megadrive" \
    "$ROMS_DIR/megadrive-japan" \
    "$ROMS_DIR/msx" \
    "$ROMS_DIR/msx2" \
    "$ROMS_DIR/n64" \
    "$ROMS_DIR/n64dd" \
    "$ROMS_DIR/nds" \
    "$ROMS_DIR/neogeo" \
    "$ROMS_DIR/neogeocd" \
    "$ROMS_DIR/nes" \
    "$ROMS_DIR/ngp" \
    "$ROMS_DIR/ngpc" \
    "$ROMS_DIR/odyssey2" \
    "$ROMS_DIR/openbor" \
    "$ROMS_DIR/pc" \
    "$ROMS_DIR/pc88" \
    "$ROMS_DIR/pc98" \
    "$ROMS_DIR/pcengine" \
    "$ROMS_DIR/pcenginecd" \
    "$ROMS_DIR/pcfx" \
    "$ROMS_DIR/pico8" \
    "$ROMS_DIR/pokemini" \
    "$ROMS_DIR/ports" \
    "$ROMS_DIR/psp" \
    "$ROMS_DIR/psx" \
    "$ROMS_DIR/residualvm" \
    "$ROMS_DIR/satellaview" \
    "$ROMS_DIR/saturn" \
    "$ROMS_DIR/scummvm" \
    "$ROMS_DIR/sega32x" \
    "$ROMS_DIR/segacd" \
    "$ROMS_DIR/sg-1000" \
    "$ROMS_DIR/snes" \
    "$ROMS_DIR/snesmsu1" \
    "$ROMS_DIR/sufami" \
    "$ROMS_DIR/supergrafx" \
    "$ROMS_DIR/tg16" \
    "$ROMS_DIR/tg-cd" \
    "$ROMS_DIR/vectrex" \
    "$ROMS_DIR/videopac" \
    "$ROMS_DIR/virtualboy" \
    "$ROMS_DIR/wonderswan" \
    "$ROMS_DIR/wonderswancolor" \
    "$ROMS_DIR/x68000" \
    "$ROMS_DIR/zmachine" \
    "$ROMS_DIR/zxspectrum" \
    "$ROMS2_DIR/gamecube" \
    "$ROMS2_DIR/wii" \
    "$ROMS2_DIR/ps2" \
    "$ROMS2_DIR/xbox" \
    "$RETROPIE_DIR/BIOS"

  log "Symlinking /root/RetroPie/roms -> $ROMS_DIR so RetroPie uses the external drive..."
  mkdir -p "$RETROPIE_DIR"
  if [ -d "$RETROPIE_DIR/roms" ] && [ ! -L "$RETROPIE_DIR/roms" ]; then
    log "Backing up existing roms folder..."
    mv "$RETROPIE_DIR/roms" "$RETROPIE_DIR/roms.bak"
  fi
  ln -sf "$ROMS_DIR" "$RETROPIE_DIR/roms"
  log "Symlink created."
}

setup_samba() {
  log "Configuring Samba for Mac/PC network access..."
  cat >> /etc/samba/smb.conf << 'EOF'

[roms]
path = /media/roms
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777

[roms2]
path = /media/roms2
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777

[extra]
path = /media/extra
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777
EOF
  systemctl restart smbd
  log "Samba configured. Connect from Mac: smb://192.168.1.167"
}

setup_autologin() {
  log "Setting up auto-login and auto-start EmulationStation..."
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF

  if ! grep -q "emulationstation" /root/.bashrc; then
    cat >> /root/.bashrc << 'EOF'

# Auto-start EmulationStation on tty1
if [ "$(tty)" = "/dev/tty1" ]; then
  emulationstation
fi
EOF
  fi
  log "Auto-login and auto-start configured."
}

main() {
  log "Starting DietPi RetroPie setup..."
  check_drive
  ensure_packages
  clone_repo
  install_retropie_setup
  create_dirs
  setup_samba
  setup_autologin
  log ""
  log "====================================="
  log "Setup complete! Next steps:"
  log "1. Run RetroPie-Setup: cd $RETROPIE_SETUP_DIR && sudo ./retropie_setup.sh"
  log "2. Choose Basic Install"
  log "3. After install, reboot: sudo reboot"
  log "4. Pi will boot straight into EmulationStation"
  log "5. Copy ROMs from Mac via Finder: smb://192.168.1.167"
  log "====================================="
}

main "$@"