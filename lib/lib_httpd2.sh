#!/bin/bash

file001=/etc/httpd/conf.d

if [ "$u_httpd2" != "n" ]; then

    ### http/2
    ###
    ###
    if [ -d "$file001" ]; then
        cp $u_path/files/httpd/http2.conf $file001/
        cp $u_path/files/httpd/security.conf $file001/
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
    printf "[\e[32mOK\e[0m]\n"

fi
