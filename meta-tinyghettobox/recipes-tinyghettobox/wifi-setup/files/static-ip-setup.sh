#!/bin/bash

# Get the default gateway IP
GATEWAY_IP=$(ip route | grep default | awk '{print $3}')

# Extract the subnet from the gateway IP
SUBNET=$(echo $GATEWAY_IP | awk -F'.' '{print $1"."$2"."$3}')

# Set the desired static IP based on the subnet
STATIC_IP="${SUBNET}.222"

# Update systemd-networkd configuration with the correct static IP
cat <<EOF > /etc/systemd/network/25-static.network
[Match]
Name=wlan*

[Network]
Address=$STATIC_IP/24
Gateway=$GATEWAY_IP
EOF
