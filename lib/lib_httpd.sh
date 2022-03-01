#!/bin/bash

file005=/etc/httpd/conf/httpd.conf
file006=/etc/httpd/conf.d/obsolete
file007=/etc/httpd/conf.modules.d/obsolete
file008=/etc/httpd/conf.d

printf "\n\n***********************************************\n\nConfigure /etc/httpd/conf/httpd.conf [y/n]: "
if [ "$u_httpd" = "" ]; then
    read u_httpd
fi

if [ "$u_httpd" = "y" ]; then

    if [ -f "$file005" ]; then

        sed -i 's/^#ServerName www.example.com:80/ServerName '"$u_ip"':80/' $file005

    fi

    if [ ! -d "$file006" ]; then
        mkdir $file006
    fi

    if [ ! -d "$file007" ]; then
        mkdir $file007
    fi

    if [ -d "$file006" ]; then

        if [ -f "/etc/httpd/conf.d/autoindex.conf" ]; then
            mv /etc/httpd/conf.d/autoindex.conf $file006/
        fi
        if [ -f "/etc/httpd/conf.d/userdir.conf" ]; then
            mv /etc/httpd/conf.d/userdir.conf $file006/
        fi
        if [ -f "/etc/httpd/conf.d/webalizer.conf" ]; then
            mv /etc/httpd/conf.d/webalizer.conf $file006/
        fi
        if [ -f "/etc/httpd/conf.d/welcome.conf" ]; then
            mv /etc/httpd/conf.d/welcome.conf $file006/
        fi

    fi

    if [ -d "$file007" ]; then

        if [ -f "/etc/httpd/conf.modules.d/00-dav.conf" ]; then
            mv /etc/httpd/conf.modules.d/00-dav.conf $file006/
        fi
        if [ -f "/etc/httpd/conf.modules.d/00-lua.conf" ]; then
            mv /etc/httpd/conf.modules.d/00-lua.conf $file006/
        fi

    fi

    if [ -d "/var/www/html" ]; then
        cp $u_path/files/httpd/index.html /var/www/html
    fi

    ### Autoindex
    if [ -d "/usr/share/httpd/noindex" ]; then
        cp -rf $u_path/files/httpd/index.html /usr/share/httpd/noindex/
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
