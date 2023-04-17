timedatectl set-ntp true
loadkeys us
#pacman -Sy reflector archlinux-keyring
#reflector --country US --latest 6 --sort rate --save /etc/pacman.d/mirrorlist
#pacman -Sy

lsblk

mkfs.btrfs -f -L ArchLinux /dev/nvme0n1p2
mkfs.vfat -n BOOT /dev/nvme0n1p1

mount /dev/nvme0n1p2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@images
btrfs subvolume create /mnt/@.snapshots
btrfs subvolume create /mnt/@swapfile


umount -l /mnt

mkdir -p /mnt/{boot/efi,home,swapfile,.snapshots,var/{cache,log,lib/libvirt/images}}

mount -o defaults,discard=async,ssd,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o defaults,discard=async,ssd,subvol=@cache /dev/nvme0n1p2 /mnt/var/cache
mount -o defaults,discard=async,ssd,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mount -o defaults,discard=async,ssd,subvol=@log /dev/nvme0n1p2 /mnt/var/lib/libvirt/images
mount -o defaults,discard=async,ssd,subvol=@.snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount -o defaults,discard=async,ssd,subvol=@swapfile /dev/nvme0n1p2 /mnt/swapfile

mount /dev/nvme0n1p1 /mnt/boot/efi

swapon /dev/nvme0n1p2

cd
cp -r arch-easy /mnt

