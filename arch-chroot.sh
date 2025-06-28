#!/bin/bash
set -e

# -------------------------------------
# Load user credentials
# -------------------------------------
USERNAME=$(cat /root/.arch_username)
USERPASS=$(cat /root/.arch_userpass)
ROOTPASS=$(cat /root/.arch_rootpass)

# -------------------------------------
# Locale, time, hostname
# -------------------------------------
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-intl" > /etc/vconsole.conf
echo "ArchLinux" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 ArchLinux.localdomain ArchLinux
EOF

# -------------------------------------
# Initramfs and GRUB
# -------------------------------------
sed -i 's/^HOOKS=(.*/HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p3)
SWAP_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"resume=UUID=$SWAP_UUID rootflags=subvol=@\"|" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# -------------------------------------
# Install full KDE system and tools
# -------------------------------------
pacman -Sy --noconfirm \
  plasma plasma-meta \
  qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects \
  kwalletmanager kwallet-pam \
  sddm networkmanager bluez bluez-utils \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack \
  firewalld avahi upower sshd \
  intel-ucode os-prober sof-firmware acpid \
  man-db man-pages btrfs-progs git neofetch

# -------------------------------------
# Create user and passwords
# -------------------------------------
useradd -m -G wheel,power,storage -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd
echo "root:$ROOTPASS" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# -------------------------------------
# NetworkManager config
# -------------------------------------
cat > /etc/NetworkManager/NetworkManager.conf <<NM
[main]
plugins=keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
NM

# -------------------------------------
# Enable essential services
# -------------------------------------
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable firewalld
systemctl enable avahi-daemon
systemctl enable upower
systemctl enable sshd
systemctl enable fstrim.timer
systemctl enable systemd-hibernate.service

# -------------------------------------
# Safe reboot prompt
# -------------------------------------
echo
read -rp "System setup finished. Reboot now? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "[+] Cleaning up and rebooting..."
  exit
else
  echo "[!] Reboot skipped. You may continue configuration manually."
fi