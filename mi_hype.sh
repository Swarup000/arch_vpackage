#!/usr/bin/env bash
# Optimized Arch Pentest Setup
set -uo pipefail # Removed -e to handle tool-specific failures gracefully

# Function to safely add repos
add_repo_if_missing() {
    local name=$1
    local content=$2
    if ! grep -q "^\[$name\]" /etc/pacman.conf; then
        echo "[+] Adding $name repository..."
        echo -e "$content" | sudo tee -a /etc/pacman.conf
        return 0
    fi
    return 1
}

echo "[+] Initializing System..."
sudo pacman -Syu --noconfirm --needed base-devel git curl wget

# --- 1. MULTILIB ---
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/^\s*#\s*\[multilib\]/,/^\s*#\s*Include/ s/^#//' /etc/pacman.conf
fi

# --- 2. CHAOTIC-AUR (Better to add before BlackArch for speed) ---
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
    echo "[+] Setting up Chaotic-AUR Keys..."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver hkps://keyserver.ubuntu.com || \
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keys.gnupg.net
    sudo pacman-key --lsign-key 3056513887B78AEB
    
    sudo pacman -U --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    
    add_repo_if_missing "chaotic-aur" "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist"
fi

# --- 3. BLACKARCH ---
if ! grep -q "^\[blackarch\]" /etc/pacman.conf; then
    curl -O https://blackarch.org/strap.sh
    chmod +x strap.sh
    sudo ./strap.sh
    rm strap.sh
fi

# Sync all new repos
sudo pacman -Syy

# --- 4. TOOL INSTALLATION (Optimized) ---
# We split groups from individual packages to prevent "group-select" hangs
GROUPS=(blackarch-recon blackarch-webapp blackarch-scanner)
TOOLS=(nmap sqlmap amass ffuf gobuster metasploit exploitdb seclists wordlists wireshark-qt burpsuite paru)

echo "[+] Installing Tool Groups..."
sudo pacman -S --needed --noconfirm "${GROUPS[@]}"

echo "[+] Installing Individual Tools..."
sudo pacman -S --needed --noconfirm "${TOOLS[@]}"

# --- 5. POST-INSTALL & SERVICES ---
echo "[+] Enabling Services..."
sudo systemctl enable --now postgresql
[ ! -d "/var/lib/postgres/data" ] && sudo -u postgres initdb -D /var/lib/postgres/data

# Wordlist optimization
[ -f /usr/share/wordlists/rockyou.txt.gz ] && sudo gzip -df /usr/share/wordlists/rockyou.txt

echo "[✓] Setup Complete."
