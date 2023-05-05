#!/bin/bash

# Search for any line with "oyinbra" and replace that with your own username

ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime
hwclock --systohc

# Locale gen for en_US.UTF-8 UTF-8
sed -i '171s/.//' /etc/locale.gen
# Locale gen for en_NG UTF-8
sed -i '163s/.//' /etc/locale.gen
locale-gen

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
LC_TIME=en_NG"

echo "KEYMAP=us-acentos" >> /etc/vconsole.conf

echo "ArchLinux" >> /etc/hostname

echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     ArchLinux.localdomain     localhost" >> /etc/hosts

mkinitcpio -P

# Change password to your password
echo root:password | chpasswd

# Comment if installing packages from the base-packages.txt file

pacman -S grub grub-btrfs base-devel efibootmgr networkmanager network-manager-applet dialog wpa_supplicant linux-headers pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync acpi acpi_call firewalld flatpak sof-firmware acpid os-prober terminus-font mtools dosfstools dhcp avahi upower man-db man-pages zsh

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable upower.service
# systemctl enable bluetooth
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable dhcpcd.service 
# acpid#systemctl enable

# replace username with your own network
useradd -m -G sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,wheel,adm,uucp -s /bin/zsh oyinbra

# Change password to your password
echo oyinbra:password | chpasswd

# Change password to your password
usermod -aG wheel,storage,power oyinbra

printf "\e[1;32mDone! grub configuration, Type exit, umount -a and reboot.\e[0m"
