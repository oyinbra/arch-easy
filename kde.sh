#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

reflector --country US --latest 6 --sort rate --save /etc/pacman.d/mirrorlist

# sudo firewall-cmd --add-port=1025-65535/tcp --permanent
# sudo firewall-cmd --add-port=1025-65535/udp --permanent
# sudo firewall-cmd --reload

# Paru Installation
git clone https://aur.archlinux.org/paru.git
cd paru/
makepkg -si --noconfirm

sudo pacman -S --noconfirm xorg sddm plasma 

sudo flatpak install -y spotify

sudo systemctl enable sddm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
