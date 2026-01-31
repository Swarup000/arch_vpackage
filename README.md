# Arch Linux Automated Install & Pentesting Setup

This repository contains **two scripts**:
1. A **base Arch Linux installation script**
2. A **post‑install pentesting environment setup script**

Together, they automate a full Arch Linux installation and convert it into a
ready‑to‑use **cybersecurity / pentesting workstation**.

---

## Script Overview

### 1. Arch Installation Script
- Mounts EFI and root partitions
- Updates mirrors and package keyrings
- Installs a minimal Arch Linux system
- Configures:
  - Timezone and locale
  - Hostname and root password
  - NetworkManager
- Generates `fstab`
- Installs and configures `systemd-boot`
- Fixes random‑seed security warning
- Prepares the system for first boot

**Run from:** Arch Linux live ISO  
**Result:** Bootable Arch Linux system

---

### 2. Post‑Install Pentesting Setup Script
- Updates the system
- Enables `multilib`
- Installs development tools and language runtimes
- Adds:
  - BlackArch repository
  - Chaotic‑AUR repository
- Installs common pentesting tools and frameworks
- Updates tool databases (Exploit‑DB, Nmap, SQLMap)
- Sets up Metasploit and PostgreSQL
- Creates a structured pentesting workspace

**Run from:** Installed Arch system (as a sudo user)  
**Result:** Fully configured pentesting environment

---

## Usage Order

1. Boot Arch Linux live ISO  
2. Run the **installation script**  
3. Reboot into the new system  
4. Log in as a normal user  
5. Run the **post‑install setup script**  
6. Reboot (recommended)

---

## Notes

- Designed for **UEFI systems with NVMe storage**
- Uses `--noconfirm` for unattended execution
- Intended for **dedicated pentesting systems**
- Uses third‑party repositories (BlackArch, Chaotic‑AUR)

---

## Disclaimer

Use only on systems intended for security testing.
Mixing multiple repositories may reduce long‑term system stability.
