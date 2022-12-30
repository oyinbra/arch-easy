#!/bin/bash

ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime
hwclock --systohc
sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LC_ADDRESS=en_US.UTF-8" >> /etc/locale.conf
echo "LC_IDENTIFICATION=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MEASUREMENT=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=en_US.UTF-8" >> /etc/locale.conf
echo "LC_NAME=en_US.UTF-8" >> /etc/locale.conf
echo "LC_NUMERIC=en_US.UTF-8" >> /etc/locale.conf
echo "LC_PAPER=en_US.UTF-8" >> /etc/locale.conf
echo "LC_TELEPHONE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_TIME=en_US.UTF-8" >> /etc/locale.conf

echo "KEYMAP=us-acentos" >> /etc/vconsole.conf

echo "ArchLinux" >> /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ArchLinux.localdomain ArchLinux" >> /etc/hosts

# Change password to your password
echo root:password | chpasswd


pacman -S grub grub-btrfs base-devel efibootmgr networkmanager network-manager-applet dialog wpa_supplicant linux-headers pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync acpi acpi_call firewalld flatpak sof-firmware acpid os-prober terminus-font mtools dosfstools dhcp avahi upower man-db man-pages zsh

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable upower.service
systemctl enable bluetooth
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable fstrim.timer
systemctl enable firewalld
# acpid#systemctl enable

useradd -m -G sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,wheel,adm,uucp -s /bin/zsh oyinbra
# Change password to your password
echo oyinbra:password | chpasswd
# usermod -aG wheel oyinbra

echo "oyinbra ALL=(ALL) ALL" >> /etc/sudoers.d/oyinbra


printf "\e[1;32mDone! grub configuration, Type exit, umount -a and reboot.\e[0m"
