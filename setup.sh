#!/usr/bin/env bash
set -euo pipefail

# setup.sh: Installer for RetroPie on DietPi (Pi 400 target).
# Usage: bash setup.sh
# Run as root on DietPi. No ROMs/BIOS are installed. You must add your own.
# External drive should be mounted at /media/roms, /media/roms2, /media/extra before running.

REPO_URL="https://github.com/pkph8q65rs-spec/retropie-arcade-setup.git"
INSTALL_DIR="/root/retropie-arcade-setup"
RETROPIE_SETUP_DIR="/root/RetroPie-Setup"

PI_USER="pi"
PI_HOME="/home/pi"
RETROPIE_DIR="$PI_HOME/RetroPie"

ROMS_DIR="/media/roms"
ROMS2_DIR="/media/roms2"
EXTRA_DIR="/media/extra"

# Optional EmulationStation interface defaults (applied for pi user).
# Set CUSTOM_UI_ENABLED=0 to skip these UI customizations.
CUSTOM_UI_ENABLED="${CUSTOM_UI_ENABLED:-1}"
CUSTOM_ES_THEME="${CUSTOM_ES_THEME:-carbon}"
CUSTOM_ES_TRANSITION_STYLE="${CUSTOM_ES_TRANSITION_STYLE:-fade}"
CUSTOM_ES_SCREENSAVER_STYLE="${CUSTOM_ES_SCREENSAVER_STYLE:-dim}"
CUSTOM_ES_UI_MODE="${CUSTOM_ES_UI_MODE:-full}"

log() { echo "[setup] $*"; }

check_drive() {
  log "Checking external drive is mounted..."
  if ! mountpoint -q "$ROMS_DIR"; then
    echo "ERROR: $ROMS_DIR is not mounted. Please mount your external drive first." >&2
    echo "Example: mount /dev/sda2 $ROMS_DIR" >&2
    exit 1
  fi

  mkdir -p "$ROMS2_DIR" "$EXTRA_DIR"
  log "External drive found at $ROMS_DIR."
}

ensure_pi_user() {
  if ! id "$PI_USER" >/dev/null 2>&1; then
    log "Creating user '$PI_USER'..."
    useradd -m -s /bin/bash -G sudo,audio,video,input,plugdev,games "$PI_USER"
    echo "$PI_USER:1234" | chpasswd
  else
    log "User '$PI_USER' already exists."
  fi
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
  log "Creating ROM/BIOS folders on external drive..."
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
    "$ROMS_DIR/ports/doom" \
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
    "$RETROPIE_DIR" \
    "$RETROPIE_DIR/BIOS"

  log "Linking $RETROPIE_DIR/roms -> $ROMS_DIR ..."
  mkdir -p "$RETROPIE_DIR"

  if [ -L "$RETROPIE_DIR/roms" ]; then
    rm -f "$RETROPIE_DIR/roms"
  elif [ -e "$RETROPIE_DIR/roms" ]; then
    mv "$RETROPIE_DIR/roms" "$RETROPIE_DIR/roms.bak"
  fi
  ln -s "$ROMS_DIR" "$RETROPIE_DIR/roms"

  log "Linking /root/RetroPie/roms -> $ROMS_DIR for admin convenience..."
  mkdir -p /root/RetroPie
  if [ -L /root/RetroPie/roms ]; then
    rm -f /root/RetroPie/roms
  elif [ -e /root/RetroPie/roms ]; then
    mv /root/RetroPie/roms /root/RetroPie/roms.bak
  fi
  ln -s "$ROMS_DIR" /root/RetroPie/roms

  chown -R "$PI_USER:$PI_USER" "$PI_HOME"
  chown -R "$PI_USER:$PI_USER" "$RETROPIE_DIR"

  if [ -d "$ROMS_DIR" ]; then
    chown -R "$PI_USER:$PI_USER" "$ROMS_DIR" || true
  fi
  if [ -d "$ROMS2_DIR" ]; then
    chown -R "$PI_USER:$PI_USER" "$ROMS2_DIR" || true
  fi
}

