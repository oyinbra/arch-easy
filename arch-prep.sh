#!/bin/bash
set -e

# -------------------------------------
# Prompt for user credentials
# -------------------------------------
read -rp "Enter new username: " USERNAME
read -rsp "Enter password for $USERNAME: " USERPASS && echo
read -rsp "Enter password for root: " ROOTPASS && echo

# -------------------------------------
# Define partitions
# -------------------------------------
EFI=/dev/nvme0n1p1
SWAP=/dev/nvme0n1p2
ROOT=/dev/nvme0n1p3

# -------------------------------------
# Format & create BTRFS subvolumes
# -------------------------------------
mkfs.fat -F32 $EFI
mkswap $SWAP
swapon $SWAP
mkfs.btrfs -f $ROOT

mount $ROOT /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots
umount /mnt

# -------------------------------------
# Mount BTRFS subvolumes
# -------------------------------------
mount -o noatime,compress=zstd,subvol=@ $ROOT /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache,.snapshots}
mount -o noatime,compress=zstd,subvol=@home $ROOT /mnt/home
mount -o noatime,compress=zstd,subvol=@log $ROOT /mnt/var/log
mount -o noatime,compress=zstd,subvol=@cache $ROOT /mnt/var/cache
mount -o noatime,compress=zstd,subvol=@snapshots $ROOT /mnt/.snapshots
mount $EFI /mnt/boot

# -------------------------------------
# Install base system (for chroot)
# -------------------------------------
until pacstrap /mnt base linux linux-firmware btrfs-progs grub; do
  echo "[!] pacstrap failed. Retrying in 5s..."
  sleep 5
done

# -------------------------------------
# Generate fstab and pass credentials
# -------------------------------------
genfstab -U /mnt >> /mnt/etc/fstab
echo "$USERNAME" > /mnt/root/.arch_username
echo "$USERPASS" > /mnt/root/.arch_userpass
echo "$ROOTPASS" > /mnt/root/.arch_rootpass

cp arch-chroot.sh /mnt/root/
chmod +x /mnt/root/arch-chroot.sh

echo
echo "[+] Prep done. Now run: arch-chroot /mnt"
echo "[+] Then run: /root/arch-chroot.sh"