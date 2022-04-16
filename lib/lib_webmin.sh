#!/bin/bash

file_webmin001=/etc/webmin/miniserv.conf
file_webmin002=/etc/webmin/config
webmin_version=1.990

### /webmin/
###
###
printf "\n\n***********************************************\n\nDownload and Install Webmin [y/n]: "
if [ "$u_webmin" = "" ]; then
    read u_webmin
fi

if [ "$u_webmin" = "y" ]; then

    if [ ! -f "webmin-$webmin_version-1.noarch.rpm" ]; then

        cd /root/
        wget https://prdownloads.sourceforge.net/webadmin/webmin-$webmin_version-1.noarch.rpm
        rpm -Uvh webmin-$webmin_version-1.noarch.rpm

    fi

    if [ ! -f "webmin-$webmin_version-minimal.tar.gz" ]; then

        cd /root/
        wget https://prdownloads.sourceforge.net/webadmin/webmin-$webmin_version-minimal.tar.gz

    fi

    ### miniserv.conf
    ###
    ###
    if [ -f "$file_webmin001" ]; then
        ### Change Port from 10000 to 88
        ###
        ###
        sed -i 's/^port=10000/port=88/' $file_webmin001
        sed -i 's/^blockhost_time=60/blockhost_time=3601/' $file_webmin001
        sed -i 's/^keyfile=\/etc\/webmin\/miniserv.pem\/keyfile=\/etc\/letsencrypt\/live\/'"$u_hostname"'\/privkey.pem/' $file_webmin001

        ### add certificate
        ###
        ###
        echo "certfile=/etc/letsencrypt/live/$u_hostname/fullchain.pem" >>$file_webmin002
        echo "ssl_redirect=1" >>$file_webmin002

    fi

    ### /etc/webmin/config
    ###
    ###
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

        ### goto to module ?? BETA is gotomodule= in a blank webmin installtion present ???
        ###
        ###
        sed -i 's/^gotomodule=/gotomodule=virtualx/' $file_webmin002

    fi

    ### lang
    ###
    ###
    if [ -f "/root/webmin-$webmin_version/lang/de" ]; then
        sed -i 's/^session_header=Anmelden bei Webmin/session_header=Anmelden bei host-x/' /root/webmin-$webmin_version/lang/de
    fi

    if [ -f "/usr/libexec/webmin/lang/de" ]; then
        sed -i 's/^session_header=Anmelden bei Webmin/session_header=Anmelden bei host-x/' /usr/libexec/webmin/lang/de
    fi

    ### disable Webmin Logo from Loginpage
    ###
    ###
    if [ -d "/etc/webmin/authentic-theme" ]; then
        cp $u_path/files/webmin/styles.css /etc/webmin/authentic-theme/
    fi

    ### status monitor
    ###
    ###
    if [ -d "/etc/webmin/status" ]; then

        # del standard services first
        rm -f /etc/webmin/status/services/*.serv

        cp $u_path/files/webmin/status/config /etc/webmin/status/
        cp $u_path/files/webmin/status/monitor.pl /etc/webmin/status/
        cp $u_path/files/webmin/status/services/*.serv /etc/webmin/status/services/

    fi

    ### apply changes
    ###
    ###
    /etc/webmin/stop
    /etc/webmin/start

fi
