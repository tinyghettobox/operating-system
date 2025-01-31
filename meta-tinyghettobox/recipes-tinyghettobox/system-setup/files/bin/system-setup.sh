#!/bin/bash

# Add debian repo to apt sources
echo "deb [trusted=yes] http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list

# Disabling getty speeds up boot, we don't need terminal access anyways
systemctl disable getty@tty1.service
# We don't need display-manager to start Xorg service
systemctl disable display-manager.service
# We don't want to wait with boot for network to spin up
systemctl disable systemd-networkd-wait-online.service
# No need to execute this setup script again
systemctl disable tgb.system-setup.service

# Delay network initialization after graphical.target
#sed -i 's/sockets.target/graphical.target/g' /usr/lib/systemd/system/systemd-networkd.socket
#sed -i 's/multi-user.target/graphical.target/g' /usr/lib/systemd/system/systemd-networkd.service
#sed -i 's/sysinit.target/graphical.target/g' /usr/lib/systemd/system/systemd-network-generator.service

# Install font files
fc-cache -f -v