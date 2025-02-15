#!/bin/sh
# This is an init script for initramfs to set up /etc and /srv as overlay filesystems.

# Halt on any error
set -e


# Specify the data partition
BOOT_PARTITION="/dev/mmcblk0p1" 
BOOT_MOUNT="/mnt/boot"
DATA_PARTITION="/dev/mmcblk0p3" 
DATA_MOUNT="/mnt/data"
ROOT_PARTITION="/dev/mmcblk0p2" 
ROOT_MOUNT="/mnt/root"

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Mount boot partition and give it 3 attempts to wait for sd to be ready
n=0
until [ $n -ge 3 ]
do
   mount -o ro $BOOT_PARTITION $BOOT_MOUNT &> /dev/null  && break
   let "n=n+1"
   sleep .5
done
[[ $n -ge 3 ]] && echo "FAILED TO MOUNT BOOT"

# Parse splash config from splash.txt
if [[ -f $BOOT_MOUNT/splash.txt ]]; then
   SPLASH_IMG=$(awk -F '=' '/^image/{print $2}' $BOOT_MOUNT/splash.txt)
   SPLASH_FS=$(awk -F '=' '/^fullscreen/{print $2}' $BOOT_MOUNT/splash.txt)
   SPLASH_ASP=$(awk -F '=' '/^stretch/{print $2}' $BOOT_MOUNT/splash.txt)
fi
# Set splash defaults
[[ -z $SPLASH_IMG ]] && SPLASH_IMG="splash.png"
if [[ -n $SPLASH_FS ]]; then
   [[ "$SPLASH_FS" = "1" ]] && SPLASH_OPT="--resize" || unset SPLASH_FS
fi
if [[ -n $SPLASH_ASP ]]; then
   [[ "$SPLASH_ASP" = "1" ]] && SPLASH_OPT="--resize --freeaspect" || unset SPLASH_ASP
fi
# Show splash and unmount boot
[[ -f "$BOOT_MOUNT/$SPLASH_IMG" ]] && fbsplash $SPLASH_OPT "$BOOT_MOUNT/$SPLASH_IMG" || echo "NO SPLASH IMAGE FOUND!!"
umount $BOOT_MOUNT

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
