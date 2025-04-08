require recipes-core/images/core-image-minimal.bb

# Own recipes
IMAGE_INSTALL:append = " wifi-setup"
IMAGE_INSTALL:append = " system-setup"
IMAGE_INSTALL:append = " brcm-files"
IMAGE_INSTALL:append = " spotifyd"

# Splash
IMAGE_INSTALL:append = " psplash-startup psplash-startup-180 psplash-shutdown psplash-shutdown-180"

# System
IMAGE_INSTALL:append = " alsa-lib alsa-utils"
IMAGE_INSTALL:append = " systemd-analyze"
IMAGE_INSTALL:append = " libgpiod libgpiod-dev libgpiod-tools"

# Utility
IMAGE_INSTALL:append = " e2fsprogs-resize2fs"
IMAGE_INSTALL:append = " parted"
IMAGE_INSTALL:append = " lsof iproute2"
IMAGE_INSTALL:append = " htop"
#IMAGE_INSTALL:append = " evtest"
#IMAGE_INSTALL:append = " perf perf-python"

# Rendering
IMAGE_INSTALL:append = " gtk4 librsvg-gtk"
IMAGE_INSTALL:append = " xinit xserver-xorg xf86-video-fbdev xf86-input-libinput"
IMAGE_INSTALL:append = " sqlite3"

# Connectivity
# Wifi and BT drivers
#IMAGE_INSTALL:append = " linux-firmware-rpidistro-bcm43455"
#IMAGE_INSTALL:append = " linux-firmware-rpidistro-bcm43430"
# Connect to Wi-Fi
IMAGE_INSTALL:append = " wpa-supplicant"
IMAGE_INSTALL:append = " avahi-daemon"
IMAGE_INSTALL:remove = "gtk+3"
IMAGE_INSTALL:remove = "adwaita-icon-theme"

do_install() {
    bbwarn "IMAGE_BOOT_FILES ${IMAGE_BOOT_FILES}"
}


post_install() {    
    sed -i "4 i ConditionPathExists=!/etc/ssh/ssh_host_rsa_key" ${IMAGE_ROOTFS}${systemd_system_unitdir}/sshdgenkeys.service
    sed -i "4 i ConditionPathExists=!/etc/ssh/ssh_host_rsa_key.pub" ${IMAGE_ROOTFS}${systemd_system_unitdir}/sshdgenkeys.service
    
    rm ${IMAGE_ROOTFS}${systemd_system_unitdir}/psplash-start.service.d/framebuf.conf
}

ROOTFS_POSTPROCESS_COMMAND += "post_install; "