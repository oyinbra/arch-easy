#!/bin/bash
set -e

read -rsp "Enter new root password: " ROOTPASS
echo

ROOT_PART="/dev/nvme0n1p3"
EFI_PART="/dev/nvme0n1p1"

echo "[+] Mounting root and EFI"
mount -o subvol=@ $ROOT_PART /mnt
mount $EFI_PART /mnt/boot

echo "[+] Injecting password into system"
echo "root:$ROOTPASS" > /mnt/rootpass.txt

echo "[+] Chrooting and setting root password"
arch-chroot /mnt /bin/bash <<'EOF'
chpasswd < /rootpass.txt
rm /rootpass.txt
EOF

echo "[+] Unmounting"
umount -R /mnt

echo "[+] Done. Root password has been set."