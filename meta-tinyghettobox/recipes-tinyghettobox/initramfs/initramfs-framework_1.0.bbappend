SUMMARY = "Custom initramfs for overlay mounting"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://init-overlay.sh \
    file://fbsplash \
    "

S = "${WORKDIR}"

COMPATIBLE_MACHINE = "^rpi$"

do_install:append() {
    bbwarn "Installing initramfs files"
    install -m 0755 ${WORKDIR}/init-overlay.sh ${D}/init
    install -m 0755 ${WORKDIR}/fbsplash ${D}/bin/fbsplash
}

FILES:${PN} += "\
    /init \
    /bin/fbsplash \
    "
