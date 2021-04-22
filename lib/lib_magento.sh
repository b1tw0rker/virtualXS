#!/bin/bash



### q install magento stuff dnf
###
###
#if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nInstall Magento apps via dnf [y/n]: "
    if [ "$u_magento_dnf" = "" ]; then
        read u_magento_dnf
    fi


#else 
#    u_magento_dnf=y
#fi


if [ "$u_magento_dnf" = "y" ]; then

    printf "MAGENTO TODO\n";
    # dnf install stuff

fi 











