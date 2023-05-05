pacman -Sy
pacman-key --init
pacman-key --populate archlinux
timedatectl set-ntp true
loadkeys us
pacman -S reflector archlinux-keyring
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --country US --latest 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy

lsblk

mkfs.btrfs -f -L ArchLinux /dev/sda2
mkfs.btrfs -f -L Home /dev/sda3
mkfs.vfat -n BOOT /dev/sda1
mkswap /dev/sda5

mount /dev/sda3 /mnt
btrfs subvolume create /mnt/@home
umount -l /mnt
mkdir -p /mnt/home
mount -o defaults,discard=async,ssd,subvol=@home /dev/sda3 /mnt/home

mount /dev/sda2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@images
btrfs subvolume create /mnt/@.snapshots
btrfs subvolume create /mnt/@swapfile


umount -l /mnt

mkdir -p /mnt/{boot/efi,swapfile,.snapshots,var/{cache,log,lib/libvirt/images}}

mount -o defaults,discard=async,ssd,subvol=@cache /dev/sda2 /mnt/var/cache
mount -o defaults,discard=async,ssd,subvol=@log /dev/sda2 /mnt/var/log
mount -o defaults,discard=async,ssd,subvol=@log /dev/sda2 /mnt/var/lib/libvirt/images
mount -o defaults,discard=async,ssd,subvol=@.snapshots /dev/sda2 /mnt/.snapshots
mount -o defaults,discard=async,ssd,subvol=@swapfile /dev/sda2 /mnt/swapfile

mount /dev/sda1 /mnt/boot/efi

swapon /dev/sda5

cd
cp -r arch-easy /mnt

