#!/bin/bash

file005=/etc/httpd/conf/httpd.conf
file006=/etc/httpd/conf.d/obsolete
file007=/etc/httpd/conf.modules.d/obsolete
file008=/etc/httpd/conf.d

printf "\n\n***********************************************\n\nActivate Protocol http/2 [y/n]: "
if [ "$u_httpd2" = "" ]; then
    read u_httpd2
fi

if [ "$u_httpd2" = "y" ]; then

    ### http/2
    ###
    ###
    if [ -d "$file008" ]; then
        cp $u_path/files/httpd/http2.conf $file008/
    fi

    ### Check Apache State
    ###
    ###
    u_state=$(apachectl -t 2>&1)

    if [ "$u_state" = "Syntax OK" ]; then
        printf "Reload httpd\n"
        systemctl reload httpd
    fi

fi
