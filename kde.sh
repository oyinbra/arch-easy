#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

reflector --country US --latest 6 --sort rate --save /etc/pacman.d/mirrorlist

# sudo firewall-cmd --add-port=1025-65535/tcp --permanent
# sudo firewall-cmd --add-port=1025-65535/udp --permanent
# sudo firewall-cmd --reload

# paru installation
cd
mkdir -p Repos
~/Repos
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

sudo pacman -Syyu
paru -S xorg plasma plasma-desktop plasma-wayland-session sddm ark kate dolphin konsole 

sudo systemctl enable sddm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
