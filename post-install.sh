#!/bin/bash
# =============================================================================
# York IT Reuse - Post-Install Package Installer
# Run as root (sudo) after connecting the PC to the internet.
# Usage: sudo bash post-install.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_LIST="$SCRIPT_DIR/packages.txt"

# --- Preflight checks --------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo."
    echo "  sudo bash $0"
    exit 1
fi

if [[ ! -f "$PACKAGE_LIST" ]]; then
    echo "ERROR: packages.txt not found at $PACKAGE_LIST"
    exit 1
fi

# --- Check internet connectivity ---------------------------------------------
echo "Checking internet connection..."
if ! ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
    echo "ERROR: No internet connection detected. Connect to the internet and try again."
    exit 1
fi
echo "Internet OK."

# --- Parse package list (skip blanks and comments) ---------------------------
mapfile -t PACKAGES < <(grep -v -E '^\s*(#|$)' "$PACKAGE_LIST")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found in packages.txt. Nothing to install."
    exit 0
fi

echo ""
echo "Packages to install: ${PACKAGES[*]}"
echo ""

# --- Install -----------------------------------------------------------------
apt-get update -qq

FAILED=()
for pkg in "${PACKAGES[@]}"; do
    echo "Installing: $pkg"
    if ! apt-get install -y "$pkg" -qq; then
        echo "  WARNING: Failed to install $pkg"
        FAILED+=("$pkg")
    fi
done

# --- Report ------------------------------------------------------------------
echo ""
echo "================================================"
if [[ ${#FAILED[@]} -eq 0 ]]; then
    echo "All packages installed successfully."
else
    echo "Completed with errors. Failed packages:"
    printf '  - %s\n' "${FAILED[@]}"
    echo "Check package names in packages.txt."
fi
echo "================================================"

# --- Zoom --------------------------------------------------------------------
echo ""
echo "Installing Zoom..."
ZOOM_DEB="/tmp/zoom_amd64.deb"
if wget -q --show-progress -O "$ZOOM_DEB" "https://zoom.us/client/latest/zoom_amd64.deb"; then
    apt-get install -y "$ZOOM_DEB"
    rm -f "$ZOOM_DEB"
    echo "Zoom installed."
else
    echo "  WARNING: Failed to download Zoom. Install manually later from https://zoom.us/download"
fi

# --- Nvidia drivers ----------------------------------------------------------
echo ""
echo "Checking for NVIDIA GPU..."
if lspci | grep -qi nvidia; then
    echo "NVIDIA GPU detected. Installing drivers (this may take a few minutes)..."
    apt-get install -y ubuntu-drivers-common
    ubuntu-drivers install
    echo "NVIDIA drivers installed. Reboot will apply them."
else
    echo "No NVIDIA GPU detected. Skipping."
fi

# --- System upgrade ----------------------------------------------------------
echo ""
echo "Running system upgrade..."
apt-get upgrade -y
echo "Upgrade complete."

# --- Security hardening ------------------------------------------------------
echo ""
echo "Applying security hardening..."

# A: Firewall — block unsolicited inbound connections
echo "  [1/4] Enabling firewall..."
apt-get install -y ufw -qq
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
echo "        Done — firewall active (deny incoming, allow outgoing)."

# B: Automatic security updates — patches applied silently in the background
echo "  [2/4] Enabling automatic security updates..."
apt-get install -y unattended-upgrades -qq
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true \
    | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades
echo "        Done — security updates will apply automatically."

# C: Disable guest session on the login screen
echo "  [3/4] Disabling guest login..."
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/40-no-guest.conf << 'EOF'
[SeatDefaults]
allow-guest=false
EOF
echo "        Done — guest session disabled."

# D: Lock screen when the machine is suspended or lid is closed
echo "  [4/4] Enabling lock screen on suspend..."
mkdir -p /etc/dconf/db/local.d /etc/dconf/profile
cat > /etc/dconf/db/local.d/01-screensaver << 'EOF'
[org/cinnamon/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 0
EOF
if [[ ! -f /etc/dconf/profile/user ]]; then
    printf 'user-db:user\nsystem-db:local\n' > /etc/dconf/profile/user
fi
dconf update
echo "        Done — screen locks on suspend."

echo ""
echo "Security hardening complete."

# --- Reboot ------------------------------------------------------------------
echo ""
echo "All done. Rebooting in 10 seconds..."
echo "(Press Ctrl+C to cancel the reboot if needed.)"
sleep 10
reboot
