#!/bin/bash

cat << "EOF"

 ██████                                   ██     ██           ████ ██
░█░░░░██                                 ░██    ░██          ░██░ ░░
░█   ░██   ██████    ██████  █████       ░██    ░██  █████  ██████ ██
░██████   ░░░░░░██  ██░░░░  ██░░░██ █████░██    ░██ ██░░░██░░░██░ ░██
░█░░░░ ██  ███████ ░░█████ ░███████░░░░░ ░██    ░██░███████  ░██  ░██
░█    ░██ ██░░░░██  ░░░░░██░██░░░░       ░██    ░██░██░░░░   ░██  ░██
░███████ ░░████████ ██████ ░░██████      ░░███████ ░░██████  ░██  ░██
░░░░░░░   ░░░░░░░░ ░░░░░░   ░░░░░░        ░░░░░░░   ░░░░░░   ░░   ░░

EOF

# -----------------------------------------
# Set the timezone to Africa/Lagos
# -----------------------------------------
ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime
hwclock --systohc

# -----------------------------------------
# Uncomment locale settings for en_US.UTF-8 and en_NG UTF-8
# -----------------------------------------
sed -i '171s/.//' /etc/locale.gen
sed -i '163s/.//' /etc/locale.gen
locale-gen

# -----------------------------------------
# Set system locale to en_NG
# -----------------------------------------
echo "
LANG=en_NG
LC_ADDRESS=en_NG
LC_IDENTIFICATION=en_NG
LC_MEASUREMENT=en_NG
LC_MONETARY=en_NG
LC_NAME=en_NG
LC_NUMERIC=en_NG
LC_PAPER=en_NG
LC_TELEPHONE=en_NG
LC_TIME=en_NG" > /etc/locale.conf

# -----------------------------------------
# Set keymap to us-acentos
# -----------------------------------------
echo "KEYMAP=us-acentos" >> /etc/vconsole.conf

# -----------------------------------------
# Set hostname to ArchLinux
# -----------------------------------------
echo "ArchLinux" > /etc/hostname

# -----------------------------------------
# Configure /etc/hosts file
# -----------------------------------------
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     ArchLinux.localdomain     localhost" >> /etc/hosts

# -----------------------------------------
# Regenerate initramfs
# -----------------------------------------
mkinitcpio -P

# -----------------------------------------
# Set the root password
# -----------------------------------------
while true; do
    passwd root
    if [ $? -eq 0 ]; then
        break
    else
        echo "Error setting root password. Please try again."
    fi
done

# -----------------------------------------
# Install and configure GRUB
# -----------------------------------------
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# -----------------------------------------
# Create a new user and add to necessary groups
# -----------------------------------------
# Function to prompt and set username
# -----------------------------------------
set_username() {
    read -p "Enter your username: " username
    export username
}

# -----------------------------------------
# Prompt user for username
# -----------------------------------------
set_username

# -----------------------------------------
# Create a new user and add to necessary groups
# -----------------------------------------
useradd -m -G sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,wheel,adm,uucp -s /bin/zsh "$username"

# -----------------------------------------
# Set the password for the new user
# -----------------------------------------
while true; do
    passwd "$username"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Error setting $username's password. Please try again."
    fi
done

# -----------------------------------------
# Add the new user to additional groups
# -----------------------------------------
usermod -aG wheel,storage,power "$username"

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

