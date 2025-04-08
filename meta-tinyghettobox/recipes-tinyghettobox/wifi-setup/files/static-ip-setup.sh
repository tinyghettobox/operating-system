#!/bin/bash

# Get the default gateway IP
attempts=0
while [ -z "$gateway_ip" ] && [ $attempts -lt 5 ]; do
    sleep 2
    gateway_ip=$(ip route | grep default | awk '{print $3}')
    attempts=$((attempts + 1))
done
if [ -z "$gateway_ip" ]; then
    echo "Failed to retrieve the default gateway IP after 5 attempts."
    exit 1
fi
echo "Default gateway IP: $gateway_ip"

# Extract the subnet from the gateway IP
subnet=$(echo $gateway_ip | awk -F'.' '{print $1"."$2"."$3}')

# Set the desired static IP based on the subnet
static_ip="${SUBNET}.222"

# Update systemd-networkd configuration with the correct static IP
mkdir -p /etc/systemd/network
cat <<EOF > /etc/systemd/network/25-static.network
[Match]
Name=wlan*

[Network]
Address=$static_ip/24
Gateway=$gateway_ip
DHCP=yes

[DHCP]
UseHostname=true
SendHostname=true
EOF

systemctl restart systemd-networkd
