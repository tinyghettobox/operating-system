DESCRIPTION = "Combined image containing boot files and squashfs rootfs used for update mechanism"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

# Define the names of the individual images (adjust if your wks names differ)

# Define the output archive name
OUTPUT_ARCHIVE_NAME = "${IMAGE_NAME}.update.tar.gz"
IGNORE_LIST = "\
        wifi-config.txt \
        splash.txt \
        splash-startup.png \
        splash-shutdown.png \
        config.txt \
    "

is_ignored() {
    for ignore in "${IGNORE_LIST}";
    do
        if [ "$ignore" == "$1" ];
        then
            return 1
        fi
    done
    return 0
}

# Create a temporary working directory
do_prepare() {
    rm -rf ${DEPLOY_DIR_IMAGE}/*.update.tar.gz
    rm -rf ${DEPLOY_DIR_IMAGE}/update_archive
    mkdir -p ${DEPLOY_DIR_IMAGE}/update_archive
}

# Copy boot files
do_copy_boot() {
    BOOT_DIR="${DEPLOY_DIR_IMAGE}/update_archive/boot"
    mkdir -p ${BOOT_DIR}

    # Find and copy files from the boot image deploy directory
    copy_pattern="${IMAGE_BOOT_FILES}"
    for pattern in $copy_pattern;
    do
        source=$(echo $pattern | cut -d ';' -f1)
        target=$(echo $pattern | cut -d ';' -f2)

        if [ ! -d "$(dirname ${BOOT_DIR}/${target})" ];
        then
            mkdir -p $(dirname ${BOOT_DIR}/${target})
        fi
        
        # handle wildcard
        if [ $(echo $source | grep -c '*') -gt 0 ];
        then
            cp -r ${DEPLOY_DIR_IMAGE}/$source ${BOOT_DIR}
            continue
        fi

        cp ${DEPLOY_DIR_IMAGE}/${source} ${BOOT_DIR}/${target}
    done

    ignored_files="${IGNORE_LIST}"
    for ignored_file in $ignored_files;
    do
        if [ -f ${BOOT_DIR}/${ignored_file} ];
        then
           rm -rf ${BOOT_DIR}/${ignored_file}
        else
           bbwarn "Does not exist ${BOOT_DIR}/${ignored_file}"
        fi
    done
}

# Copy squashfs rootfs
do_copy_squashfs() {
    # Copy the squashfs file
    cp ${IMGDEPLOYDIR}/${IMAGE_NAME}.squashfs ${DEPLOY_DIR_IMAGE}/update_archive/rootfs.squashfs
}

do_bundle_update_archive() {
    cd ${DEPLOY_DIR_IMAGE}/update_archive
    tar czvf ${DEPLOY_DIR_IMAGE}/${OUTPUT_ARCHIVE_NAME} *
}

# Tasks to execute
addtask do_prepare after do_rootfs before do_build
do_prepare[deptask] += "do_rootfs"

addtask do_copy_boot after do_prepare before do_build
do_copy_boot[deptask] += "do_rootfs"
do_copy_boot[deptask] += "do_prepare"

addtask do_copy_squashfs after do_image_squashfs before do_build
do_copy_squashfs[deptask] += "do_image_squashfs"
do_copy_squashfs[deptask] += "do_prepare"

addtask do_bundle_update_archive after do_image_complete before do_build
do_bundle_update_archive[deptask] += "do_image_complete"

# Specify the output image(s)
IMAGE_TYPES += "${OUTPUT_ARCHIVE_NAME}"
