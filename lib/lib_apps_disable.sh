#!/bin/bash

### q disable apps / Prework
###
###
printf "\n\n***********************************************\n\nDisable useless apps at startup [y/n]: "
if [ "$u_disable_apps" = "" ]; then
    read u_disable
fi

if [ "$u_disable_apps" = "y" ]; then

    if [ -f "/etc/systemd/system/multi-user.target.wants/atd.service" ]; then
        systemctl disable atd
    fi

    if [ -f "/etc/systemd/system/multi-user.target.wants/sendmail.service" ]; then
        systemctl disable sendmail
    fi

    if [ -f "/etc/systemd/system/multi-user.target.wants/firewalld.service" ]; then
        systemctl disable firewalld
    fi

    if [ -f "/etc/systemd/system/multi-user.target.wants/saslauthd.service" ]; then
        systemctl disable saslauthd
    fi

    if [ -f "/etc/systemd/system/multi-user.target.wants/atd.service" ]; then
        systemctl disable atd
    fi

    ### do not disable sssd.service for various reasons
    ###
    ###
    #if [ -f "/etc/systemd/system/multi-user.target.wants/sssd.service" ]; then
    #    systemctl disable sssd
    #fi

    if [ -f "/etc/systemd/system/atd.service" ]; then
        systemctl stop atd
    fi

    if [ -f "/etc/systemd/system/sendmail.service" ]; then
        systemctl stop sendmail
    fi

    if [ -f "/etc/systemd/system/firewalld.service" ]; then
        systemctl stop firewalld
    fi

    if [ -f "/etc/systemd/system/saslauthd.service" ]; then
        systemctl stop saslauthd
    fi

fi
