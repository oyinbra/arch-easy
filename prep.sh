#!/bin/bash

cat << "EOF"

 ███████
░██░░░░██                ██████
░██   ░██ ██████  █████ ░██░░░██
░███████ ░░██░░█ ██░░░██░██  ░██
░██░░░░   ░██ ░ ░███████░██████
░██       ░██   ░██░░░░ ░██░░░
░██      ░███   ░░██████░██
░░       ░░░     ░░░░░░ ░░

EOF

# --------------------------------------------------------
# Update the package repositories
# --------------------------------------------------------
pacman -Sy

# --------------------------------------------------------
# Initialize the pacman keyring
# --------------------------------------------------------
pacman-key --init

# --------------------------------------------------------
# Populate the Arch Linux GPG keyring
# --------------------------------------------------------
pacman-key --populate archlinux

# --------------------------------------------------------
# Enable Network Time Protocol (NTP)
# --------------------------------------------------------
timedatectl set-ntp true

# --------------------------------------------------------
# Set the US keyboard layout, default is AltGr (Right Alt) dead keys
# --------------------------------------------------------
# Function to prompt and set keyboard layout
# --------------------------------------------------------
set_keyboard_layout() {
    read -p "Choose your keyboard layout (default: us-altgr-intl, other options: us, de, fr): " layout
    layout=${layout:-us-altgr-intl}

    case $layout in
        us|de|fr|us-altgr-intl)
            loadkeys "$layout"
            ;;
        *)
            echo "Invalid option. Setting default layout (us-altgr-intl)."
            loadkeys us-altgr-intl
            ;;
    esac
}

# --------------------------------------------------------
# Prompt user for keyboard layout
# --------------------------------------------------------
set_keyboard_layout

# --------------------------------------------------------
# Install reflector and the Arch Linux keyring
# --------------------------------------------------------
pacman -S reflector archlinux-keyring

# --------------------------------------------------------
# Use reflector to generate an optimized mirrorlist for the US
# Adjust options as needed for your location or preferences
# --------------------------------------------------------
reflector --country US --latest 6 --sort rate --save /etc/pacman.d/mirrorlist

# --------------------------------------------------------
# Update the package repositories with the new mirrorlist
# --------------------------------------------------------
pacman -Sy

# --------------------------------------------------------
# Set Parallel downloads to 5 in line 38 
# --------------------------------------------------------
sudo sed -i '38iParallelDownloads = 5' /etc/pacman.conf
cat /etc/pacman.conf | grep ParallelDownload

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

