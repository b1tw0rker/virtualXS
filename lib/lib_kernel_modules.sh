#!/bin/bash

printf "\n********************************************************************\n\nDisable kernel modules (printer, USB storage, Bluetooth, unused protocols) [y/N]: "
if [ "$u_module_blacklist" = "" ]; then
    read u_module_blacklist
fi

if [ "$u_module_blacklist" = "y" ]; then

    folder_modprobe=/etc/modprobe.d

    if [ ! -d "$folder_modprobe" ]; then
        mkdir -p "$folder_modprobe"
    fi

    cp $u_path/files/firewall/99-bw-module-blacklist.conf $folder_modprobe

fi
