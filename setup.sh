#!/bin/bash
# =============================================================================
# York IT Reuse - Linux Mint Guided Install
# Run from the live desktop terminal: bash /cdrom/setup.sh
# =============================================================================

# ── Metadata (update when changing the script) ───────────────────────────────
MINT_VERSION="21.3 'Virginia'"
LAST_EDIT="2026-03-31"
AUTHOR="Miles James"
CONTACT="miljam90@proton.me"
ORG="York IT Reuse"
# ─────────────────────────────────────────────────────────────────────────────

# Re-escalate as root while preserving the display session
if [[ $EUID -ne 0 ]]; then
    exec sudo --preserve-env=DISPLAY,XAUTHORITY bash "$0" "$@"
fi

# ── Banner ────────────────────────────────────────────────────────────────────

clear

# NOTE: title rows are centred inside the 40-char laptop screen.
# Adjust spacing if MINT_VERSION length changes.
cat << ASCIIART
⠀⠀⠀⠀⠀⠀⠀⠀⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿             York IT Reuse              ⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿       Linux Mint $MINT_VERSION       ⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿            Installation ISO            ⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣰⠾⠓⢛⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⡟⣿⣿⣿⣿⣻⣿⣟⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡻⣿⠤⣄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⡴⠚⠁⠀⣴⣿⣿⣿⣿⢿⣿⣿⢿⣿⡿⣿⣿⣿⣾⣿⣿⣿⣿⣾⣿⣧⣿⣿⣾⣿⣧⣿⣿⣿⣿⣿⣿⣿⣾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⠀⠛⢦⡀⠀⠀⠀⠀
⠀⣠⠔⠋⠀⠀⠀⠾⠿⠿⠗⠿⠾⠿⠷⠿⠿⠿⠿⠿⠿⠿⠿⠿⠰⠅⠀⠀⣀⣀⣀⣀⣀⡀⠀⠀⠸⠀⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠆⠀⠀⠈⠷⣄⠀⠀
⣾⣧⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣄⣤⡤⢤⢤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣬⣷⣠
ASCIIART

printf '\n  Author     :  %s\n' "$AUTHOR"
printf   '  Contact    :  %s\n' "$CONTACT"
printf   '  Last edit  :  %s\n' "$LAST_EDIT"
printf '\n%s\n\n' "══════════════════════════════════════════════════════════"

# ── Drive info helper ─────────────────────────────────────────────────────────
# Returns a single human-readable line for a given block device name.
# Output goes directly to stdout — never capture this with $() into a variable.

disk_info() {
    local dev="$1" size type model rot
    size=$(lsblk -dno SIZE "/dev/$dev" 2>/dev/null || echo "?")
    rot=$(cat "/sys/block/$dev/queue/rotational" 2>/dev/null || echo 1)
    [[ "$rot" == "0" ]] && type="SSD" || type="HDD"
    model=$(cat "/sys/block/$dev/device/model" 2>/dev/null | xargs || echo "Unknown")
    printf "/dev/%-12s  %-4s  %-8s  %s" "$dev" "$type" "$size" "$model"
}

# ── Detect drives ─────────────────────────────────────────────────────────────

mapfile -t ALL_DISKS < <(lsblk -dno NAME \
    | grep -E '^(sd[a-z]|nvme[0-9]+n[0-9]+|vd[a-z])' \
    | sort)

