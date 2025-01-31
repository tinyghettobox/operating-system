#!/bin/sh
# This is an init script for initramfs to set up /etc and /srv as overlay filesystems.

# Halt on any error
set -e


# Specify the data partition
DATA_PARTITION="/dev/mmcblk0p3" 
DATA_MOUNT="/mnt/data"
ROOT_PARTITION="/dev/mmcblk0p2" 
ROOT_MOUNT="/mnt/root"

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Create mount point folders
mkdir -p $ROOT_MOUNT
mkdir -p $DATA_MOUNT

# Mount root and overlay partitions
echo "Mounting partitions"
mount -t squashfs $ROOT_PARTITION $ROOT_MOUNT
mount -t ext4 $DATA_PARTITION $DATA_MOUNT

# Prepare overlay mounts
for DIR in etc srv; do
    echo "Setting up overlay for /$DIR..."

    # Create necessary directories
    mkdir -p $ROOT_MOUNT/$DIR
    mkdir -p $DATA_MOUNT/$DIR/upper
    mkdir -p $DATA_MOUNT/$DIR/work

    # Set up the overlay mount
    mount -t overlay overlay -o lowerdir=$ROOT_MOUNT/$DIR,upperdir=$DATA_MOUNT/$DIR/upper,workdir=$DATA_MOUNT/$DIR/work $ROOT_MOUNT/$DIR
done

# Switch the root filesystem
echo "Switching root"
exec switch_root $ROOT_MOUNT /sbin/init
