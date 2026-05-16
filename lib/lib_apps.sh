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
        if systemctl is-enabled --quiet "$service"; then
            printf "[\e[36mINFO\e[0m] %s already enabled\n" "$service"
        else
            if systemctl enable "$service" 2>/dev/null; then
                printf "[\e[32mOK\e[0m] %s enabled\n" "$service"
            else
                printf "[\e[31mFAIL\e[0m] could not enable %s\n" "$service"
            fi
        fi
    done

fi

### q start apps
###
###
printf "\n********************************************************************\n\nSmoke-Start Server now [y/N]: "
if [ "$u_start_server" = "" ]; then
    read u_start_server
fi

if [ "$u_start_server" = "y" ]; then

    for service in "${services[@]}"; do
        if systemctl start "$service" 2>/dev/null; then
            printf "[\e[32mOK\e[0m] %s started\n" "$service"
        else
            printf "[\e[31mFAIL\e[0m] could not start %s\n" "$service"
        fi
    done

fi
