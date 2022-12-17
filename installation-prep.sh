timedatectl set-ntp true
loadkeys us

pacman -U rate-mirrors-bin-0.11.1-1-x86_64.pkg.tar.zst
rate-mirrors --allow-root --protocol https arch | sudo tee /etc/pacman.d/mirrorlist

lsblk

mkfs.btrfs -f -L archlinux /dev/nvme0n1p2
mkfs.vfat /dev/nvme0n1p1
# mkswap /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@swap

umount /mnt

mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@ /dev/nvme0n1p2 /mnt

mkdir -p /mnt/{boot/efi,home,var/cache/pacman/pkg,var/log,var/tmp,srv,opt,swap}

mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@pkg /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@tmp /dev/nvme0n1p2 /mnt/var/tmp
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@srv /dev/nvme0n1p2 /mnt/srv
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@opt /dev/nvme0n1p2 /mnt/opt
mount -o noatime,space_cache=v2,ssd,subvol=@swap /dev/nvme0n1p2 /mnt/swap

mount /dev/nvme0n1p1 /mnt/boot/efi

cd
mv arch-easy /mnt
# swapon /dev/nvme0n1p2

