#!/bin/bash

file_webmin001=/etc/webmin/miniserv.conf

### /webmin/
###
###
printf "\n\n***********************************************\n\nDownload and Install Webmin [y/n]: "
if [ "$u_webmin" = "" ]; then
        read u_webmin
fi




if [ "$u_webmin" = "y" ]; then


    if [ ! -f "webmin-1.984-1.noarch.rpm" ]; then
   
        cd /root/
        wget https://prdownloads.sourceforge.net/webadmin/webmin-1.984-1.noarch.rpm
        rpm -ivh webmin-1.984-1.noarch.rpm
    
    fi

    if [ ! -f "webmin-1.984-minimal.tar.gz" ]; then

        cd /root/
            
        wget https://prdownloads.sourceforge.net/webadmin/webmin-1.984-minimal.tar.gz

    fi


    if [ -f "$file_webmin001" ]; then
        ### Change Port from 10000 to 88
        ###
        ###
        sed -i 's/^port=10000/port=88/' $file_webmin001

        ### apply changes
        ###
        ###
        /etc/webmin/stop
        /etc/webmin/start
    fi


fi




