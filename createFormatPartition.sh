#!/bin/bash

cat << "EOF"

 ████████                                         ██
░██░░░░░                                         ░██
░██        ██████  ██████ ██████████   ██████   ██████
░███████  ██░░░░██░░██░░█░░██░░██░░██ ░░░░░░██ ░░░██░
░██░░░░  ░██   ░██ ░██ ░  ░██ ░██ ░██  ███████   ░██
░██      ░██   ░██ ░██    ░██ ░██ ░██ ██░░░░██   ░██
░██      ░░██████ ░███    ███ ░██ ░██░░████████  ░░██
░░        ░░░░░░  ░░░    ░░░  ░░  ░░  ░░░░░░░░    ░░

EOF

# -----------------------------------------
# Ensure you are running this script as root
# -----------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# -----------------------------------------
# Device name (modify according to your system, e.g., /dev/sda)
# -----------------------------------------
device="/dev/nvme0n1"

# -----------------------------------------
# Partition sizes (adjust as needed)
# -----------------------------------------
efi_size="512M"
swap_size="32768M"

# -----------------------------------------
# Partition types
# -----------------------------------------
efi_type="ef00"  # EFI System Partition
swap_type="8200" # Linux Swap
root_type="8300" # Linux Filesystem

# -----------------------------------------
# Print existing partitions
# -----------------------------------------
gdisk -l $device

# -----------------------------------------
# Prompt for confirmation before proceeding
# -----------------------------------------
read -p "This script will destroy existing data on $device. Continue? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# -----------------------------------------
# Create EFI System Partition
# -----------------------------------------
sgdisk -n 1:0:+$efi_size -t 1:$efi_type -c 1:"EFI System" -u 1 $device

# -----------------------------------------
# Create Swap Partition
# -----------------------------------------
sgdisk -n 2:0:+$swap_size -t 2:$swap_type -c 2:"Swap" -u 2 $device

# -----------------------------------------
# Create Root Partition (using remaining space)
# -----------------------------------------
sgdisk -n 3:0:0 -t 3:$root_type -c 3:"Root" -u 3 $device

# -----------------------------------------
# Print updated partition table
# -----------------------------------------
gdisk -l $device

# -----------------------------------------
# Format Root Partition (using btrfs)
# -----------------------------------------
mkfs.btrfs -f -L ArchLinux ${device}p3

# -----------------------------------------
# Format EFI System Partition
# -----------------------------------------
mkfs.vfat -n BOOT ${device}p1

# -----------------------------------------
# Format Swap Partition
# -----------------------------------------
mkswap -L SWAP ${device}p2
lsblk

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

