#!/usr/bin/env bash
set -euo pipefail

# setup.sh: User-run installer for RetroPie on Pi (Pi 400 target), plus this repo's files.
# Usage: bash setup.sh
# Notes: run as pi user on Raspberry Pi OS. No ROMs/BIOS are installed. You must add your own.

# Config
REPO_URL="https://github.com/pkph8q65rs-spec/retropie-arcade-setup.git"
INSTALL_DIR="$HOME/retropie-arcade-setup"
RETROPIE_SETUP_DIR="$HOME/RetroPie-Setup"

log() { echo "[setup] $*"; }

ensure_packages() {
  log "Updating apt and installing prerequisites (git, dialog)..."
  sudo apt update
  sudo apt install -y git dialog
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

run_retropie_basic() {
  log "Launching RetroPie-Setup (you must select Basic Install)."
  log "Navigate: Manage packages → core/optional as needed."
  (cd "$RETROPIE_SETUP_DIR" && sudo ./retropie_setup.sh)
}

create_dirs() {
  log "Creating ROM/BIOS folders..."
  mkdir -p \
    "$HOME/RetroPie/roms/nes" \
    "$HOME/RetroPie/roms/snes" \
    "$HOME/RetroPie/roms/megadrive" \
    "$HOME/RetroPie/roms/psx" \
    "$HOME/RetroPie/roms/n64" \
    "$HOME/RetroPie/roms/psp" \
    "$HOME/RetroPie/roms/mame-libretro" \
    "$HOME/RetroPie/BIOS"
  log "Folders ready. Add your ROMs/BIOS to these directories. Keep MAME ROMs zipped; PSX BIOS in /home/pi/RetroPie/BIOS."
}

main() {
  log "Starting setup..."
  ensure_packages
  clone_repo
  install_retropie_setup
  create_dirs
  log "Run RetroPie-Setup next to install core/optional packages:"
  log "  cd $RETROPIE_SETUP_DIR && sudo ./retropie_setup.sh"
  log "After install, restart EmulationStation to see systems once ROMs are added."
  log "Done."
}

main "$@"
