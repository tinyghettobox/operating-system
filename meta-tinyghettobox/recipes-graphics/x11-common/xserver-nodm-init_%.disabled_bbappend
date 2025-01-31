#PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

do_deploy () {
    # Commenting content of systemd service
    sed -i "s/^/#/g" ${D}${systemd_system_unitdir}/xserver-nodm.service
}

addtask deploy before do_build after do_install
