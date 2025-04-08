#!/bin/sh
###
# Script will be called during systemd shutdown phase.
# It will set the POWER_OFF_PIN to output and pull this pin low, which will tell on-off-shim to fully cut the power.
# Additionally if set the set led will flash 4 times and the power off pin will be set to low.
###

LED_PIN=$(sqlite3 /srv/tinyghettobox/tinyghettobox.sqlite "select led_pin from system_config" || echo "0")
POWER_OFF_PIN=$(sqlite3 /srv/tinyghettobox/tinyghettobox.sqlite "select power_off_pin from system_config" || echo "4")

set_gpio() {
    for chip in $(gpiodetect | awk '{ print $1 }' ):
    do
        line=$(gpioinfo | awk "/\"GPIO$1\"/ {gsub(/:/, \"\", $2); print $2}")
        if [ "$line" != "" ]; then
            gpioset -c $chip -t0 $1=$2
            return
        fi
    done
}

if [ "$1" = "poweroff" ]; then
    if [ "${LED_PIN}" != "" ] && [ "${LED_PIN}" != "0" ]; then
        for iteration in 1 2 3 4; do
            set_gpio ${LED_PIN} 0
            /bin/sleep 0.2
            set_gpio ${LED_PIN} 1
            /bin/sleep 0.2
        done
    fi

    set_gpio ${POWER_OFF_PIN} 0
fi