SUMMARY = "Adding files to systemd folders"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://usr/lib/systemd/system-shutdown/poweroff.sh \
    "

do_install:append() {
    install -d ${D}/usr/lib/systemd/system-shutdown
    install -m 0744 ${WORKDIR}/usr/lib/systemd/system-shutdown/poweroff.sh ${D}/usr/lib/systemd/system-shutdown/poweroff.sh
}

FILES:${PN} += "\
    /usr/lib/systemd/system-shutdown/poweroff.sh \
    "
