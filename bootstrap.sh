#!/bin/bash

REQ=req

timedatectl set-ntp true  # Ensure sys clock is accurate

## Partition disks - Create or set: /, /boot/efi, /home, swap
cfdisk

# Format ext4, and swap drives
mkfs.ext4 /dev/sdX1
mkfs.swapon /dev/sdX2

# Mount drives on /mnt, /mnt/boot/efi
mount /dev/sdX1 /mnt # Don't try to auto partition from script

## Select Mirrors in /etc/pacman.d/mirrorlist
# Auto Select the 6 fastest mirrors for Canada. Requires pacman-contrib
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
awk '/^## Canada$/{f=1; next}f==0{next}/^$/{exit}{print substr($0, 1);}' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

pacstrap /mnt $(<$REQ)              # Install base packages
genfstab -U /mnt >> /mnt/etc/fstab  # Gen fstab, check for errors
nvim /mnt/etc/fstab
arch-chroot /mnt                    # Chroot into system
ln -sf /usr/share/zoneinfo/Canada/Pacific /etc/localtime # Set time zone (Canada/Pacific)
hwclock --systohc                   # Adjust hardware clock for /etc/adjtime

## Localization - Select locales and generate en_US.UTF-8 UTF-8, etc in /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 
locale-gen                          # or do: localectl set-locale LANG=en_US.UTF-8

## Networking - /etc/hosts/
cat << 'EOF' >> /etc/hosts
127.0.0.1	arch
::1		arch
127.0.1.1	arch.localdomain arch 
EOF

passwd # Set root passwd

usermod -mG wheel,audio,optical,storage,video jmd   # Make user, set groups - To remove group: gpasswd -d user group
EDITOR=nvim visudo                                  # Uncomment "%wheel ALL=(ALL) ALL" in /etc/sudoers with visudo
systemctl enable lightdm                            # Enable services

# Install GRUB Bootloader for UEFI systems
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt # Ctrl-d or exit out of chroot environment and unmount all partitions
exit 
