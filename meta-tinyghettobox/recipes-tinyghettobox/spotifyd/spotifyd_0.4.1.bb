DESCRIPTION = "Spotifyd - A spotify client daemon"
HOMEPAGE = "https://github.com/Spotifyd/spotifyd"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    https://github.com/Spotifyd/spotifyd/releases/download/v${PV}/spotifyd-linux-aarch64-slim.tar.gz \
    file://spotifyd.conf \
    file://spotifyd.service \
"
SRC_URI[sha256sum] = "0f5219fbd15b69cb802b70ac51ae81db872e25c36b08e8fc22c4c8c2e6592ab9"

S = "${WORKDIR}"

RDEPENDS:${PN} += "libasound"

do_install() {
    install -d ${D}/srv/tinyghettobox
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}${sysconfdir}/spotifyd

    install -m 0755 ${WORKDIR}/spotifyd ${D}/srv/tinyghettobox/spotifyd
    install -m 0755 ${WORKDIR}/spotifyd.conf ${D}${sysconfdir}/spotifyd/spotifyd.conf
    install -m 0644 ${WORKDIR}/spotifyd.service ${D}${systemd_system_unitdir}/spotifyd.service
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/spotifyd.service \
    ${sysconfdir}/spotifyd/spotifyd.conf \
    /srv/tinyghettobox/spotifyd \
    "

SYSTEMD_SERVICE:${PN} = "spotifyd.service"
INSANE_SKIP:${PN} = "already-stripped"

inherit systemd