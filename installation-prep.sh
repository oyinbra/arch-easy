timedatectl set-ntp true

lsblk

mkfs.btrfs -L archlinux /dev/nvme0n1p2
mkfs.fat -F32 /dev/nvme0n1p1
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

mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p2 /mnt

mkdir -p /mnt/{boot/efi,home,var/cache/pacman/pkg,var/log,var/tmp,srv,opt,swap}

mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@pkg /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@tmp /dev/nvme0n1p2 /mnt/var/tmp
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@srv /dev/nvme0n1p2 /mnt/srv
mount -o noatime,space_cache=v2,ssd,discard=async,subvol=@opt /dev/nvme0n1p2 /mnt/opt
mount -o noatime,space_cache=v2,ssd,subvol=@snapshots /dev/nvme0n1p2 /mnt/swap

mount /dev/nvme0n1p1 /mnt/boot/efi
# swapon /dev/nvme0n1p2

lsblk

