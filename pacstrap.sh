#!/bin/bash

cat << "EOF"

 ███████                              ██
░██░░░░██                            ░██                    ██████
░██   ░██  ██████    █████   ██████ ██████ ██████  ██████  ░██░░░██
░███████  ░░░░░░██  ██░░░██ ██░░░░ ░░░██░ ░░██░░█ ░░░░░░██ ░██  ░██
░██░░░░    ███████ ░██  ░░ ░░█████   ░██   ░██ ░   ███████ ░██████
░██       ██░░░░██ ░██   ██ ░░░░░██  ░██   ░██    ██░░░░██ ░██░░░
░██      ░░████████░░█████  ██████   ░░██ ░███   ░░████████░██
░░        ░░░░░░░░  ░░░░░  ░░░░░░     ░░  ░░░     ░░░░░░░░ ░░

EOF

# -----------------------------------------
# Set the packages to install
# -----------------------------------------
pacstrapPackages=(
  "base"
  "base-devel"
  "linux"
  "linux-headers"
  "linux-firmware"
  "sudo"
  "pulseaudio"
  "intel-ucode"
  "nano"
  "neovim"
  "git"
  "networkmanager"
)

# -----------------------------------------
# Retry pacstrap until it's successful
# -----------------------------------------
while ! pacstrap -c /mnt "${pacstrapPackages[@]}"; do
    echo "Error: pacstrap failed. Retrying..."
    sleep 5  # Wait for 5 seconds before retrying
done

# -----------------------------------------
# Generate an fstab file for the new system
# -----------------------------------------
genfstab -U /mnt >> /mnt/etc/fstab

# -----------------------------------------
# Change root into the new system
# -----------------------------------------
arch-chroot /mnt

# -----------------------------------------
# Continue the installation inside the chroot environment
# -----------------------------------------
rsync -av /root/arch-easy/ /mnt/
arch-chroot /mnt /bin/bash -c "/arch-easy/installPostChroot.sh"

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

