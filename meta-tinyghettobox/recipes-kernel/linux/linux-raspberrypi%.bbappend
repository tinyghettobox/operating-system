FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://kernel.cfg"

#KBUILD_DEFCONFIG = "custom_defconfig"
#KBUILD_DEFCONFIG:raspberrypi3-64 = "custom_defconfig"
#KCONFIG_MODE = "--alldefconfig"
#KERNEL_VERSION_SANITY_SKIP = "1"

#do_kernel_metadata:prepend() {
#    bbwarn "${WORKDIR}"
#    install -d ${S}/arch/${ARCH}/configs
#    install -m 0644 ${WORKDIR}/custom_defconfig ${S}/arch/${ARCH}/configs/${KBUILD_DEFCONFIG} || die "No default configuration for ${MACHINE} / ${KBUILD_DEFCONFIG} available."
#}

COMPATIBLE_MACHINE = "raspberrypi3-64"
