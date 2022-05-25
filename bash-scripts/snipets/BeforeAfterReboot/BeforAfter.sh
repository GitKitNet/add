#!/bin/bash

# wget -O /root/script https://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/BeforeAfterReboot/BeforAfter.sh && chmod +x /root/script && bash /root/script     


myupdate_START() {

MyUPdate="/etc/init.d/myupdate"
touch $MyUPdate
cat> $MyUPdate <<EOF
#! /bin/sh

### BEGIN INIT INFO
# Provides:          myupdate
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin

case "$1" in
    start)
        /root/script
        ;;
    stop|restart|reload)
        ;;
esac

EOF
chmod +x $MyUPdate
########
}



SCRIPT_START() {
SCRIPT="/root/script
touch $SCRIPT_RUN
}

rebooting_START() {

before_reboot(){
    # Do stuff
  touch /root/before_reboot
}

after_reboot(){
    # Do stuff

    touch /root/after_reboot
  
}

# script
if [ -f /var/run/rebooting-for-updates ]; then
    after_reboot
    rm /var/run/rebooting-for-updates
    update-rc.d myupdate remove
else
    before_reboot
    touch /var/run/rebooting-for-updates
    update-rc.d myupdate defaults
    sudo reboot
fi
}

myupdate_START
SCRIPT_START
