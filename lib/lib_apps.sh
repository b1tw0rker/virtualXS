#!/bin/bash

### q enable apps
###
###
printf "\n********************************************************************\n\n%d) Enable apps at startup [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_enable_apps" = "" ]; then
    read u_enable_apps
fi

services=(
    httpd
    php-fpm
    mariadb
    postfix
    vsftpd
    dovecot
    spamassassin
)

if [ "$u_enable_apps" = "y" ]; then
    printf "\n"
    for service in "${services[@]}"; do
        if systemctl is-enabled --quiet "$service"; then
            _log info "$service already enabled"
        else
            if systemctl enable "$service" 2>/dev/null; then
                _log ok "$service enabled"
            else
                _log error "could not enable $service"
            fi
        fi
    done

fi

### q start apps
###
###
printf "\n********************************************************************\n\n%d) Smoke-Start Server now [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_start_server" = "" ]; then
    read u_start_server
fi

if [ "$u_start_server" = "y" ]; then
    printf "\n"
    for service in "${services[@]}"; do
        if systemctl start "$service" 2>/dev/null; then
            _log ok "$service started"
        else
            _log error "could not start $service"
        fi
    done

fi
