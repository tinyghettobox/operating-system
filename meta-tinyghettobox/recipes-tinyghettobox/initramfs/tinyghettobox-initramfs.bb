require recipes-core/images/core-image-minimal-initramfs.bb

COMPATIBLE_MACHINE = "^rpi$"

PACKAGE_INSTALL:append = " busybox"
