#!/usr/bin/env bash
set -euo pipefail

# rom_inventory.sh: generate a ROM inventory (path,size bytes,sha256) under a given directory.
# Usage: ./rom_inventory.sh /path/to/roms > inventory.csv
# Tip: run from Pi after copying ROMs. Redirect output to a file.

ROOT=${1:-.}

if [ ! -d "$ROOT" ]; then
  echo "error: directory not found: $ROOT" >&2
  exit 1
fi

echo "path,size_bytes,sha256"
# Exclude hidden/system junk; adjust --type f filter as needed.
find "$ROOT" -type f \( ! -name ".DS_Store" ! -path "*/.git/*" \) -print0 | while IFS= read -r -d '' f; do
  size=$(stat -f%z "$f" 2>/dev/null || stat --printf="%s" "$f")
  hash=$(sha256sum "$f" 2>/dev/null | awk '{print $1}')
  # Fallback for systems without sha256sum (macOS):
  if [ -z "$hash" ]; then
    hash=$(shasum -a 256 "$f" | awk '{print $1}')
  fi
  printf '"%s",%s,%s\n' "$f" "$size" "$hash"
done
