# Arch Installation made easy

A small summary:

1. Partition the disk into 3 part with
partition 1 = boot
partition 2 = swap
partition 3 = root

2. Run the <code>./nvme0n1-format-mount.sh</code>for nvme0n1 or <code>./sda-format-mount.sh</code> sda disk to format, create, mount subvolumes, turn on swap partition and copy the arch-easy repository into /mnt
- For nvme0n1
```
nvme0n1-format-mount.sh
```
- For sda
```
sda-format-mount.sh
```

3. Run the <code>./pacstrap.sh</code> to start installation for intel-cpu by default which can be changed to amd from within the script
```
./pacstrap.sh
```

4. Generate fstab and export it to your drive. the U tag is for the command to use the UUID of the partitions
```
genfstab -U /mnt >> /mnt/etc/fstab
```
5. Enter into the Root of your newly installed system with chroot command

```
arch-chroot /mnt
```

6. Configure Pacman settings, uncomment
color
ParalleDownloads = 5
```
vim /etc/pacman.conf
```

Then refresh the database
```
pacman -Sy
```

7. Install remaining essential packages from the <code>base-packages.txt</code> by running the command below
```
pacman -S --needed - < ./arch-easy/base-packages.txt
```

8. Edit the <code>base-uefi.sh</code> and replace oyinbra with your own username then your default password is password and can be changed at anytime with the <code>passwd User_Name</code> command the run the script to complete the installation and enable the neccessary system controls
```
./arch-easy/base-uefi.sh
```
9. Exit back into the bootable USB with
<code>exit</code>

10. Unmount with
```
umount -l /mnt
```

11. Reboot
```
reboot
```

12. login with your username and password and install your preferred Desktop Environment.

# For KDE Plasma Installation

1. Run the command bellow to install all the basics stuffs for plasma
```
sudo pacman -S plasma sddm
```
2. Install basic packages
```
sudo pacman -S alacritty kate dolphin spectacle xorg breeze-gtk kde-gtk-config xdg-desktop-portal xdg-desktop-portal-kde
```
3. Enable your bluetooth and display manager
```
sudo systemctl enable --now sddm bluetooth
```