setup_samba() {
  log "Configuring Samba for Mac/PC network access..."

  if ! grep -q "^\[roms\]$" /etc/samba/smb.conf; then
    cat >> /etc/samba/smb.conf << 'EOF'

[roms]
path = /media/roms
browseable = yes
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777

[roms2]
path = /media/roms2
browseable = yes
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777

[extra]
path = /media/extra
browseable = yes
writeable = yes
guest ok = yes
create mask = 0777
directory mask = 0777
EOF
  else
    log "Samba shares already present, skipping append."
  fi

  systemctl enable smbd
  systemctl restart smbd
  log "Samba configured."
}

setup_autologin() {
  log "Setting up auto-login for $PI_USER..."
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $PI_USER --noclear %I \$TERM
EOF
}

setup_autostart_es() {
  log "Setting up auto-start EmulationStation for $PI_USER..."

  cat > "$PI_HOME/.bash_profile" << 'EOF'
if [ -n "${SSH_CONNECTION:-}" ]; then
  return
fi

if [ "$(tty)" = "/dev/tty1" ]; then
  if command -v emulationstation >/dev/null 2>&1; then
    emulationstation
  fi
fi
EOF

  chown "$PI_USER:$PI_USER" "$PI_HOME/.bash_profile"

  sed -i '/emulationstation/d' /root/.bashrc 2>/dev/null || true
}

setup_custom_interface() {
  if [ "$CUSTOM_UI_ENABLED" != "1" ]; then
    log "Custom interface disabled (CUSTOM_UI_ENABLED=$CUSTOM_UI_ENABLED)."
    return
  fi

  log "Applying custom EmulationStation interface settings..."

  if ! command -v python3 >/dev/null 2>&1; then
    log "python3 not found; skipping custom interface config."
    return
  fi

  local es_dir="$PI_HOME/.emulationstation"
  local es_settings="$es_dir/es_settings.cfg"

  mkdir -p "$es_dir"

  python3 - "$es_settings" "$CUSTOM_ES_THEME" "$CUSTOM_ES_TRANSITION_STYLE" "$CUSTOM_ES_SCREENSAVER_STYLE" "$CUSTOM_ES_UI_MODE" << 'PY'
import sys
import xml.etree.ElementTree as ET

settings_path, theme, transition, screensaver, ui_mode = sys.argv[1:]

try:
    tree = ET.parse(settings_path)
    root = tree.getroot()
except Exception:
    root = ET.Element("config")
    tree = ET.ElementTree(root)

def set_string(name: str, value: str) -> None:
    for elem in root.findall("string"):
        if elem.get("name") == name:
            elem.set("value", value)
            return
    ET.SubElement(root, "string", name=name, value=value)

set_string("ThemeSet", theme)
set_string("TransitionStyle", transition)
set_string("ScreenSaverBehavior", screensaver)
set_string("UIMode", ui_mode)

tree.write(settings_path, encoding="utf-8", xml_declaration=True)
PY

  chown -R "$PI_USER:$PI_USER" "$es_dir"
  log "Custom interface configured (theme=$CUSTOM_ES_THEME, ui_mode=$CUSTOM_ES_UI_MODE)."
}

main() {
  log "Starting DietPi RetroPie setup..."
  check_drive
  ensure_pi_user
  ensure_packages
  clone_repo
  install_retropie_setup
  create_dirs
  setup_samba
  setup_autologin
  setup_autostart_es
  setup_custom_interface

  log ""
  log "====================================="
  log "Setup complete! Next steps:"
  log "1. Run RetroPie-Setup:"
  log "   cd $RETROPIE_SETUP_DIR && ./retropie_setup.sh"
  log "2. Choose Basic Install"
  log "3. Install optional packages you want"
  log "4. Reboot"
  log "5. Pi will auto-login as $PI_USER and launch EmulationStation"
  log "6. Copy ROMs from Mac via Finder: smb://192.168.1.167"
  log "====================================="
}

main "$@"
