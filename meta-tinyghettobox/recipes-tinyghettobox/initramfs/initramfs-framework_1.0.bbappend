SUMMARY = "Custom initramfs for overlay mounting"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://init-overlay.sh \
    file://update.sh \
    file://resize.sh \
    file://rootfs_partition \
    "

S = "${WORKDIR}"

COMPATIBLE_MACHINE = "^rpi$"

do_install:append() {
    install -m 0744 ${WORKDIR}/rootfs_partition ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/rootfs_partition
    install -m 0755 ${WORKDIR}/init-overlay.sh ${D}/init
    install -m 0755 ${WORKDIR}/update.sh ${D}/update.sh
    install -m 0755 ${WORKDIR}/resize.sh ${D}/resize.sh
}

FILES:${PN}-base += "\
    /init \
    /update.sh \
    /resize.sh \
    "
