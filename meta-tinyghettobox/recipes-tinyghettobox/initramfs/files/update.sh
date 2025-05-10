#!/bin/sh
#
# Assuming variables from init-overlay.sh like ROOT_MOUNT, DATA_MOUNT, ROOT_PARTITION_A, etc. are set.
# The function expects another process (admin_interface) to download the update archive and extract it to /srv/update folder.
# 

function write_update_to_partition() {
    used_partition_key=$(test -f $BOOT_MOUNT/rootfs_partition && cat $BOOT_MOUNT/rootfs_partition || echo "a")
    if [ "$used_partition_key" == "a" ]; then
        next_partition_key="b"
        next_partition_no=$ROOT_PARTITION_B_NO
        next_partition_path=$ROOT_PARTITION_B
    else
        next_partition_key="a"
        next_partition_no=$ROOT_PARTITION_A_NO
        next_partition_path=$ROOT_PARTITION_A
    fi

    if [ ! -f $DATA_MOUNT/srv/upper/update/rootfs.squashfs ]; then
        log "No update file found"
        return 1
    fi

    new_fs_size=$(stat -c %s $DATA_MOUNT/srv/upper/update/rootfs.squashfs)
    next_partition_size=$(parted -s $STORAGE_DEVICE unit b print | awk "/ $next_partition_no / {print \$4}" | sed 's/[sB]//')
    missing_space=$(($new_fs_size - $next_partition_size))

    if [ $missing_space -gt 0 ]; then
        log "Target partition $next_partition_no is too small"
        return 2
        # new_userdata_size=$(($userdata_size - $missing_space))

        # umount $DATA_MOUNT
        
        # echo "Resizing filesystem on $DATA_PARTITION to $new_userdata_size bytes"
        # e2fsck -fy $DATA_PARTITION
        # resize2fs $DATA_PARTITION $(($new_userdata_size / 1024))K

        # echo "Resizing partition $DATA_PARTITION_NO to $new_userdata_size bytes"
        # echo "Yes" | parted $STORAGE_DEVICE unit b resizepart $DATA_PARTITION_NO $new_userdata_size ---pretend-input-tty

        # echo "Resizing partition $next_partition_no to increase by $missing_space bytes"
        # echo "Yes" | parted -s $STORAGE_DEVICE unit b resizepart $next_partition_no $new_fs_size ---pretend-input-tty

        # mount_data
    fi

    log "Copying new root filesystem to $next_partition_path"
    dd if=$DATA_MOUNT/srv/upper/update/rootfs.squashfs of=$next_partition_path bs=1M
    echo $next_partition_key > $BOOT_MOUNT/rootfs_partition

    log "Copying boot files to $BOOT_MOUNT"
    cp $DATA_MOUNT/srv/upper/update/boot/* $BOOT_MOUNT/

    log "Cleaning up update files"
    rm -rf $DATA_MOUNT/srv/upper/update
    
    log "Update completed successfully"
    return 0
}