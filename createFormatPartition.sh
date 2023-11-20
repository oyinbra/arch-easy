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
# Auto-detect device type
# -----------------------------------------
if [[ -e "/sys/block/nvme0n1" ]]; then
    device="/dev/nvme0n1p"
else
    device="/dev/sda"
fi

# -----------------------------------------
# Partition sizes (uncomment as needed for swap partiton)
# -----------------------------------------
efi_size="512M"
swap_size="32768M" # 32G swap_size
# swap_size="65536M" # 64G swap_size
# swap_size="16384M" # 16G swap_size
# swap_size="8192M" # 8GB swap_size

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
read -p "This script will destroy existing data on ${device}1, ${device}2, and ${device}3. Continue? (y/n): " -r
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
mkfs.btrfs -f -L ArchLinux ${device}3

# -----------------------------------------
# Format EFI System Partition
# -----------------------------------------
mkfs.vfat -n BOOT ${device}1

# -----------------------------------------
# Format Swap Partition
# -----------------------------------------
mkswap -L SWAP ${device}2
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

