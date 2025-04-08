
do_deploy:append () {
    echo "\ndtoverlay=disable-bt\n" >> $CONFIG
    echo "\ndtoverlay=hifiberry-dac\n" >> $CONFIG
}
