SUMMARY = "Ensures the wifi is setup and configurable via file in /boot dir"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

inherit deploy systemd

DEPENDS = "wpa-supplicant"
RDEPENDS:${PN} = "bash"

#COMPATIBLE_MACHINE = "^rpi$"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://tgb.wifi-setup.service \
    file://static-ip-setup.sh \
    file://wifi-setup.sh \
    file://wifi-config.txt \
    file://wpa_supplicant.conf \
    file://wlan0.network \
    "

SYSTEMD_SERVICE:${PN} = " tgb.wifi-setup.service"

IMAGE_BOOT_FILES:append = " ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/*"

do_install() {
    bbwarn "wifi"
    install -d ${D}${bindir}/tinyghettobox
    install -d ${D}${sysconfdir}

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/tgb.wifi-setup.service ${D}${systemd_system_unitdir}

    install -m 0744 ${WORKDIR}/wifi-setup.sh ${D}${bindir}/tinyghettobox/
    install -m 0744 ${WORKDIR}/static-ip-setup.sh ${D}${bindir}/tinyghettobox/

    install -d ${D}${sysconfdir}/wpa_supplicant
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf

    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/wlan0.network ${D}${sysconfdir}/systemd/network
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/tgb.wifi-setup.service \
    ${bindir}/tinyghettobox/wifi-setup.sh \
    ${bindir}/tinyghettobox/static-ip-setup.sh \
    ${sysconfdir}/wpa_supplicant.conf \
    ${sysconfdir}/systemd/network/wlan0.network \
    "

do_deploy() {
    bbwarn "deploy  wpa supplicant ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
    install -d ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    install -m 0644 ${WORKDIR}/wifi-config.txt ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
}

addtask deploy before do_build after do_install
#do_deploy[dirs] += "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"

