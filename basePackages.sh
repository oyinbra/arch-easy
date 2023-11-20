
#!/bin/bash

cat << "EOF"

 ██████                               ███████  ██   ██   ████████
░█░░░░██                             ░██░░░░██░██  ██   ██░░░░░░██
░█   ░██   ██████    ██████  █████   ░██   ░██░██ ██   ██      ░░
░██████   ░░░░░░██  ██░░░░  ██░░░██  ░███████ ░████   ░██
░█░░░░ ██  ███████ ░░█████ ░███████  ░██░░░░  ░██░██  ░██    █████
░█    ░██ ██░░░░██  ░░░░░██░██░░░░   ░██      ░██░░██ ░░██  ░░░░██
░███████ ░░████████ ██████ ░░██████  ░██      ░██ ░░██ ░░████████
░░░░░░░   ░░░░░░░░ ░░░░░░   ░░░░░░   ░░       ░░   ░░   ░░░░░░░░


EOF

# ------------------------------------------------------
# Load library from modules directory
# ------------------------------------------------------
source $(dirname "$0")/modules/library.sh
clear

cat << "EOF"

 ██                    ██              ██  ██
░██                   ░██             ░██ ░██
░██ ███████   ██████ ██████  ██████   ░██ ░██
░██░░██░░░██ ██░░░░ ░░░██░  ░░░░░░██  ░██ ░██
░██ ░██  ░██░░█████   ░██    ███████  ░██ ░██
░██ ░██  ░██ ░░░░░██  ░██   ██░░░░██  ░██ ░██
░██ ███  ░██ ██████   ░░██ ░░████████ ███ ███
░░ ░░░   ░░ ░░░░░░     ░░   ░░░░░░░░ ░░░ ░░░

EOF

# ------------------------------------------------------
# Call function to Confirm Start
# ------------------------------------------------------
confirm_start

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
echo ""
echo "-> Install main packages"

# Install the rest of base packages
packagesPacman=(
    "blueman"
    "grub"
    "grub-btrfs"
    "base-devel"
    "efibootmgr"
    "networkmanager"
    "network-manager-applet"
    "dialog"
    "wpa_supplicant"
    "linux-headers"
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "pipewire-jack"
    "bash-completion"
    "openssh"
    "rsync"
    "acpi"
    "acpi_call"
    "firewalld"
    "flatpak"
    "sof-firmware"
    "acpid"
    "os-prober"
    "terminus-font"
    "mtools"
    "dosfstools"
    "dhcp"
    "avahi"
    "upower"
    "man-db"
    "man-pages"
    "zsh"
    "intel-ucode"
    "btrfs-progs"
    "archlinux-keyring"
    "nano"
    "git"
    "neovim"
    "zsh"
    "neofetch"
    "iw"
    "iwd"
    "sudo"
    "tmux"
    "xterm"
)

# -----------------------------------------
# Install pacman packages
# -----------------------------------------
_installPackagesPacman "${packagesPacman[@]}";

# -----------------------------------------
# Enable essential services
# -----------------------------------------
systemctl enable bluetooth
systemctl enable firewalld
systemctl enable NetworkManager
systemctl enable upower.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable fstrim.timer
systemctl enable dhcpcd.service 
systemctl enable systemd-hibernate.service

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

