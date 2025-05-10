#!/bin/bash

CONF_FILE="/boot/wifi-config.txt"
WPA_FILE="/etc/wpa_supplicant/wpa_supplicant-wlan0.conf"
NETWORKD_FILE="/etc/systemd/network/25-static.network"
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

function configure_wpa_supplicant() {
  SSID=$(sed -n 's/SSID\s*=\s*"\([^"]*\)"/\1/p' $CONF_FILE)
  PSK=$(sed -n 's/PSK\s*=\s*"\([^"]*\)"/\1/p' $CONF_FILE)

  if [ ! -f "${WPA_FILE}" ];
  then
    echo "Creating wpa file ${WPA_FILE}"
    touch $WPA_FILE
  fi

  WPA_SSID=$(sed -n 's/\s*ssid\s*=\s*"\([^"]*\)"/\1/p' $WPA_FILE)
  WPA_PSK=$(sed -n 's/\s*psk\s*=\s*\([^"]*\)/\1/p' $WPA_FILE)

  if [ "${SSID}" != "${WPA_SSID}" ] || [ "$PSK" != "$WPA_PSK" ];
  then
    echo "Updating WPA supplicant config"
    cat <<EOF > ${WPA_FILE}
update_config=1

network={
    ssid="$SSID"
    psk=$PSK
    proto=WPA2
    key_mgmt=WPA-PSK
    pairwise=CCMP TKIP
    group=CCMP TKIP
    scan_ssid=1
    priority=10
}
EOF

    echo "Restarting WPA supplicant"
    systemctl enable wpa_supplicant@wlan0
    systemctl restart wpa_supplicant@wlan0
  else
    echo "WPA supplicant config already up to date"
  fi
}

function enable_dhcp() {
  echo "Enabling DHCP for wlan0"
  cat <<EOF > $NETWORKD_FILE
[Match]
Name=wlan*

[Network]
DHCP=yes

[DHCP]
UseHostname=true
SendHostname=true
EOF

  systemctl restart systemd-networkd
}

function set_static_ip() {
  echo "Determining static IP address based on gateway IP"
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
  static_ip="${subnet}.222"

  echo "Setting static IP: $static_ip"
  # Update systemd-networkd configuration with the correct static IP
  cat <<EOF > $NETWORKD_FILE
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
}


if [ ! -f $CONF_FILE ];
then
  echo "No new wifi config found"
  exit 0
fi

if [ ! -d "$((dirname \"$NETWORKD_FILE\"))" ]; then
  mkdir -p "$(dirname \"$NETWORKD_FILE\")"
fi

# Configuring wpa_supplicant will connect to the wifi
configure_wpa_supplicant
# Let DHCP assign an IP address and this allows us to get the gateway IP
enable_dhcp
# Set the static IP address based on gateway IP
# set_static_ip
