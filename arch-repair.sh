#!/bin/bash
set -e

# -------------------------------------
# Mount all BTRFS subvolumes for chroot
# -------------------------------------
mount -o noatime,compress=zstd,subvol=@ /dev/nvme0n1p3 /mnt
mount -o noatime,compress=zstd,subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o noatime,compress=zstd,subvol=@log /dev/nvme0n1p3 /mnt/var/log
mount -o noatime,compress=zstd,subvol=@cache /dev/nvme0n1p3 /mnt/var/cache
mount -o noatime,compress=zstd,subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot

echo "[+] All subvolumes mounted. Entering chroot..."
arch-chroot /mnt