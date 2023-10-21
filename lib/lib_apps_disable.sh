#!/bin/bash

### q disable apps / Prework
###
###
printf "\n\n***********************************************\n\nDisable useless apps at startup [y/N]: "
if [ "$u_disable_apps" = "" ]; then
    read u_disable
fi

if [ "$u_disable_apps" = "y" ]; then

    systemctl disable atd

    systemctl disable sendmail

    systemctl disable firewalld

    systemctl disable saslauthd

    ### do not disable sssd.service for various reasons
    ###
    ###
    #systemctl disable sssd

    systemctl stop atd

    systemctl stop sendmail

    systemctl stop firewalld

    systemctl stop saslauthd

fi
