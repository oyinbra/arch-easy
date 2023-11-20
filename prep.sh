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
# Enable color, parallel downloads and multilib
# --------------------------------------------------------
# Remove comments from lines 33, 37, 90, and 91 in /etc/pacman.conf
# --------------------------------------------------------
sed -i -e '33s/^#//' -e '37s/^#//' -e '90s/^#//' -e '91s/^#//' /etc/pacman.conf
# Confirm those changes
sed -n -e '33p' -e '37p' -e '90p' -e '91p' /etc/pacman.conf

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

