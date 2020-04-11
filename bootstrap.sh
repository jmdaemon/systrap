#!/bin/bash
# ./bootstrap - Arch Laptop

REQ_LIST=req

timedatectl set-ntp true  # Ensure sys clock is accurate

# Partition disks
# Make sure to make or set /home, /, swap, /boot/efi
cfdisk

# Format ext4 drives
mkfs.ext4 /dev/sdX1

# Format swap drive
mkfs.swapon /dev/sdX2

# Mount / and other drives on /mnt, /mnt/boot/efi, /home, etc
mount /dev/sdX1 /mnt

# Edit the package mirror list using your editor
# [editor] /etc/pacman.d/mirrorlist

# Auto Select the 6 fastest mirrors for Canada. Requires pacman-contrib
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
awk '/^## Canada$/{f=1; next}f==0{next}/^$/{exit}{print substr($0, 1);}' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Install base packages
pacstrap /mnt $(<arch.req.list)

# Gen File system table and check for errors
genfstab -U /mnt >> /mnt/etc/fstab
nvim /mnt/etc/fstab

# Chroot into system
arch-chroot /mnt

# Set time zone with Region and City of your choice (Canada/Pacific)
ln -sf /usr/share/zoneinfo/Canada/Pacific /etc/localtime

# Generate /etc/adjtime
hwclock --systohc

# Localization
# Uncomment en_US.UTF-8 UTF-8 and other needed locales in /etc/locale.gen, and generate them with
echo "LANG=en_US.UTF-8" > /etc/locale.conf 
# Alternative: localectl set-locale LANG=en_US.UTF-8
locale-gen

# Networking
# Create host name file
cat << 'EOF' >> /etc/hosts
127.0.0.1	arch
::1		arch
127.0.1.1	arch.localdomain arch 
EOF


# Set root passwd
passwd

# << Optional >>
# Make and add user to groups
# Note: If you make a mistake in adding user groups, you can remove them with
# gpasswd -d user group
usermod -mG wheel,audio,optical,storage,video jmd 

# Uncomment out the wheel group in /etc/sudoers
# "%wheel ALL=(ALL) ALL"
# EDITOR=ED visudo 
EDITOR=nvim visudo

# Enable services
systemctl enable lightdm

# Install GRUB Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Ctrl-d or exit out of chroot environment and unmount all partitions
umount -R /mnt

exit 
