
do_install:append() {
    bbwarn "Adding to ${D}${systemd_system_unitdir}/sshdgenkeys.service"
    sed -i "4 i ConditionPathExists=!/etc/ssh/ssh_host_rsa_key" ${D}${systemd_system_unitdir}/sshdgenkeys.service
    sed -i "4 i ConditionPathExists=!/etc/ssh/ssh_host_rsa_key.pub" ${D}${systemd_system_unitdir}/sshdgenkeys.service
}