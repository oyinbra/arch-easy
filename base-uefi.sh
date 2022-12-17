#!/bin/bash

ln -sf /usr/share/zoneinfo/Africa/Lagos /etc/localtime
hwclock --systohc
sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us-acentos" >> /etc/vconsole.conf
echo "ArchLinux" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ArchLinux.localdomain ArchLinux" >> /etc/hosts
# Change password to your password
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S grub grub-btrfs base-devel efibootmgr networkmanager network-manager-applet dialog wpa_supplicant linux-headers pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync acpi acpi_call firewalld flatpak sof-firmware acpid os-prober terminus-font mtools dosfstools

# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
# systemctl enable bluetooth
# systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
# You can comment this command out if you didn't install tlp, see above
#systemctl enable tlp
# systemctl enable reflector.timer
systemctl enable fstrim.timer
#systemctl enable libvirtd
systemctl enable firewalld
#systemctl enable acpid

useradd -m oyinbra
# Change password to your password
echo oyinbra:password | chpasswd
usermod -aG wheel oyinbra

echo "oyinbra ALL=(ALL) ALL" >> /etc/sudoers.d/oyinbra


printf "\e[1;32mDone! grub configuration, Type exit, umount -a and reboot.\e[0m"
