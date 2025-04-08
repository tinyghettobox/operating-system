DESCRIPTION = "Frame Buffer Viewer"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=130f9d9dddfebd2c6ff59165f066e41c"
DEPENDS = "libpng jpeg"
PR = "r2"

SRC_URI = "git://github.com/godspeed1989/fbv;protocol=http;branch=master;rev=57f26fb104ef5a718fc934006408719f929f6811"

SRC_URI[sha256sum] = "106cea452e47f46e764e1703e6e1d6502b3f20c3ff450f846aa8f9bf3c0f41e1"

S = "${WORKDIR}/git"

do_configure() {
	CC="${CC}" ./configure
}

do_compile() {
	oe_runmake CC="${CC}" CFLAGS="-O2 -Wall -D_GNU_SOURCE -D__KERNEL_STRICT_NAMES"
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 fbv ${D}${bindir}
}

