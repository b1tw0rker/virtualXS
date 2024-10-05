#!/bin/bash

if [ "$1" == "starthttp" ]; then
    echo "Stopping pihole-FTL Webserver... Starting httpd"
    systemctl stop lighttpd
    systemctl stop pihole-FTL
    sed -i 's/^LIGHTTPD_ENABLED=.*/LIGHTTPD_ENABLED=false/' /etc/pihole/setupVars.conf
    systemctl start httpd
    systemctl start pihole-FTL
    
    
    elif [ "$1" == "startpihole" ]; then
    echo "Starting pihole-FTL with Webserver... Stopping httpd"
    systemctl stop httpd
    sed -i 's/^LIGHTTPD_ENABLED=.*/LIGHTTPD_ENABLED=true/' /etc/pihole/setupVars.conf
    systemctl restart pihole-FTL
    systemctl start lighttpd
    
    
else
    echo "Ungültige Eingabe. Bitte verwenden Sie 'starthttp' oder 'startpihole'."
    exit 1
fi

exit 0
