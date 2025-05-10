FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SPLASH_IMAGES:append = " \
    file://splash-up.png;outsuffix=startup \
    file://splash-up.png;outsuffix=up \
    file://splash-down.png;outsuffix=down \
    "
ALTERNATIVE_PRIORITY_psplash-tinyghettobox[psplash] = "200"

SRC_URI += " \
    file://psplash-shutdown.service \
    "

SYSTEMD_SERVICE:${PN} += " psplash-shutdown.service "

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/psplash-shutdown.service ${D}${systemd_system_unitdir}
}

do_deploy () {
    # Delete this file as it causes problems with timeouts waiting for framebuffer
    rm ${D}${systemd_system_unitdir}/psplash-start.service.d/framebuf.conf
}

# rpi's bbappend file creates framebuf in do_install, so we create a deploy hook to remove it
addtask deploy before do_build after do_install

FILES:${PN} += "\
    ${systemd_system_unitdir}/psplash-shutdown.service \
    "