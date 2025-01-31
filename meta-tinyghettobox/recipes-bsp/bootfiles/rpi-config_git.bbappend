
do_deploy:append () {
    bbwarn "rpi config git"
    echo "\ndtoverlay=disable-bt\n" >> $CONFIG
}
