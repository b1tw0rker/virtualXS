#!/bin/bash

### q run upate
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nInstall Powerdns [y/n]: "
    if [ "$u_powerdns" = "" ]; then
        read u_powerdns
    fi

else 
 u_powerdns=y
fi


if [ "$u_powerdns" = "y" ]; then

    dnf -y install pdns pdns-backend-mysql pdns-recursor pdns-tools

fi