#!/bin/bash

### q enable apps
###
###
printf "\n********************************************************************\n\nEnable apps at startup [y/N]: "
if [ "$u_enable_apps" = "" ]; then
    read u_enable_apps
fi

services=(
    httpd
    php-fpm
    mysqld
    postfix
    vsftpd
    dovecot
    spamassassin
)

if [ "$u_enable_apps" = "y" ]; then

    for service in "${services[@]}"; do
        if ! systemctl is-enabled --quiet "$service"; then
            systemctl enable "$service"
        fi
    done

    printf "[\e[32mOK\e[0m]\n"

fi

### q start apps
###
###
printf "\n********************************************************************\n\nSmoke-Start apps now [y/N]: "
if [ "$u_start_apps" = "" ]; then
    read u_start_apps
fi

if [ "$u_start_apps" = "y" ]; then

    for service in "${services[@]}"; do
        systemctl start "$service"
    done
    printf "[\e[32mOK\e[0m]\n"

fi
