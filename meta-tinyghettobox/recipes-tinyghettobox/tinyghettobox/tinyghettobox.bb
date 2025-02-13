require recipes-core/images/core-image-minimal.bb

# Own recipes
IMAGE_INSTALL:append = " wifi-setup"
IMAGE_INSTALL:append = " system-setup"
IMAGE_INSTALL:append = " brcm-files"
#IMAGE_INSTALL:append = " tgb-binaries"

# Splash
IMAGE_INSTALL:append = " psplash-startup psplash-startup-180 psplash-shutdown psplash-shutdown-180"

# System
IMAGE_INSTALL:append = " alsa-lib"
IMAGE_INSTALL:append = " systemd-analyze"

# Utility
#IMAGE_INSTALL:append = " dpkg"
#IMAGE_INSTALL:append = " apt"
#IMAGE_INSTALL:append = " gnupg"
#IMAGE_INSTALL:append = " pciutils"
#IMAGE_INSTALL:append = " dtc"
#IMAGE_INSTALL:append = " evtest"
#IMAGE_INSTALL:append = " perf perf-python"

# Rendering
IMAGE_INSTALL:append = " gtk4"
#IMAGE_INSTALL:append = " mesa"
#IMAGE_INSTALL:append = " vulkan-loader vulkan-headers"
IMAGE_INSTALL:append = " xinit xserver-xorg xf86-video-fbdev xf86-input-libinput"
#IMAGE_INSTALL:append = " wayland"
#IMAGE_INSTALL:append = " weston"
#IMAGE_INSTALL:append = " seatd"
#IMAGE_INSTALL:append = " cage"

# Connectivity
# Wifi and BT drivers
#IMAGE_INSTALL:append = " linux-firmware-rpidistro-bcm43455"
#IMAGE_INSTALL:append = " linux-firmware-rpidistro-bcm43430" 
# Connect to Wi-Fi
IMAGE_INSTALL:append = " wpa-supplicant"
# Request IP address from router
#IMAGE_INSTALL:append = " dhcpcd"
# makes device accessible via hostname
#IMAGE_INSTALL:append = " avahi-daemon"

do_install() {
    bbwarn "IMAGE_BOOT_FILES ${IMAGE_BOOT_FILES}"
}
