# Arch Installation made easy

A small summary:

1. Partition the disk into 3 part with
partition 1 = boot
partition 2 = swap
partition 3 = root

2. Run the <code>./nvme0n1-format-mount.sh</code>for nvme0n1 or <code>./sda-format-mount.sh</code> sda disk to format, create, mount subvolumes, turn on swap partition and copy the arch-easy repository into /mnt

3. Run the <code>./pacstrap.sh</code> to start installation for intel-cpu by default which can be changed to amd from within the script

4. Generate fstab and export it to your drive. the U tag is for the command to use the UUID of the partitions
```
genfstab -U /mnt >> /mnt/etc/fstab
```
5. Enter into the Root of your newly installed system with chroot command

<code>arch-chroot /mnt</code>

6. Configure Pacman settings, uncomment
color
ParalleDownloads = 5

<code>vim /etc/pacman.conf</code>

7. Install remaining essential packages from the <code>base-packages.txt</code> by running the command below

<code>pacman -S --needed - < base-packages.txt</code>

8. Run the <code>base-uefi.sh</code> script to complete the installation and enable the neccessary system controls

9. Exit back into the bootable USB with
<code>exit</code>

10. Unmount with
<code>umount -l /mnt</code>

11. <code>reboot</code>

12. login with your username and password and install your preferred Desktop Environment.

