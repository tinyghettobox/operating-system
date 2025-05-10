require recipes-core/images/core-image-minimal-initramfs.bb

COMPATIBLE_MACHINE = "^rpi$"

PACKAGE_INSTALL:append = " busybox fbv"

PACKAGE_INSTALL:append = " e2fsprogs-e2fsck"
PACKAGE_INSTALL:append = " e2fsprogs-resize2fs"
PACKAGE_INSTALL:append = " parted"

do_install() {
    bbwarn "deploydir ${DEPLOYDIR} ? ${BOOTFILES_DIR_NAME}"
}
