SUMMARY = "Moves broadcom files for enabling wifi support"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

SRC_URI:append = " \
    https://github.com/RPi-Distro/firmware-nonfree/raw/bookworm/debian/config/brcm80211/cypress/cyfmac43430-sdio.bin;name=firmware \
    https://github.com/RPi-Distro/firmware-nonfree/raw/bookworm/debian/config/brcm80211/cypress/cyfmac43430-sdio.clm_blob;name=clm_blob \
    https://github.com/RPi-Distro/firmware-nonfree/raw/bookworm/debian/config/brcm80211/brcm/brcmfmac43430-sdio.txt;name=config \
"

SRC_URI[firmware.sha256sum] = "0717f8e798f3962230e76e9d840385ba127a38d31d6a55acd5c97cf53e4acc9d"
SRC_URI[clm_blob.sha256sum] = "3376b9c9b32d16bf762e21c7fafb665365070ae240d092498d0d1987c22022aa"
SRC_URI[config.sha256sum] = "fc3949a4c32f07c18308e7e145c7615be314158e7d714a80e04e4791f16495f9"

do_install() {
    bbwarn "install"
    install -d ${D}/usr/lib/firmware/brcm
    install -m 0644 ${WORKDIR}/cyfmac43430-sdio.bin ${D}/usr/lib/firmware/brcm/brcmfmac43430-sdio.raspberrypi,3-model-b.bin
    install -m 0644 ${WORKDIR}/cyfmac43430-sdio.clm_blob ${D}/usr/lib/firmware/brcm/brcmfmac43430-sdio.clm_blob
    install -m 0644 ${WORKDIR}/brcmfmac43430-sdio.txt ${D}/usr/lib/firmware/brcm/brcmfmac43430-sdio.txt
}

FILES:${PN} += "/usr/lib/firmware/brcm/brcmfmac43430-sdio.raspberrypi,3-model-b.bin /usr/lib/firmware/brcm/brcmfmac43430-sdio.clm_blob /usr/lib/firmware/brcm/brcmfmac43430-sdio.txt"
