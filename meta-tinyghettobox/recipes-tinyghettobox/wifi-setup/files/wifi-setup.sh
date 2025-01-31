#!/bin/bash

CONF_FILE="/boot/wifi-config.txt"
WPA_FILE="/etc/wpa_supplicant/wpa_supplicant-wlan0.conf"

if [ ! -f $CONF_FILE ];
then
  echo "No new wifi config found"
fi

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

  sleep 5
  ./set-static-ip.sh
fi
