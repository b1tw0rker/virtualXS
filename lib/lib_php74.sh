#!/bin/bash

file_php_001=/etc/php.ini
file_php_002=/etc/httpd/conf.d/php.conf
file_php_003=/etc/php.d

### install php 7.4
###
###
printf "\n\n***********************************************\n\nInstall php 7.4 instead using php 7.2 [y/n]: "
if [ "$u_php74" = "" ]; then
    read u_php74
fi

if [ "$u_php74" = "y" ]; then

    dnf -y upgrade
    dnf -y module reset php
    dnf -y module install php:7.4

fi

### Mofify php.ini to yor needs here
###
###
printf "\n\n***********************************************\n\nFix php-fpm and garbage-collector [y/n]: "
if [ "$u_phpfpmfix" = "" ]; then
    read u_phpfpmfix
fi

if [ "$u_phpfpmfix" = "y" ]; then

    if [ -f "$file_php_001" ]; then

        sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 20M/' $file_php_001

    fi

    ### Modify php-fpm handler
    ### https://medium.com/@jacksonpauls/moving-from-mod-php-to-php-fpm-914125a7f336
    ###
    ###
    if [ -f "$file_php_002" ]; then
        cp $u_path/files/php-fpm/php.conf /etc/httpd/conf.d/
    fi

    if [ -d "$file_php_003" ]; then
        cp $u_path/files/php/90-bw-security.ini $file_php_003
    fi

    ### set garbage-collector cron.daily
    ###
    ###
    cp $u_path/files/php/garbage-collector /etc/cron.hourly/
    chmod 700 /etc/cron.hourly/garbage-collector

    ### set clearBuffer
    ###
    ###
    cp $u_path/files/php/clearBuffer /etc/cron.hourly/
    chmod 700 /etc/cron.hourly/clearBuffer

fi
