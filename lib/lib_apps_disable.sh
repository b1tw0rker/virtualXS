#!/bin/bash

### q disable apps / Prework
###
###
printf "\n\n***********************************************\n\nDisable useless apps at startup [y/N]: "
if [ "$u_disable_apps" = "" ]; then
    read u_disable
fi

if [ "$u_disable_apps" = "y" ]; then

    ### do not disable sssd.service for various reasons
    services=("atd" "certbot-renew.timer" "dnf-automatic.timer" "dnf-makecache.timer" "firewalld" "saslauthd" "sendmail")

    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "$service"; then
            systemctl disable "$service"
            systemctl stop "$service"
        fi
    done

fi
