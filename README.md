# Arch Installation made easy

A small summary:

1. Partition the disk into 3 part with
partition 1 = boot
partition 2 = swap
partition 3 = root

2. Run the nvme0n1-format-mount.sh for nvme0n1 or sda-format-mount.sh sda disk to format, create, mount subvolumes and turn on swap partition

Run the pacstrap.sh to start installation for intel-cpu by default which can be changed to amd from the script

Generate fstab and export it to your drive. the U tag is for the command to use the UUID of the partitions

<code>genfstab -U /mnt >> /mnt/etc/fstab</code>





1. If needed, load your keymap
2. Refresh the servers with pacman -Syy
3. Partition the disk
4. Format the partitions
5. Mount the partitions
6. Install the base packages into /mnt (pacstrap /mnt base linux linux-firmware git vim intel-ucode (or amd-ucode))
7. Generate the FSTAB file with genfstab -U /mnt >> /mnt/etc/FSTAB
8. Chroot in with arch-chroot /mnt
9. Download the git repository with git clone https://gitlab.com/eflinux/arch-basic
10. cd arch-basic
11. chmod +x install-uefi.sh
12. run with ./install-uefi.sh
