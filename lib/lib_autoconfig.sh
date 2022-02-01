#!/bin/bash

#https://wiki.mozilla.org/Thunderbird:Autoconfiguration:ConfigFileFormat
#https://www.heise.de/ct/ausgabe/2013-8-Selbstkonfiguration-von-E-Mail-Clients-2324925.html

file001=/etc/httpd/conf.d

printf "\n\n***********************************************\n\nCreate Autoconfig and Autodiscover [y/n]: "
if [ "$u_autoconfig" = "" ]; then
    read u_autoconfig
fi

if [ "$u_autoconfig" = "y" ]; then

    if [ -d "$file001" ]; then

        cp $u_path/files/autoconfig/autoconfig.conf $file001/

        if [ ! -d /home/httpd/autoconfig ]; then
            mkdir /home/httpd/autoconfig
        fi
        if [ ! -d /home/httpd/autoconfig/htdocs ]; then
            mkdir /home/httpd/autoconfig/htdocs

            touch /home/httpd/autoconfig/htdocs/favicon.ico
            touch /home/httpd/autoconfig/htdocs/index.html
        fi

        if [ ! -d /home/httpd/autoconfig/logs ]; then
            mkdir /home/httpd/autoconfig/logs
        fi

        if [ ! -d /home/httpd/autoconfig/htdocs/mail ]; then
            mkdir /home/httpd/autoconfig/htdocs/mail
            mkdir /home/httpd/autoconfig/htdocs/autodiscover
            cp $u_path/files/autoconfig/config-v1.1.xml /home/httpd/autoconfig/htdocs/mail/
            cp $u_path/files/autoconfig/autodiscover.xml /home/httpd/autoconfig/htdocs/autodiscover/
        fi

        ### insert som local Vars
        ###
        ###
        sed -i 's/<VirtualHost XXX:80>/<VirtualHost '"$u_ip4"':80>/' $file001/autoconfig.conf
        sed -i 's/<VirtualHost XXX:443>/<VirtualHost '"$u_ip4"':443>/' $file001/autoconfig.conf
        sed -i 's/XXX/'"$u_srv"'/' $file001/autoconfig.conf

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

fi
