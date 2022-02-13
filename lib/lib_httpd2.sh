#!/bin/bash

file001=/etc/httpd/conf.d

printf "\n\n***********************************************\n\nActivate Protocol http/2 [y/n]: "
if [ "$u_httpd2" = "" ]; then
    read u_httpd2
fi

if [ "$u_httpd2" = "y" ]; then

    ### http/2
    ###
    ###
    if [ -d "$file001" ]; then
        cp $u_path/files/httpd/http2.conf $file008/
        cp $u_path/files/httpd/security.conf $file008/
    fi

    ### Check Apache State
    ###
    ###
    u_state=$(apachectl -t 2>&1)

    if [ "$u_state" = "Syntax OK" ]; then
        printf "Reload httpd\n"
        systemctl reload httpd
    else
        printf "Reload httpd failed:\n"
        apachectl -t
    fi

fi
