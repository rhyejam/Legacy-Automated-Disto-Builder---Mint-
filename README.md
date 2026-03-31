# Legacy Automated Distro Builder — Mint

Automated Linux Mint installer for legacy hardware. Plug in the USB, run one command, select the drives, walk away.

**No Linux experience required to follow this guide.**

---

## Contents

- [What this does](#what-this-does)
- [What you'll need](#what-youll-need)
- [First-time setup](#first-time-setup)
- [Building the installer USB](#building-the-installer-usb)
- [Installing on legacy hardware](#installing-on-legacy-hardware)
- [Post-install setup](#post-install-internet-required)
- [Adding or removing apps](#adding-or-removing-apps)
- [Troubleshooting](#troubleshooting)
- [How the scripts work](#how-the-scripts-work)
- [Reference](#reference)

---

## What this does

These scripts build a custom Linux Mint installer USB stick. You plug it into a legacy machine, run one command, answer two questions about the hard drives, then leave it. The machine installs itself and reboots ready to use.

---

## What you'll need

**To build the installer USB** (done once, or whenever the scripts are updated):
- A Linux PC or laptop to build on
- A USB stick, **8 GB or larger** — it will be completely wiped
- An internet connection

**To install on a legacy machine:**
- The installer USB
- The target machine — no internet needed during install

---

## First-time setup

> Only needs doing once on the machine you use to build USBs.

### 1. Install xorriso

Open a terminal and run the correct command for your system:

**Ubuntu or Linux Mint:**
```bash
sudo apt install xorriso
```

**NixOS:**
```bash
nix profile add nixpkgs#xorriso
```

### 2. Download the Linux Mint ISO

Download the ISO directly:

```
https://pub.linuxmint.io/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso
```

Or choose a mirror closer to you from the official page: https://www.linuxmint.com/edition.php?id=311

- Edition: **Cinnamon**
- Version: **21.3 "Virginia"**
- Type: **64-bit**

Save it to your Downloads folder. The file is around 2.9 GB.

### 3. Get the scripts

```bash
git clone https://github.com/rhyejam/ladb-mint.git ~/ladb-mint
```

Or download the ZIP from GitHub, extract it, and place the folder at `~/ladb-mint`.

---

## Building the installer USB

> Repeat this any time you update the scripts.

1. Plug in the USB stick
2. Open a terminal
3. Run:

```bash
sudo -E bash ~/ladb-mint/flash-usb.sh ~/Downloads/linuxmint-21.3-cinnamon-64bit.iso
```

4. Type `YES` when prompted
5. Wait — the build and flash takes **5–10 minutes** and shows a progress counter
6. When done you'll see `Done. USB is ready.`

Label the USB and keep it safe.

---

## Installing on legacy hardware

### Step 1 — BIOS settings

> Do this once per machine before booting from the USB.

Power on the PC and press the BIOS key repeatedly as it starts. The key varies — common ones are `F2`, `F10`, `F12`, or `Delete`. Watch for a prompt on screen during startup.

In the BIOS, set the following:

| Setting | Value |
|---|---|
| Boot Mode | **Legacy** or **CSM** (not UEFI) |
| Secure Boot | **Disabled** |
| Boot Order | **USB first** |

Save and exit — usually `F10`.

> **Why Legacy mode?** Legacy hardware is typically 5+ years old. Legacy/CSM mode is far more reliable on older machines than UEFI.

---

### Step 2 — Boot from USB

1. Plug in the installer USB
2. Power on the PC
3. Wait for the Linux Mint desktop to load

> Old hardware can take **3–5 minutes** to reach the desktop — this is normal. If it appears stuck on the Mint logo, press `Escape`, or reboot and select **Compatibility Mode** from the boot menu.

---

### Step 3 — Run the installer

Once the desktop has loaded:

1. Right-click the desktop and choose **Open Terminal** (or find it in the taskbar)
2. Type the following exactly and press `Enter`:

```
bash /cdrom/setup.sh
```

---

### Step 4 — Select drives

The script shows the drives it has found. Example:

```
Drives found on this machine:

  1)  /dev/nvme0n1   SSD   238.5G   SAMSUNG MZVLB256
  2)  /dev/sda       HDD   931.5G   WDC WD10JPVX
  3)  /dev/sdb       HDD    14.6G   ProductCode

How should storage be configured on this machine?

  1)  Single drive   — install everything on one drive
  2)  Dual drive     — OS on SSD, user files on separate HDD
```

**Single drive** — choose `1`, then select the drive number to install on.

**Dual drive** (SSD + HDD) — choose `2`, then:
- Select the SSD number when asked for the operating system drive
- Select the HDD number when asked for the user files drive

> **Do not select the USB stick.** It will appear as a small drive (14–16 GB) labelled something like `ProductCode`. The internal drives will be larger.

---

### Step 5 — Confirm and walk away

Type `YES` in capitals when prompted, then leave it. The install takes **15–20 minutes** and the PC reboots itself when done.

After rebooting, the PC is ready. Default login:

| | |
|---|---|
| Username | `user` |
| Password | `changeme` |

---

## Post-install (internet required)

Once connected to the internet, the end user (or a tech) runs:

```bash
sudo bash ~/post-install.sh
```

> The terminal will ask for the password — it is `changeme`.

This installs all apps, applies security settings, and reboots. It takes **10–20 minutes** depending on internet speed.

**Apps installed:**
- LibreOffice (office suite)
- Chromium (web browser)
- VLC (media player)
- GIMP (photo editor)
- Thunderbird (email)
- Zoom (video calls)
- GNOME Disk Utility (drive management)

**Security applied:**
- Firewall enabled
- Automatic security updates enabled
- Guest login disabled
- Screen locks when the PC is suspended or lid is closed

**If an NVIDIA graphics card is detected**, the correct drivers are installed automatically.

> The machine reboots automatically at the end. Remind the end user to **change their password** after logging in.

---

## Adding or removing apps

Open `packages.txt` in any text editor. One package per line. Lines beginning with `#` are comments and are skipped.

```
# This line is ignored
vlc
libreoffice
# thunderbird   ← commented out, won't install
thunderbird     ← active, will install
```

To find the exact package name for an app, search at:
https://packages.ubuntu.com — select **Jammy** from the dropdown.

After editing `packages.txt`, rebuild and reflash the USB so the updated file is included in future installs.

---

## Troubleshooting

**PC won't boot from the USB**
- Double-check BIOS: Legacy/CSM mode on, Secure Boot off, USB first in boot order
- Try a different USB port — prefer USB 2.0 ports on older machines

**Stuck on the Mint logo for more than 5 minutes**
- Reboot and select **Compatibility Mode** from the boot menu
- This adds a graphics fallback (`nomodeset`) that helps older GPUs

**"No drives detected" error**
- Check internal drive cables are seated properly
- The script only lists internal drives — it won't detect external USB drives as install targets

**Script fails or PC reboots unexpectedly during install**
- Reboot from the USB and run `bash /cdrom/setup.sh` again — it is safe to re-run

**Post-install fails on a package**
- The script reports which packages failed and continues with the rest
- Check the spelling in `packages.txt` — package names are case-sensitive

---

## How the scripts work

### build-usb.sh

`build-usb.sh` takes the official Linux Mint ISO and injects the three local files (`setup.sh`, `post-install.sh`, `packages.txt`) into it, producing a new custom ISO.

It uses **xorriso** to do this non-destructively — the original Mint ISO is left untouched. The custom ISO is identical to the official one except for the three added files, which land in the root of the disc (`/cdrom/` when booted). The original boot configuration is preserved exactly using `-boot_image any replay`, so the USB boots the same way a standard Mint USB would.

Any previous output ISO is deleted before building, so you always know the result is fresh.

Output filename format: `mint-reuse-YYYYMMDD.iso`

`flash-usb.sh` is a wrapper that calls `build-usb.sh` and then immediately flashes the result to the USB with `dd`. It also validates that the output ISO is at least 2 GB before flashing, catching silent build failures before they produce a broken USB.

---

### setup.sh

`setup.sh` runs on the live Mint desktop (booted from the USB) and fully automates the installation. Here is what it does in order:

**1. Drive detection**

It scans for all internal block devices — SATA drives (`sda`, `sdb`...), NVMe drives (`nvme0n1`...), and virtual drives (`vda`...). For each one it reads the size, model, and whether it is an SSD or HDD directly from the kernel (`/sys/block/`), and displays them in a numbered list.

**2. Storage layout**

If only one drive is found, it is used automatically. If multiple drives are present, the technician chooses between:

- **Single drive** — everything on one disk
- **Dual drive** — OS on one disk (typically an SSD), user files on a separate disk (typically an HDD)

Drive selection uses a global variable (`SELECTED_DISK`) rather than command substitution (`$(...)`). This is intentional — command substitution captures all stdout, which would corrupt the drive name by including menu text.

**3. Dual drive preparation**

If dual drive is chosen, the script partitions and formats the second drive as ext4 before the installer runs. It records the partition's UUID so it can be written into `/etc/fstab` by the installer, mounting it automatically as `/home` on every boot.

**4. Preseed generation**

The script generates a debconf preseed file at `/tmp/reuse-preseed.cfg`. This file contains every answer the Ubiquity installer would normally ask for interactively:

- Locale, language, keyboard layout (UK English)
- Timezone (Europe/London)
- Hostname (`mintpc`), default user (`user`), default password (`changeme`)
- Disk partitioning (wipes the target drive, single partition, MBR/msdos label)
- GRUB bootloader target
- A `late_command` that copies `post-install.sh` and `packages.txt` from the USB into the newly installed system's home directory

**5. Automated install**

The preseed is loaded with `debconf-set-selections` and Ubiquity is launched in fully non-interactive mode:

```bash
UBIQUITY_AUTOMATIC=1 UBIQUITY_FRONTEND=noninteractive ubiquity --automatic
```

No GUI appears. The install runs entirely in the terminal and the machine reboots itself when complete.

---

## Reference

### Default credentials

| | |
|---|---|
| Username | `user` |
| Password | `changeme` |
| Hostname | `mintpc` |
| Keyboard | UK English |
| Timezone | Europe/London |

### Script overview

| File | Purpose |
|---|---|
| `setup.sh` | Runs on the live desktop — selects drives and installs Mint |
| `build-usb.sh` | Injects scripts into a Mint ISO |
| `flash-usb.sh` | Builds ISO and flashes to USB in one step |
| `post-install.sh` | Installs apps and hardens the system after deployment |
| `packages.txt` | App list — the only file most techs need to edit |

### Updating the scripts

1. Edit the relevant file
2. Rebuild and flash the USB:
   ```bash
   sudo -E bash ~/ladb-mint/flash-usb.sh ~/Downloads/linuxmint-21.3-cinnamon-64bit.iso
   ```
3. Commit and push to GitHub

### Mint version

Configured for **Linux Mint 21.3 "Virginia"** (Ubuntu 22.04 base).
If upgrading to a newer version, update `MINT_VERSION` and `LAST_EDIT` at the top of `setup.sh`.

---

*Maintained by rhyejam*
