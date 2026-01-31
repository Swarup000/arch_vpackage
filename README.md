# Arch Linux Automated Install Script

This script automates the installation of a minimal Arch Linux system on a UEFI machine with an NVMe drive. It is **future-proof**, handles mirrors, keyrings, and bootloader configuration, and is designed for unattended installs.

---

## Features

1. **Partition Mounting**  
   - Mounts the root and EFI partitions automatically.

2. **Mirror Update**  
   - Refreshes package mirrors with fast, India-based HTTPS mirrors.  
   - Updates the package database.

3. **Keyring Initialization**  
   - Sets up and populates Arch Linux GPG keys.  
   - Updates the keyring to avoid “unknown trust” errors.

4. **Base System Installation**  
   - Installs a minimal Arch system (`base`, `linux`, `linux-firmware`, `networkmanager`, `vim`).  
   - Uses `--noconfirm` for unattended installation.

5. **Filesystem Table**  
   - Generates `/etc/fstab` using UUIDs for reliable mounting.

6. **System Configuration (Chroot)**  
   - Timezone and hardware clock setup.  
   - Locale configuration (`en_US.UTF-8`).  
   - Hostname and `/etc/hosts` setup.  
   - Root password assignment.  
   - Enables NetworkManager for networking.

7. **Bootloader Setup (Full Script)**  
   - Installs `systemd-boot` for UEFI booting.  
   - Creates boot entries pointing to the installed kernel and root partition.  
   - Sets default loader entry and timeout.  
   - Secures random seed storage to avoid world-readable `/boot` warnings.

8. **Cleanup and Reboot**  
   - Exits chroot, unmounts partitions, and reboots into the new system.

---

## Usage

1. Boot from the Arch Linux live ISO.  
2. Connect to the internet (Wi-Fi or Ethernet).  
3. Run the script in the live environment.  
4. After the script completes, remove the USB and reboot.

---

## Notes

- The script is **idempotent** — it can be safely re-run to fix failed installs.  
- Designed for **UEFI + NVMe** systems. Adjust partitions if different.  
- Locale, timezone, hostname, and root password can be customized in the script.
