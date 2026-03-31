#!/bin/bash
# =============================================================================
# York IT Reuse - Build and Flash USB
# Usage: sudo -E bash ~/reuse-install/flash-usb.sh <path-to-mint.iso>
#        (the -E flag preserves your PATH so xorriso can be found)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_ISO="${1:?Usage: sudo -E bash $0 <path-to-linuxmint.iso>}"
TARGET="/dev/sdb"

# ── Preflight ─────────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run with sudo -E:"
    echo "  sudo -E bash $0 $SOURCE_ISO"
    exit 1
fi

if ! command -v xorriso &>/dev/null; then
    echo "ERROR: xorriso not found. Make sure you used sudo -E to preserve PATH."
    exit 1
fi

if [[ ! -f "$SOURCE_ISO" ]]; then
    echo "ERROR: Source ISO not found: $SOURCE_ISO"
    exit 1
fi

if [[ ! -b "$TARGET" ]]; then
    echo "ERROR: $TARGET not found. Is the USB plugged in?"
    exit 1
fi

echo "Source ISO : $SOURCE_ISO"
echo "USB target : $TARGET"
echo ""
read -rp "Type YES to build and flash (THIS WILL ERASE THE USB): " confirm
[[ "$confirm" != "YES" ]] && { echo "Cancelled."; exit 0; }

# ── Step 1: Build custom ISO ──────────────────────────────────────────────────

echo ""
echo "[1/2] Building custom ISO..."
bash "$SCRIPT_DIR/build-usb.sh" "$SOURCE_ISO"

# build-usb.sh deletes then recreates the ISO, so we know this file is fresh
OUTPUT_ISO="$SCRIPT_DIR/mint-reuse-$(date +%Y%m%d).iso"

if [[ ! -f "$OUTPUT_ISO" ]]; then
    echo "ERROR: Expected ISO not found: $OUTPUT_ISO"
    exit 1
fi

ISO_SIZE=$(stat -c%s "$OUTPUT_ISO")
if (( ISO_SIZE < 2000000000 )); then
    echo "ERROR: Built ISO is only ${ISO_SIZE} bytes — build failed."
    exit 1
fi

echo "Verified: $OUTPUT_ISO ($(numfmt --to=iec "$ISO_SIZE"))"

# ── Step 2: Flash to USB ──────────────────────────────────────────────────────

echo ""
echo "[2/2] Flashing to $TARGET — this will take a few minutes..."
dd if="$OUTPUT_ISO" of="$TARGET" bs=4M status=progress conv=fsync

echo ""
echo "======================================================"
echo "  Done. USB is ready."
echo ""
echo "  Technician instructions:"
echo "    1. Set BIOS to Legacy / CSM, disable Secure Boot"
echo "    2. Boot from USB"
echo "    3. Open terminal: bash /cdrom/setup.sh"
echo "======================================================"
