#!/bin/bash

# Add debian repo to apt sources
if [ -d /etc/apt ]; then
    echo "deb [trusted=yes] http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list
fi

# Install font files
fc-cache -f -v

# Disabling getty speeds up boot, we don't need terminal access anyways
systemctl disable getty@tty1.service
# We don't need display-manager to start Xorg service
systemctl disable display-manager.service

systemctl disable xserver-nodm.service
systemctl stop xserver-nodm.service
# We don't want to wait with boot for network to spin up
systemctl disable systemd-networkd-wait-online.service
# No need to execute this setup script again
systemctl disable tgb.system-setup.service

# Delay network initialization after graphical.target
#sed -i 's/sockets.target/graphical.target/g' /usr/lib/systemd/system/systemd-networkd.socket
#sed -i 's/multi-user.target/graphical.target/g' /usr/lib/systemd/system/systemd-networkd.service
#sed -i 's/sysinit.target/graphical.target/g' /usr/lib/systemd/system/systemd-network-generator.service

# if [ ! -f /boot/resized ]; then
#     if [ -b "/dev/sda4" ]; then
#         device="/dev/sda"
#         partition="/dev/sda4"
#         partition_no=4
#     elif [ -b "/dev/mmcblk0p4" ]; then
#         device="/dev/mmcblk0"
#         partition="/dev/mmcblk0p4"
#         partition_no=4
#     else
#         echo "No partition found to resize"
#         exit 1
#     fi

#     disk_size=$(blockdev --getsz $device)
#     new_end_sector=$(($disk_size - 1)) # Subtract 1 from the disk size
#     start_sector=$(parted -s $device unit s print | awk "/ $partition_no / {print \$2}" | sed 's/[sB]//')

#     # Check if the new end sector is valid.
#     if [ "$new_end_sector" -le "$start_sector" ]; then
#         echo "Invalid new end sector. Exiting."
#         exit 1
#     fi

#     echo "Resizing partition $partition from $start_sector to $new_end_sector"
#     parted -s $device resizepart $partition_no "$new_end_sector"s
#     e2fsck -fy $partition
#     resize2fs $partition
#     echo "done" > /boot/resized
#     echo "Resized partition $partition"

#     # reboot now
# fi