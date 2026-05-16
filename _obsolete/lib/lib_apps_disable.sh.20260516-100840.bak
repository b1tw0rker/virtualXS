#!/bin/bash

### q disable apps / Prework
### Wird auch in ks.cfg schon erledigt. Prüfen ob das noch notwendig ist. , 03.05.2026
###
printf "\n********************************************************************\n\nDisable useless apps at startup [y/N]: "
if [ "$u_disable_apps" = "" ]; then
    read u_disable_apps
fi

if [ "$u_disable_apps" = "y" ]; then

    ### do not disable sssd.service for various reasons
    services=("atd" "certbot-renew.timer" "dnf-makecache.timer" "firewalld" "saslauthd" "sendmail")

    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "$service"; then
            systemctl disable "$service"
            systemctl stop "$service"
        fi
    done

    printf "[\e[32mOK\e[0m]\n"

fi
