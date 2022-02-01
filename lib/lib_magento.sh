#!/bin/bash

### q install magento stuff dnf
###
###
printf "\n\n***********************************************\n\nInstall Magento apps via dnf [y/n]: "
if [ "$u_magento_dnf" = "" ]; then
    read u_magento_dnf
fi

if [ "$u_magento_dnf" = "y" ]; then

    printf "MAGENTO STUDD IS STILL TODO\n"
    # dnf install stuff - eleasticsearch for example

fi
