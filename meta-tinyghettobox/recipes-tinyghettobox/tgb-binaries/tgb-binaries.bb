SUMMARY = "Uploads initial version of tinyghettobox binaries"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

inherit deploy systemd

RDEPENDS:${PN} = "libasound gtk4 glib-2.0 cairo graphene pango gdk-pixbuf cairo-gobject"

COMPATIBLE_MACHINE = "^rpi$"

INSANE_SKIP:${PN} += "already-stripped"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://srv/tinyghettobox/user_interface \
    file://srv/tinyghettobox/admin_interface_server \
    file://srv/tinyghettobox/spotifyd \
    file://etc/asound.conf \
    file://etc/spotifyd.conf \
    file://etc/spotifyd.service \
    file://etc/tgb.user-interface.service \
    file://etc/tgb.admin-interface.service \
    "

SYSTEMD_SERVICE:${PN} = " \
    spotifyd.service \
    tgb.user-interface.service \
    tgb.admin-interface.service \
    "

do_install() {
    bbwarn "Install binaries at ${D}${servicedir}/tinyghettobox"
    install -d ${D}${servicedir}/tinyghettobox
    install -m 0744 ${WORKDIR}/srv/tinyghettobox/spotifyd ${D}${servicedir}/tinyghettobox/
    install -m 0744 ${WORKDIR}/srv/tinyghettobox/user_interface ${D}${servicedir}/tinyghettobox/
    install -m 0744 ${WORKDIR}/srv/tinyghettobox/admin_interface_server ${D}${servicedir}/tinyghettobox/
    
    bbwarn "Install conf at ${D}${sysconfdir}"
    install -d ${D}${sysconfdir}/spotifyd
    install -m 0644 ${WORKDIR}/etc/spotifyd.conf ${D}${sysconfdir}/spotifyd/
    install -m 0644 ${WORKDIR}/etc/asound.conf ${D}${sysconfdir}/

    bbwarn "Install systemd at ${D}${systemd_system_unitdir}"
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/etc/spotifyd.service ${D}${sysconfdir}/systemd/system
    install -m 0644 ${WORKDIR}/etc/tgb.user-interface.service ${D}${sysconfdir}/systemd/system
    install -m 0644 ${WORKDIR}/etc/tgb.admin-interface.service ${D}${sysconfdir}/systemd/system
}

FILES:${PN} += "\
    ${servicedir}/tinyghettobox \
    ${sysconfdir}/asound.conf \
    ${sysconfdir}/spotifyd \
    ${sysconfdir}/systemd/system/spotifyd.service \
    ${sysconfdir}/systemd/system/tgb.user-interface.service \
    ${sysconfdir}/systemd/system/tgb.admin-interface.service \
    "
