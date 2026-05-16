#!/bin/bash

### q disable apps / Prework
### Wird auch in ks.cfg schon erledigt. Prüfen ob das noch notwendig ist. , 03.05.2026
###
printf "\n********************************************************************\n\n%d) Disable useless apps at startup [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_disable_apps" = "" ]; then
    read u_disable_apps
fi

if [ "$u_disable_apps" = "y" ]; then

    ### do not disable sssd.service for various reasons
    services=("atd" "dnf-makecache.timer" "firewalld" "saslauthd")

    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "$service"; then
            systemctl disable "$service"
            systemctl stop "$service"
            printf "[\e[32mOK\e[0m] %s disabled\n" "$service"
        else
            printf "[\e[36mINFO\e[0m] %s not found – skipped\n" "$service"
        fi
    done

fi
