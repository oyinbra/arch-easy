#!/bin/bash

cat << "EOF"

 ███████                             ██
░██░░░░██          ██████           ░░
░██   ░██   █████ ░██░░░██  ██████   ██ ██████  ██████
░███████   ██░░░██░██  ░██ ░░░░░░██ ░██░░██░░█ ██░░░░
░██░░░██  ░███████░██████   ███████ ░██ ░██ ░ ░░█████
░██  ░░██ ░██░░░░ ░██░░░   ██░░░░██ ░██ ░██    ░░░░░██
░██   ░░██░░██████░██     ░░████████░██░███    ██████
░░     ░░  ░░░░░░ ░░       ░░░░░░░░ ░░ ░░░    ░░░░░░

EOF

# -----------------------------------------
# Chroot into Arch for repairs
# -----------------------------------------

# ------------------------------------------------------
# Load library from modules directory
# ------------------------------------------------------
source $(dirname "$0")/modules/library.sh
clear

lsblk

# ------------------------------------------------------
# Call function to Confirm Start
# ------------------------------------------------------
confirm_start

# -----------------------------------------
# Set the device name variable
# -----------------------------------------
device="/dev/nvme0n1"

# -----------------------------------------
# Check if any partitions are mounted
# -----------------------------------------
if mount | grep -q "/mnt"; then
    echo "Error: Partitions are already mounted. Please unmount them before running the script."
    exit 1
fi

# -----------------------------------------
# Enable error handling
# -----------------------------------------
set -e

# -----------------------------------------
# Use UUIDs for mounting partitions
# -----------------------------------------
root_uuid=$(blkid -s UUID -o value ${device}p3)
boot_uuid=$(blkid -s UUID -o value ${device}p1)

# -----------------------------------------
# Mount all partitons to their subvol
# -----------------------------------------
mount -o defaults,discard=async,ssd,subvol=@,noatime UUID=$root_uuid /mnt
mount -o defaults,discard=async,ssd,subvol=@home,noatime UUID=$root_uuid /mnt/home
mount -o defaults,discard=async,ssd,subvol=@cache,noatime UUID=$root_uuid /mnt/var/cache
mount -o defaults,discard=async,ssd,subvol=@log,noatime UUID=$root_uuid /mnt/var/log

# -----------------------------------------
# Mount EFI partition
# -----------------------------------------
mount ${device}p1 /mnt/boot/efi


# -----------------------------------------
# Chroot into the mounted system
# -----------------------------------------
arch-chroot /mnt

# -----------------------------------------
# Done
# -----------------------------------------
cat << "EOF"

 ███████
░██░░░░██
░██    ░██  ██████  ███████   █████
░██    ░██ ██░░░░██░░██░░░██ ██░░░██
░██    ░██░██   ░██ ░██  ░██░███████
░██    ██ ░██   ░██ ░██  ░██░██░░░░
░███████  ░░██████  ███  ░██░░██████
░░░░░░░    ░░░░░░  ░░░   ░░  ░░░░░░

EOF

