#!/bin/bash



if [ -f "/etc/logrotate.conf" ]; then

    sed -i 's/^#compress/compress/' /etc/logrotate.conf

fi


