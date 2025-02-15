SUMMARY = "Initially does some system setup"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

inherit deploy systemd

#COMPATIBLE_MACHINE = "^rpi$"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://systemd/tgb.system-setup.service \
    file://usr/lib/systemd/systemd-shutdown/poweroff.sh \
    file://bin/system-setup.sh \
    file://fonts/Quicksand-VariableFont_wght.ttf \
    file://fonts/Raleway-VariableFont_wght.ttf \
    file://etc/X11/disable-dpms.conf \
    file://etc/X11/rotate-screen.conf \
    file://etc/asound.conf \
    "

RDEPENDS:${PN} = "bash"
SYSTEMD_SERVICE:${PN} = " tgb.system-setup.service"

do_install:append() {
    install -d ${D}${sysconfdir}/X11/xorg.conf.d
    install -m 0744 ${WORKDIR}/etc/X11/disable-dpms.conf ${D}${sysconfdir}/X11/xorg.conf.d/10-disable-dpms.conf
    install -m 0744 ${WORKDIR}/etc/X11/rotate-screen.conf ${D}${sysconfdir}/X11/xorg.conf.d/20-rotate-screen.conf
    install -m 0744 ${WORKDIR}/etc/asound.conf ${D}${sysconfdir}/asound.conf

    install -d ${D}${bindir}/tinyghettobox
    install -m 0744 ${WORKDIR}/bin/system-setup.sh ${D}${bindir}/tinyghettobox/

    install -d ${D}/${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/systemd/tgb.system-setup.service ${D}${systemd_system_unitdir}

    install -d ${D}/${systemd_unitdir}
    install -m 0744 ${WORKDIR}/usr/lib/systemd/systemd-shutdown/poweroff.sh ${D}${systemd_unitdir}/systemd-shutdown/poweroff.sh

    install -d ${D}/${datadir}/fonts
    install -m 0644 ${WORKDIR}/fonts/Quicksand-VariableFont_wght.ttf ${D}${datadir}/fonts
    install -m 0644 ${WORKDIR}/fonts/Raleway-VariableFont_wght.ttf ${D}${datadir}/fonts
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/tgb.system-setup.service \
    ${bindir}/tinyghettobox/system-setup.sh \
    ${datadir}/fonts/Quicksand-VariableFont_wght.ttf \
    ${datadir}/fonts/Raleway-VariableFont_wght.ttf \
    ${sysconfdir}/X11/xorg.conf.d/10-disable-dpms.conf \
    ${sysconfdir}/X11/xorg.conf.d/20-rotate-screen.conf \
    ${systemd_unitdir}/systemd-shutdown/poweroff.sh \
    "
