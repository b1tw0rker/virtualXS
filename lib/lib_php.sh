#!/bin/bash

file_php_001=/etc/php.ini
file_php_002=/etc/httpd/conf.d/php.conf
file_php_003=/etc/php.d
file_php_004=/etc/php-fpm.d/www.conf
file_php_005=/etc/php-fpm.d/www.conf.disabled

### Mofify php.ini to yor needs here
###
###
printf "\n********************************************************************\n\n%d) PHP Security patch [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_php" = "" ]; then
    read u_php
fi

if [ "$u_php" = "y" ]; then
    printf "\n"
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
        if ! cp $u_path/files/php/90-bw-security.ini $file_php_003; then
            _log error "cp 90-bw-security.ini failed"
        else
            _log ok "90-bw-security.ini copied"
        fi
    else
        _log info "PHP config dir not found – skipped"
    fi

    ###
    ###
    ###
    if [ -f "$file_php_004" ]; then
        if ! mv "$file_php_004" "$file_php_005"; then
            _log error "renaming www.conf to www.conf.disabled failed"
        else
            _log ok "www.conf renamed to www.conf.disabled"
        fi
    fi

fi
