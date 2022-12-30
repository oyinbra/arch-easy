timedatectl set-ntp true
loadkeys us
pacman -Sy

lsblk

mkfs.btrfs -f -L ArchLinux /dev/nvme0n1p3
mkfs.vfat -n Boot /dev/nvme0n1p1
mkswap /dev/nvme0n1p2

mount /dev/nvme0n1p3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@.snapshots

umount -l /mnt

mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ /dev/nvme0n1p3 /mnt

mkdir -p /mnt/{boot/efi,home,var/cache,var/log,.snapshots}

mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@cache /dev/nvme0n1p3 /mnt/var/cache
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@log /dev/nvme0n1p3 /mnt/var/log
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@.snapshots /dev/nvme0n1p3 /mnt/.snapshots

mount /dev/nvme0n1p1 /mnt/boot/efi

cd
cp -r arch-easy /mnt

pacman -S reflector
reflector --country US --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