if [[ ${#ALL_DISKS[@]} -eq 0 ]]; then
    echo "ERROR: No drives detected. Check hardware connections and try again."
    exit 1
fi

echo "Drives found on this machine:"
echo ""
for i in "${!ALL_DISKS[@]}"; do
    printf "  %d)  %s\n" "$((i+1))" "$(disk_info "${ALL_DISKS[$i]}")"
done
echo ""

# ── Drive selection ───────────────────────────────────────────────────────────
# select_drive writes the chosen device name to SELECTED_DISK.
# Never call this inside $() — it must run in the current shell.

SELECTED_DISK=""
ROOT_DISK=""
HOME_DISK=""

select_drive() {
    local prompt_text="$1"
    local exclude="${2:-}"
    local opts=() i n

    for i in "${!ALL_DISKS[@]}"; do
        [[ "${ALL_DISKS[$i]}" == "$exclude" ]] && continue
        opts+=("${ALL_DISKS[$i]}")
    done

    if [[ ${#opts[@]} -eq 0 ]]; then
        echo "ERROR: No eligible drives remaining."
        exit 1
    fi

    echo ""
    for i in "${!opts[@]}"; do
        printf "  %d)  %s\n" "$((i+1))" "$(disk_info "${opts[$i]}")"
    done
    echo ""

    while true; do
        read -rp "  $prompt_text: " n
        if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#opts[@]} )); then
            SELECTED_DISK="${opts[$((n-1))]}"
            return
        fi
        echo "  Invalid — please enter a number between 1 and ${#opts[@]}."
    done
}

# ── Storage layout ────────────────────────────────────────────────────────────

if [[ ${#ALL_DISKS[@]} -eq 1 ]]; then
    ROOT_DISK="${ALL_DISKS[0]}"
    echo "Only one drive found — will install to: $(disk_info "$ROOT_DISK")"
    echo ""
else
    echo "How should storage be configured on this machine?"
    echo ""
    echo "  1)  Single drive   — install everything on one drive"
    echo "  2)  Dual drive     — OS on SSD, user files on separate HDD"
    echo ""

    while true; do
        read -rp "  Enter 1 or 2: " layout
        case "$layout" in
            1)
                echo ""
                echo "Select the drive to install Linux Mint on:"
                select_drive "Enter the number of the installation drive"
                ROOT_DISK="$SELECTED_DISK"
                break
                ;;
            2)
                if [[ ${#ALL_DISKS[@]} -lt 2 ]]; then
                    echo "  Only one drive detected — dual drive is not available."
                    continue
                fi
                echo ""
                echo "Select the SSD — Linux Mint (the operating system) will be installed here:"
                select_drive "Enter the number of the SSD (operating system drive)"
                ROOT_DISK="$SELECTED_DISK"
                echo ""
                echo "Select the HDD — user files and documents will be stored here:"
                select_drive "Enter the number of the HDD (user files drive)" "$ROOT_DISK"
                HOME_DISK="$SELECTED_DISK"
                break
                ;;
            *)
                echo "  Please enter 1 or 2."
                ;;
        esac
    done
fi

# ── Confirmation ──────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════════════════"
echo "  INSTALLATION PLAN"
echo "══════════════════════════════════════════════════════════"
echo ""
printf "  Operating system  :  %s\n" "$(disk_info "$ROOT_DISK")"
[[ -n "$HOME_DISK" ]] && \
printf "  User files        :  %s\n" "$(disk_info "$HOME_DISK")"
echo ""
echo "  !! ALL DATA ON THE ABOVE DRIVE(S) WILL BE PERMANENTLY ERASED !!"
echo ""
read -rp "  Type YES in capitals to confirm and begin: " confirm
[[ "$confirm" != "YES" ]] && { echo "Cancelled. No changes made."; exit 0; }

# ── Pre-partition the HDD for /home (dual drive only) ─────────────────────────

HOME_UUID=""
HOME_PART=""

if [[ -n "$HOME_DISK" ]]; then
    echo ""
    echo "Preparing user files drive (/dev/$HOME_DISK)..."

    wipefs -a "/dev/$HOME_DISK"
    parted -s "/dev/$HOME_DISK" mklabel msdos mkpart primary ext4 1MiB 100%
    partprobe "/dev/$HOME_DISK"
    sleep 2

    if [[ "$HOME_DISK" == nvme* ]]; then
        HOME_PART="${HOME_DISK}p1"
    else
        HOME_PART="${HOME_DISK}1"
    fi

    mkfs.ext4 -F "/dev/$HOME_PART"
    HOME_UUID=$(blkid -s UUID -o value "/dev/$HOME_PART")
    echo "  Done. UUID: $HOME_UUID"
fi

# ── Build late_command ────────────────────────────────────────────────────────

if [[ -n "$HOME_DISK" ]]; then
    LATE_CMD="\
cp /cdrom/post-install.sh /target/home/user/post-install.sh ; \
cp /cdrom/packages.txt /target/home/user/packages.txt ; \
chown 1000:1000 /target/home/user/post-install.sh /target/home/user/packages.txt ; \
chmod +x /target/home/user/post-install.sh ; \
mkdir -p /target/mnt/newhome ; \
mount /dev/${HOME_PART} /target/mnt/newhome ; \
cp -a /target/home/. /target/mnt/newhome/ ; \
umount /target/mnt/newhome ; \
rmdir /target/mnt/newhome ; \
echo 'UUID=${HOME_UUID} /home ext4 defaults 0 2' >> /target/etc/fstab"
else
    LATE_CMD="\
cp /cdrom/post-install.sh /target/home/user/post-install.sh ; \
cp /cdrom/packages.txt /target/home/user/packages.txt ; \
chown 1000:1000 /target/home/user/post-install.sh /target/home/user/packages.txt ; \
chmod +x /target/home/user/post-install.sh"
fi

# ── Generate preseed ──────────────────────────────────────────────────────────

echo ""
echo "Configuring installer for /dev/$ROOT_DISK ..."

cat > /tmp/reuse-preseed.cfg << EOF
d-i debian-installer/locale string en_GB.UTF-8
d-i localechooser/languagelist select en
keyboard-configuration keyboard-configuration/layoutcode select gb
keyboard-configuration keyboard-configuration/variantcode select
keyboard-configuration keyboard-configuration/layout select English (UK)
keyboard-configuration keyboard-configuration/variant select English (UK)
keyboard-configuration keyboard-configuration/modelcode select pc105
d-i keyboard-configuration/xkb-keymap select gb
d-i clock-setup/utc boolean true
d-i time/zone string Europe/London

d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string mintpc
d-i netcfg/get_domain string local

d-i passwd/user-fullname string User
d-i passwd/username string user
d-i passwd/user-password password changeme
d-i passwd/user-password-again password changeme
d-i user-setup/allow-password-weak boolean true
d-i passwd/root-login boolean false

d-i partman-auto/purge_lvm_from_device boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-partitioning/default_label string msdos
d-i partman-auto/disk string /dev/${ROOT_DISK}
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string /dev/${ROOT_DISK}
d-i grub-installer/with_other_os boolean false

d-i preseed/late_command string ${LATE_CMD}
d-i finish-install/reboot_in_progress note

ubiquity ubiquity/download_updates boolean false
ubiquity ubiquity/use_nonfree boolean false
ubiquity ubiquity/reboot boolean true
ubiquity ubiquity/summary note
EOF

# ── Run installer (no GUI — fully automated) ──────────────────────────────────

echo "Loading configuration..."
debconf-set-selections /tmp/reuse-preseed.cfg

echo ""
echo "══════════════════════════════════════════════════════════"
echo "  Installation started. Do not close this terminal."
echo "  The machine will reboot automatically when complete."
echo "  Estimated time: 15-20 minutes."
echo "══════════════════════════════════════════════════════════"
echo ""

UBIQUITY_AUTOMATIC=1 UBIQUITY_FRONTEND=noninteractive ubiquity --automatic
