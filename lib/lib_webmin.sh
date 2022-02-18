#!/bin/bash

file_webmin001=/etc/webmin/miniserv.conf
file_webmin002=/etc/webmin/config

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
        sed -i 's/^keyfile=\/etc\/webmin\/miniserv.pem\/keyfile=\/etc\/letsencrypt\/live\/'"$u_hostname"'\/privkey.pem/' $file_webmin001

        ### add certificate
        ###
        ###
        echo "certfile=/etc/letsencrypt/live/$u_hostname/fullchain.pem" >>$file_webmin002
        echo "ssl_redirect=1" >>$file_webmin002

        ### apply changes
        ###
        ###
        /etc/webmin/stop
        /etc/webmin/start
    fi

    if [ -f "$file_webmin002" ]; then
        ### Change User has just one module
        ###
        ###
        sed -i 's/^gotomodule=/gotomodule=virtualx/' $file_webmin002
        sed -i 's/^gotoone=/gotoone=1/' $file_webmin002

        ### change referrer
        ###
        ###
        sed -i 's/^referers_none=1/referers_none=0/' $file_webmin002

        ### apply changes
        ###
        ###
        /etc/webmin/stop
        /etc/webmin/start
    fi

fi
