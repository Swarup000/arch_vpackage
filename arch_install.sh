#!/bin/bash
set -euo pipefail
echo "=== Arch Install Script ==="

# --- 1. Mount partitions ---
echo "[1/10] Mounting partitions..."
umount -R /mnt 2>/dev/null || true
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# --- 2. Update mirrors ---
echo "[2/10] Updating mirrorlist..."
reflector --country India --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm

# --- 3. Keyring ---
echo "[3/10] Initializing keyring..."
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring --noconfirm

# --- 4. Install base system ---
echo "[4/10] Installing base system..."
pacstrap -K /mnt base linux linux-firmware networkmanager vim --noconfirm

# --- 5. Generate fstab ---
echo "[5/10] Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# --- 6. Chroot configuration ---
echo "[6/10] Chrooting..."
arch-chroot /mnt /bin/bash <<'EOF'

set -euo pipefail
echo "[6a] Setting timezone..."
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

echo "[6b] Setting locale..."
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "[6c] Setting hostname..."
echo "archpc" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archpc.localdomain archpc
EOT

echo "[6d] Setting root password..."
echo "root:root" | chpasswd   # replace 'root' with your desired password

echo "[6e] Enable NetworkManager..."
systemctl enable NetworkManager

echo "[6f] Install systemd-boot..."
bootctl install

echo "[6g] Create boot entry..."
ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
cat <<BOOTCONF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
BOOTCONF

cat <<LOADERCONF > /boot/loader/loader.conf
default arch
timeout 3
editor 0
LOADERCONF

echo "[6h] Random seed location (safe for FAT32 /boot)..."
mkdir -p /etc/systemd/system/systemd-random-seed.service.d
cat <<SEEDCONF > /etc/systemd/system/systemd-random-seed.service.d/override.conf
[Service]
RandomSeed=/var/lib/systemd/random-seed
SEEDCONF

EOF

# --- 7. Unmount and finish ---
echo "[7/10] Unmounting and finishing..."
umount -R /mnt
sync

echo "=== Install complete! You can now remove the USB and reboot. ==="
