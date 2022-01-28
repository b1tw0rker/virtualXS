#!/bin/bash

file_php_001=/etc/php.ini


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


### Mofify php.ini to my needs
###
###
if [ -f "$file_php_001" ]; then

    sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 20M/' $file_php_001

fi

