#!/bin/sh
function resize_data_to_disk() {
    disk_name=$(basename $STORAGE_DEVICE)
    disk_size=$(cat /sys/block/$disk_name/size)
    new_end_sector=$(($disk_size - 1)) # Subtract 1 from the disk size
    start_sector=$(parted -s $STORAGE_DEVICE unit s print | awk "/ $DATA_PARTITION_NO / {print \$2}" | sed 's/[sB]//')

    # Check if the new end sector is valid.
    if [ "$new_end_sector" -le "$start_sector" ]; then
        echo "Invalid new end sector. Exiting."
        return 1
    fi

    log "Resizing partition $DATA_PARTITION from $start_sector to $new_end_sector"
    parted -s $STORAGE_DEVICE resizepart $DATA_PARTITION_NO "$new_end_sector"s

    # Use -p flag for e2fsck to repair automatically without questions
    e2fsck -fy $DATA_PARTITION || {
        log "Filesystem check completed with non-zero status, but continuing anyway"
    }

    # Capture output of resize2fs to check if it's already at the correct size
    resize_output=$(resize2fs $DATA_PARTITION 2>&1)

    log "Resize2fs output: $resize_output"

    # Check if BOOT_MOUNT is accessible before trying to write to it
    if [ -d "$BOOT_MOUNT" ]; then
        # Make sure the directory is writable
        if touch "$BOOT_MOUNT/test_write" 2>/dev/null; then
            rm -f "$BOOT_MOUNT/test_write"
            echo "done" > "$BOOT_MOUNT/resized"
            log "Successfully wrote resized marker to $BOOT_MOUNT/resized"
        else
            log "Warning: $BOOT_MOUNT exists but is not writable, skipping resized marker"
            return 2
        fi
    else
        log "Warning: $BOOT_MOUNT directory does not exist, skipping resized marker"
        return 3
    fi

    log "Resize process completed for partition $DATA_PARTITION"
    return 0
}


