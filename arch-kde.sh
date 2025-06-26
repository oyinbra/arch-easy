#!/bin/bash
set -e

read -rp "Enter new username: " USERNAME
read -rsp "Enter password for $USERNAME: " USERPASS
echo

EFI=/dev/nvme0n1p1
SWAP=/dev/nvme0n1p2
ROOT=/dev/nvme0n1p3

echo "[+] Formatting partitions"
mkfs.fat -F32 $EFI
mkswap $SWAP
swapon $SWAP
mkfs.btrfs -f $ROOT

echo "[+] Creating BTRFS subvolumes"
mount $ROOT /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@log
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@snapshots
umount /mnt

echo "[+] Mounting subvolumes"
mount -o noatime,compress=zstd,subvol=@ $ROOT /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache,.snapshots}
mount -o noatime,compress=zstd,subvol=@home      $ROOT /mnt/home
mount -o noatime,compress=zstd,subvol=@log       $ROOT /mnt/var/log
mount -o noatime,compress=zstd,subvol=@cache     $ROOT /mnt/var/cache
mount -o noatime,compress=zstd,subvol=@snapshots $ROOT /mnt/.snapshots
mount $EFI /mnt/boot

echo "[+] Running pacstrap (with retry on failure)"
until pacstrap /mnt base linux linux-firmware btrfs-progs \
    plasma-desktop konsole dolphin sddm xorg xdg-utils xdg-user-dirs \
    networkmanager sudo efibootmgr; do
    echo "[!] pacstrap failed. Retrying in 5 seconds..."
    sleep 5
done

echo "[+] Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "[+] Entering chroot"
arch-chroot /mnt /bin/bash <<EOF
set -e

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-intl" > /etc/vconsole.conf

echo "arch-kde" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1       localhost
127.0.1.1 arch-kde.localdomain arch-kde
HOSTS

# Initramfs config
sed -i 's/^HOOKS=(.*/HOOKS=(base udev autodetect modconf block filesystems keyboard resume fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# UUIDs for boot config
ROOT_UUID=$(blkid -s UUID -o value $ROOT)
SWAP_UUID=$(blkid -s UUID -o value $SWAP)

bootctl --path=/boot install

cat > /boot/loader/loader.conf <<BOOT
default arch
timeout 3
editor no
console-mode max
BOOT

cat > /boot/loader/entries/arch.conf <<ENTRY
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw resume=UUID=$SWAP_UUID rootflags=subvol=@
ENTRY

echo "[+] Creating user: $USERNAME"
useradd -mG wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

echo "[+] Configuring sudo"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[+] Enabling services"
systemctl enable NetworkManager
systemctl enable sddm

echo "[+] Set root password"
passwd
EOF

echo "[+] Unmounting and rebooting"
umount -R /mnt
reboot