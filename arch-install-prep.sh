timedatectl set-ntp true

lsblk

mkfs.btrfs -L archlinux /dev/nvme0n1p3
mkfs.fat -F32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2

lsblk

mount /dev/nvme0n1p3
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@.snapshots

umount /mnt

mkdir -p /mnt/{boot/efi,home,var/cache/pacman/pkg,var/log,var/tmp,srv,opt,.snapshots}

mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p3 /mnt
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@pkg /dev/nvme0n1p3 /mnt/var/cache/pacman/pkg
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@log /dev/nvme0n1p3 /mnt/var/log
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@tmp /dev/nvme0n1p3 /mnt/var/tmp
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@srv /dev/nvme0n1p3 /mnt/srv
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@opt /dev/nvme0n1p3 /mnt/opt
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots

mount /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/nvme0n1p2

lsblk

pacstrap /mnt base base-devel linux linux-firmware intel-ucode btrfs-progs nano git zsh neofetch
