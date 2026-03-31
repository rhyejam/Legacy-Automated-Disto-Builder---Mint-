#!/bin/bash
# =============================================================================
# York IT Reuse - Custom ISO Builder
# Usage: bash build-usb.sh <path-to-linuxmint.iso>
#
# Produces: mint-reuse-YYYYMMDD.iso in the same directory
# Flash with: sudo dd if=mint-reuse-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress conv=fsync
# =============================================================================

set -euo pipefail

SOURCE_ISO="${1:?Usage: $0 <path-to-linuxmint.iso>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_ISO="$SCRIPT_DIR/mint-reuse-$(date +%Y%m%d).iso"

# --- Preflight ----------------------------------------------------------------
if ! command -v xorriso &>/dev/null; then
    echo "ERROR: xorriso not found."
    exit 1
fi

for f in setup.sh post-install.sh packages.txt; do
    [[ -f "$SCRIPT_DIR/$f" ]] || { echo "ERROR: $f not found in $SCRIPT_DIR"; exit 1; }
done

# Remove any existing output ISO so we know the result is fresh
rm -f "$OUTPUT_ISO"

# --- Build --------------------------------------------------------------------
echo "[1/1] Building custom ISO (this takes a few minutes)..."
xorriso -indev "$SOURCE_ISO" \
    -outdev "$OUTPUT_ISO" \
    -map "$SCRIPT_DIR/setup.sh"        /setup.sh \
    -map "$SCRIPT_DIR/post-install.sh" /post-install.sh \
    -map "$SCRIPT_DIR/packages.txt"    /packages.txt \
    -boot_image any replay

echo ""
echo "Done: $OUTPUT_ISO"
echo ""
echo "Flash to USB:   sudo dd if=$OUTPUT_ISO of=/dev/sdX bs=4M status=progress conv=fsync"
