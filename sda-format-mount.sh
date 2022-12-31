timedatectl set-ntp true
loadkeys us
pacman -Sy reflector
reflector --country US --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

lsblk

mkfs.btrfs -f -L ArchLinux /dev/sda3
mkfs.vfat -n BOOT /dev/sda1
mkswap -L swap /dev/sda2

mount /dev/sda3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@.snapshots

umount -l /mnt

mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ /dev/sda3 /mnt

mkdir -p /mnt/{boot/efi,home,var/cache,var/log,.snapshots}

mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@home /dev/sda3 /mnt/home
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@cache /dev/sda3 /mnt/var/cache
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@log /dev/sda3 /mnt/var/log
mount -o noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,subvol=@.snapshots /dev/sda3 /mnt/.snapshots

mount /dev/sda1 /mnt/boot/efi

swapon /dev/sda2

cd
cp -r arch-easy /mnt

