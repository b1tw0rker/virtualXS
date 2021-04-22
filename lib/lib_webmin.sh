#!/bin/bash

file_webmin001=/etc/webmin/miniserv.conf

### /webmin/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nInstall Webmin [y/n]: "
    if [ "$u_webmin" = "" ]; then
        read u_webmin
    fi

else 
    u_webmin=y
fi




if [ "$u_webmin" = "y" ]; then


    if [ -f "webmin-1.973-1.noarch.rpm" ]; then
            rm -f webmin-1.973-1.noarch.rpm
    fi


    wget http://prdownloads.sourceforge.net/webadmin/webmin-1.973-1.noarch.rpm
    rpm -ivh webmin-1.973-1.noarch.rpm

    if [ -f "$file_webmin001" ]; then
        ### Change Port from 10000 to 88
        sed -i 's/^port=10000/port=88/' $file_webmin001

        ### apply changes
        /etc/webmin/stop
        /etc/webmin/start
    fi


fi




