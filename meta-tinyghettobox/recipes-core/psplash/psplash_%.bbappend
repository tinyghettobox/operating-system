FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SPLASH_IMAGES:append = " \
    file://splash-startup.png;outsuffix=startup \
    file://splash-shutdown.png;outsuffix=shutdown \
    file://splash-startup-180.png;outsuffix=startup-180 \
    file://splash-shutdown-180.png;outsuffix=shutdown-180 \
    "
ALTERNATIVE_PRIORITY_psplash-tinyghettobox[psplash] = "200"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

do_deploy () {
    # Delete this file as it causes problems with timeouts waiting for framebuffer
    rm ${D}${systemd_system_unitdir}/psplash-start.service.d/framebuf.conf
}


# rpi's bbappend file creates framebuf in do_install, so we create a deploy hook to remove it
addtask deploy before do_build after do_install
