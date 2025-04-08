SUMMARY = "Custom initramfs for overlay mounting"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://init-overlay.sh \
    file://rootfs_partition \
    "

S = "${WORKDIR}"

COMPATIBLE_MACHINE = "^rpi$"

do_install:append() {
    install -m 0744 ${WORKDIR}/rootfs_partition ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/rootfs_partition
    install -m 0755 ${WORKDIR}/init-overlay.sh ${D}/init
}

FILES:${PN}-base += "\
    /init \
    "
