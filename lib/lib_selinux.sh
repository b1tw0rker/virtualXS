#!/bin/bash



if [ -f "/etc/selinux/config" ]; then

    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

fi


