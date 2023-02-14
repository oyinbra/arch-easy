# Chroot into Arch installed with subvolumes on BTRFS
lsblk
mount -o subvol=@ /dev/nvme0n1p3 /mnt
mount -o subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o subvol=@cache /dev/nvme0n1p3 /mnt/var/cache
mount -o subvol=@log /dev/nvme0n1p3 /mnt/var/log
mount -o subvol=@log /dev/nvme0n1p3 /mnt/var/lib/libvirt
mount /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/nvme0n1p2
lsblk
arch-chroot /mnt
