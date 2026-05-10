#!/bin/bash

file_php_001=/etc/php.ini
file_php_002=/etc/httpd/conf.d/php.conf
file_php_003=/etc/php.d

### Mofify php.ini to yor needs here
###
###
printf "\n********************************************************************\n\nFix php-fpm and garbage-collector [y/N]: "
if [ "$u_phpfpmfix" = "" ]; then
    read u_phpfpmfix
fi

if [ "$u_phpfpmfix" = "y" ]; then

    if [ -f "$file_php_001" ]; then

        sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 20M/' $file_php_001
        sed -i 's/^expose_php = On/expose_php = Off/' $file_php_001

    fi

    ### Modify php-fpm handler
    ### https://medium.com/@jacksonpauls/moving-from-mod-php-to-php-fpm-914125a7f336
    ###
    ###
    #if [ -f "$file_php_002" ]; then
    #    cp $u_path/files/php-fpm/php.conf /etc/httpd/conf.d/
    #fi

    if [ -d "$file_php_003" ]; then
        cp $u_path/files/php/90-bw-security.ini $file_php_003
    fi


fi
