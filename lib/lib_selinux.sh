#!/bin/bash

printf "\n********************************************************************\n\nDisable SELinux enforcement (set to permissive) [y/N]: "
read u_selinux

if [ "$u_selinux" = "y" ]; then

    if [ -f "/etc/selinux/config" ]; then

        sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

    fi

fi
