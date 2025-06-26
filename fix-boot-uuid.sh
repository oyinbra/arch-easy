#!/bin/bash
set -e

ROOT=/dev/nvme0n1p3
SWAP=/dev/nvme0n1p2
EFI=/dev/nvme0n1p1

echo "[+] Mounting system"
mount -o subvol=@ $ROOT /mnt
mount $EFI /mnt/boot

echo "[+] Getting UUIDs"
ROOT_UUID=$(blkid -s UUID -o value $ROOT)
SWAP_UUID=$(blkid -s UUID -o value $SWAP)

echo "[+] Updating /boot/loader/entries/arch.conf"
cat > /mnt/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw resume=UUID=$SWAP_UUID rootflags=subvol=@
EOF

echo "[+] Unmounting system"
umount -R /mnt

echo "[+] UUIDs injected. Rebooting..."
reboot