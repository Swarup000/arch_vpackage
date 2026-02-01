#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "[!] Error on line $LINENO. Check output above."' ERR

echo "[+] Updating system"
sudo pacman -Syu --noconfirm

# ---------------- MULTILIB ----------------
echo "[+] Enabling multilib (if needed)"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/^\s*#\s*\[multilib\]/,/^\s*#\s*Include/ s/^#//' /etc/pacman.conf
  sudo pacman -Syu --noconfirm
fi

# ---------------- BASE DEPS ----------------
echo "[+] Installing base dependencies"
sudo pacman -S --needed --noconfirm \
  base-devel git curl wget unzip zsh go python python-pip ruby

# ---------------- BLACKARCH ----------------
if ! grep -q "^\[blackarch\]" /etc/pacman.conf; then
  echo "[+] Installing BlackArch repo"
  curl -fsSL https://blackarch.org/strap.sh -o strap.sh
  chmod +x strap.sh
  sudo ./strap.sh || echo "[!] BlackArch strap failed — continuing"
fi

# ---------------- CHAOTIC-AUR ----------------
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
  echo "[+] Installing Chaotic-AUR"

  sudo pacman-key --init
  sudo pacman-key --populate archlinux

  sudo pacman-key --recv-key 3056513887B78AEB \
    --keyserver hkps://keyserver.ubuntu.com || true
  sudo pacman-key --lsign-key 3056513887B78AEB || true

  sudo pacman -U --needed --noconfirm \
    https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
    https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst

  if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
  fi
fi

sudo pacman -Syu --noconfirm

# ---------------- PARU ----------------
echo "[+] Installing paru"
command -v paru >/dev/null || sudo pacman -S --needed --noconfirm paru

# ---------------- TOOLS ----------------
echo "[+] Installing pentest tools (safe mode)"
TOOLS=(
  blackarch-recon
  blackarch-webapp
  blackarch-scanner
  nmap sqlmap amass ffuf gobuster
  metasploit exploitdb
  seclists wordlists
  wireshark-qt burpsuite
)

for pkg in "${TOOLS[@]}"; do
  echo "[+] Installing $pkg"
  sudo pacman -S --needed --noconfirm "$pkg" || echo "[!] Failed: $pkg"
done

# ---------------- POST SETUP ----------------
echo "[+] Preparing wordlists"
sudo gzip -df /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

echo "[+] Updating exploitdb"
command -v searchsploit >/dev/null && searchsploit -u || true

echo "[+] Updating nmap scripts"
sudo nmap --script-updatedb || true

echo "[+] Updating sqlmap"
sqlmap --update || true

echo "[+] Setting up Metasploit DB"
sudo pacman -S --needed --noconfirm postgresql
sudo systemctl enable --now postgresql
msfconsole -q -x "db_status; exit" || true

# ---------------- WORKSPACE ----------------
echo "[+] Creating pentest workspace"
sudo mkdir -p /opt/pentest/{recon,web,exploit,wireless,forensics}
sudo chown -R "$USER:$USER" /opt/pentest

echo "[✓] DONE — reboot recommended"
