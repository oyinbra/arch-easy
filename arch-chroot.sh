#!/bin/bash
set -e

# -------------------------------------
# Validate credentials
# -------------------------------------
for f in /root/.arch_username /root/.arch_userpass /root/.arch_rootpass; do
    [[ -f $f ]] || { echo "Missing $f — did you run arch-prep.sh first?"; exit 1; }
done

username=$(< /root/.arch_username)
userpass=$(< /root/.arch_userpass)
rootpass=$(< /root/.arch_rootpass)

# -------------------------------------
# Set timezone and locale
# -------------------------------------
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-intl" > /etc/vconsole.conf

# -------------------------------------
# Set hostname
# -------------------------------------
echo "ArchLinux" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 ArchLinux.localdomain ArchLinux
EOF

# -------------------------------------
# Install GRUB EFI bootloader
# -------------------------------------
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# -------------------------------------
# Create user and set passwords
# -------------------------------------
useradd -m -G wheel -s /bin/bash "$username"
echo "$username:$userpass" | chpasswd
echo "root:$rootpass" | chpasswd

# -------------------------------------
# Enable sudo for wheel group
# -------------------------------------
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# -------------------------------------
# Configure NetworkManager to avoid secrets bug
# -------------------------------------
cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
plugins=keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
EOF

# -------------------------------------
# Enable essential services
# -------------------------------------
systemctl enable bluetooth
systemctl enable firewalld
systemctl enable NetworkManager
systemctl enable upower.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable fstrim.timer
systemctl enable systemd-hibernate.service

# -------------------------------------
# Prompt for reboot
# -------------------------------------
echo
read -rp "System setup is complete. Reboot now? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "[+] Unmounting and rebooting..."
    exit 100  # signal for wrapper to reboot and unmount
else
    echo "[!] Reboot skipped. You may continue in chroot."
fi