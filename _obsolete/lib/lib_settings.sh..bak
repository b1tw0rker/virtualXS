#!/bin/bash

#printf "\n\n********************************************************************\n\nSet general settings like .exrc [y/N]: "

#if [ "$u_settings" = "" ]; then
#    read u_settings
#fi

if confirm "Set general settings like .exrc" "$u_settings"; then

    if [ -d "/root" ]; then
        cp $u_path/files/settings/.exrc /root/
    fi

fi
