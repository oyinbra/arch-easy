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
  "intel-ucode"
  "nano"
  "neovim"
  "git"
  "grub"
  "efibootmgr"
  "zsh"
)

# -----------------------------------------
# Retry pacstrap until it's successful
# -----------------------------------------
while true; do
    if pacstrap /mnt "${pacstrapPackages[@]}"; then
        break  # Exit the loop if pacstrap is successful
    else
        # Pacstrap failed
        read -p "Error: pacstrap failed. Do you want to retry? (y/n): " choice
        case $choice in
            [Yy])
                echo "Retrying pacstrap..."
                sleep 5  # Wait for 5 seconds before retrying
                ;;
            [Nn])
                echo "Exiting script. Please check and resolve the issue."
                exit 1
                ;;
            *)
                echo "Invalid choice. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    fi
done

# -----------------------------------------
# Generate an fstab file for the new system
# -----------------------------------------
genfstab -U /mnt >> /mnt/etc/fstab

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

echo "NEXT: basePackages.sh"

# -----------------------------------------
# Change root into the new system
# -----------------------------------------
arch-chroot /mnt

# -----------------------------------------
# Continue the installation inside the chroot environment
# -----------------------------------------
rsync -av /root/arch-easy /mnt/arch-easy
arch-chroot /mnt /bin/bash -c "/arch-easy/installPostChroot.sh"

