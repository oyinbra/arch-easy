
#!/bin/bash

cat << "EOF"

 ████     ████                             ██
░██░██   ██░██                            ░██
░██░░██ ██ ░██  ██████  ██   ██ ███████  ██████
░██ ░░███  ░██ ██░░░░██░██  ░██░░██░░░██░░░██░
░██  ░░█   ░██░██   ░██░██  ░██ ░██  ░██  ░██
░██   ░    ░██░██   ░██░██  ░██ ░██  ░██  ░██
░██        ░██░░██████ ░░██████ ███  ░██  ░░██
░░         ░░  ░░░░░░   ░░░░░░ ░░░   ░░    ░░

EOF

# -----------------------------------------
# Auto-detect device type
# -----------------------------------------
if [[ -e "/sys/block/nvme0n1" ]]; then
    device="/dev/nvme0n1p"
else
    device="/dev/sda"
fi

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
root_uuid=$(blkid -s UUID -o value ${device}3)
boot_uuid=$(blkid -s UUID -o value ${device}1)
swap_uuid=$(blkid -s UUID -o value ${device}2)

# -----------------------------------------
# Mount root partition before creating subvolumes 
# -----------------------------------------
mount ${device}3 /mnt

# -----------------------------------------
# Create subvolumes for root partition
# -----------------------------------------
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log

# -----------------------------------------
# Unmount root partiton
# -----------------------------------------
umount -l /mnt

# -----------------------------------------
# Mount root partiton to root subvol
# -----------------------------------------
mount -o defaults,discard=async,ssd,subvol=@,noatime UUID=$root_uuid /mnt

# -----------------------------------------
# Ensure required directories exist before mounting
# -----------------------------------------
mkdir -p /mnt/boot/efi
mkdir -p /mnt/{home,var/{cache,log}}

# -----------------------------------------
# Mount the other partitions
# -----------------------------------------
mount -o defaults,discard=async,ssd,subvol=@home,noatime UUID=$root_uuid /mnt/home
mount -o defaults,discard=async,ssd,subvol=@cache,noatime UUID=$root_uuid /mnt/var/cache
mount -o defaults,discard=async,ssd,subvol=@log,noatime UUID=$root_uuid /mnt/var/log

# -----------------------------------------
# Mount EFI partition
# -----------------------------------------
mount ${device}1 /mnt/boot/efi

# -----------------------------------------
# Activate swap
# -----------------------------------------
swapon ${device}2

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

echo "NEXT: pacstrap.sh"
