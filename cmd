#!/usr/bin/env bash
set -e

echo "[+] Updating system"
sudo pacman -Syu --noconfirm

echo "[+] Enabling multilib"
sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm

echo "[+] Installing base dependencies"
sudo pacman -S --needed --noconfirm \
base-devel git curl wget unzip zsh go python python-pip ruby

# ---------------- BLACKARCH ----------------
if ! grep -q "\[blackarch\]" /etc/pacman.conf; then
  echo "[+] Installing BlackArch repo"
  curl -O https://blackarch.org/strap.sh
  chmod +x strap.sh
  sudo ./strap.sh
fi

# ---------------- CHAOTIC-AUR ----------------
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo "[+] Installing Chaotic-AUR"
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U --noconfirm \
    https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
    https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst

  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

sudo pacman -Syu --noconfirm

echo "[+] Installing AUR helper (paru)"
sudo pacman -S --needed --noconfirm paru

# ---------------- TOOLS ----------------
echo "[+] Installing cybersecurity tool groups"
sudo pacman -S --needed --noconfirm \
blackarch-webapp \
blackarch-recon \
blackarch-exploitation \
blackarch-scanner \
blackarch-passwords \
metasploit exploitdb nmap sqlmap amass ffuf gobuster \
seclists wordlists wireshark-qt burpsuite

echo "[+] Preparing wordlists"
sudo gzip -df /usr/share/wordlists/rockyou.txt.gz || true

echo "[+] Updating exploit database"
searchsploit -u

echo "[+] Updating Nmap scripts"
sudo nmap --script-updatedb

echo "[+] Updating SQLMap payloads"
sqlmap --update

echo "[+] Setting up Metasploit database"
sudo pacman -S --needed --noconfirm postgresql
sudo systemctl enable --now postgresql
sudo msfdb init || true

echo "[+] Creating pentest workspace"
sudo mkdir -p /opt/pentest/{recon,web,exploit,wireless,forensics}
sudo chown -R $USER:$USER /opt/pentest

echo "[+] DONE. Reboot recommended."
