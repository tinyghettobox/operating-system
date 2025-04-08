#!/bin/sh
# This is an init script for initramfs to set up /etc and /srv as overlay filesystems.
# Overlays can be overwritten by adding a space separated list of root folders in /boot/overlay_mounts (e.g. "etc srv var")
# The script will mount the root partition as squashfs readonly. It is assumed there 4 partitions boot, root_a, root_b and data. 
# Depending on the value in /boot/used_partition the script will mount the root_a or root_b partition. This is used for the update mechanism

# Halt on any error
set -e

function log() {
   echo "init1: $@" > /dev/kmsg
   logger "init2: $@"
   logger -p kern.notice "init3: $@"
   echo "init4: $@"
}

function panic() {
   log "PANIC: $@"
   echo c > /proc/sysrq-trigger
}

function find_partitions() {
   devices=$(lsblk -dn -o NAME)
   log "Found devices: $devices"
   for device in $devices; do
      if [[ -b /dev/$device ]]; then
         partitions=$(lsblk -ln -o NAME /dev/$device | grep -E "^${device##*/}[0-9]+$")
         log "Found partitions: $partitions"
         count=0
         for partition in $partitions; do
            case $count in
               0) BOOT_PARTITION="/dev/$partition" ;;
               1) ROOT_PARTITION_A="/dev/$partition" ;;
               2) ROOT_PARTITION_B="/dev/$partition" ;;
               3) DATA_PARTITION="/dev/$partition" ;;
            esac
            count=$((count+1))
         done
         if [[ $count -eq 4 ]]; then
            STORAGE_DEVICE="/dev/$device"
            return 0
         else
            log "Found $count partitions on $device, expected 3"
         fi
      else
         log "Skipping $device"
      fi
   done

   return 1
}

function show_splash() {
   # Parse splash config from splash.txt
   if [[ -f $BOOT_MOUNT/splash.txt ]]; then
      SPLASH_IMG=$(awk -F '=' '/^image/{print $2}' $BOOT_MOUNT/splash.txt)
      SPLASH_ROTATION=$(awk -F '=' '/^rotation/{print $2}' $BOOT_MOUNT/splash.txt)
      SPLASH_FS=$(awk -F '=' '/^fullscreen/{print $2}' $BOOT_MOUNT/splash.txt)
      SPLASH_ASP=$(awk -F '=' '/^stretch/{print $2}' $BOOT_MOUNT/splash.txt)
   fi
   # Set splash defaults
   SPLASH_OPT="--skiptty"
   [[ -z "$BOOT_MOUNT/$SPLASH_IMG" ]] && SPLASH_IMG="splash.png"
   if [[ -n $SPLASH_FS ]]; then
      [[ "$SPLASH_FS" = "1" ]] && SPLASH_OPT="$SPLASH_OPT --shrink --enlarge" || unset SPLASH_FS
   fi
   if [[ -n $SPLASH_ASP ]]; then
      [[ "$SPLASH_ASP" = "1" ]] && SPLASH_OPT="$SPLASH_OPT --ignore-aspect" || unset SPLASH_ASP
   fi
   if [[ -n $SPLASH_ROTATION ]]; then
      if [[ "$SPLASH_ROTATION" = "90" ]]; then
         SPLASH_OPT="$SPLASH_OPT --orientation 1"
      elif [[ "$SPLASH_ROTATION" = "180" ]]; then
         SPLASH_OPT="$SPLASH_OPT --orientation 2"
      elif [[ "$SPLASH_ROTATION" = "270" ]]; then
         SPLASH_OPT="$SPLASH_OPT --orientation 2"
      else
         log "Unknown splash rotation $SPLASH_ROTATION"
      fi
   fi

   # Show splash and unmount boot
   log "Showing splash image $SPLASH_OPT $BOOT_MOUNT/$SPLASH_IMG"
   if [[ -f "$BOOT_MOUNT/$SPLASH_IMG" ]];
   then
      fbv $SPLASH_OPT "$BOOT_MOUNT/$SPLASH_IMG"
   else
      log "NO SPLASH IMAGE FOUND!!"
   fi
}

function mount_essentials() {
   mount -n -t proc proc /proc
   mount -n -t sysfs sysfs /sys
   mount -n -t devtmpfs devtmpfs /dev
   mount -n -t tmpfs tmpfs /run
}

function prepare_variables() {
   BOOT_MOUNT="/mnt/boot"
   DATA_MOUNT="/mnt/data"
   ROOT_MOUNT="/mnt/root"

   mkdir -p $BOOT_MOUNT
   mkdir -p $DATA_MOUNT
   mkdir -p $ROOT_MOUNT

   n=0
   until [ $n -ge 5 ]
   do
      find_partitions && break
      let "n=n+1"
      sleep 1
   done

   if [[ $n -ge 5 ]];
   then
      panic "COULD NOT FIND PARTITIONS"
   fi
}

function mount_boot() {
   # Mount boot partition and give it 3 attempts to wait for sd to be ready
   n=0
   until [ $n -ge 3 ]
   do
      mount -o ro $BOOT_PARTITION $BOOT_MOUNT  && log "Boot mounted" && break
      let "n=n+1"
      sleep .5
   done

   if [[ $n -ge 3 ]];
   then
      panic "FAILED TO MOUNT BOOT"
   fi
}

function mount_rootfs() {
   log "Mounting root partition with overlay"

   used_partition=$(test -f $BOOT_MOUNT/rootfs_partition && cat $BOOT_MOUNT/rootfs_partition || echo "a")
   if [[ $used_partition = "a" ]]; then
      mount -t squashfs $ROOT_PARTITION_A $ROOT_MOUNT
   else
      mount -t squashfs $ROOT_PARTITION_B $ROOT_MOUNT
   fi
}

function mount_overlay() {
   mount -t ext4 $DATA_PARTITION $DATA_MOUNT
   OVERLAY_MOUNTPATHS=$(test -f $BOOT_MOUNT/overlay_mounts && cat $BOOT_MOUNT/overlay_mounts || echo "etc srv")
   # Prepare overlay mounts
   for DIR in $OVERLAY_MOUNTPATHS; do
      log "Setting up overlay for /$DIR..."

      # Create necessary directories
      mkdir -p $ROOT_MOUNT/$DIR
      mkdir -p $DATA_MOUNT/$DIR/upper
      mkdir -p $DATA_MOUNT/$DIR/work

      # Set up the overlay mount
      mount -t overlay overlay -o lowerdir=$ROOT_MOUNT/$DIR,upperdir=$DATA_MOUNT/$DIR/upper,workdir=$DATA_MOUNT/$DIR/work $ROOT_MOUNT/$DIR
   done
}

mount_essentials
prepare_variables
mount_boot
show_splash
mount_rootfs
# On the first boot we want to resize the data partition and therefore we don't mount the partition here
# We do that using systemd service tgb.system-setup.service instead of this script to keep initramfs small
if [ -f $BOOT_MOUNT/resized ]; then
   mount_overlay
fi

umount $BOOT_MOUNT

# Switch the root filesystem
log "Switching root"

exec switch_root $ROOT_MOUNT /sbin/init
