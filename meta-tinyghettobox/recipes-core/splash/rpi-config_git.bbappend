
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://initramfs.img \
    file://splash.txt \
    file://splash-startup.png \
    file://splash-shutdown.png \
"

do_deploy:append () {    
    install -d ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    #install -m 0644 ${WORKDIR}/initramfs.img ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/initramfs.img
    install -m 0644 ${WORKDIR}/splash.txt ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/splash.txt
    install -m 0644 ${WORKDIR}/splash-startup.png ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/splash-startup.png
    install -m 0644 ${WORKDIR}/splash-shutdown.png ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/splash-shutdown.png

    echo "\ninitramfs initramfs.img\n" >> $CONFIG
}
