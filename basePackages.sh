
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
    "grub-btrfs"
    "dialog"
    "wpa_supplicant"
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "pipewire-jack"
    "bash-completion"
    "acpi"
    "acpi_call"
    "firewalld"
    "flatpak"
    "sof-firmware"
    "acpid"
    "os-prober"
    "mtools"
    "dosfstools"
    "dhcp"
    "avahi"
    "upower"
    "man-db"
    "man-pages"
    "intel-ucode"
    "btrfs-progs"
    "archlinux-keyring"
    "nano"
    "git"
    "neofetch"
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

echo "NEXT: setBaseUEFI.sh"

