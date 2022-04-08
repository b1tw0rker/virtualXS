#!/bin/bash

if [ -f "/etc/logrotate.conf" ]; then

    sed -i 's/^#compress/compress/' /etc/logrotate.conf

fi

if [ -d "/etc/logrotate.d" ]; then
    cp $u_path/files/logrotate/virtualx /etc/logrotate.d/
    cp $u_path/files/logrotate/dovecot /etc/logrotate.d/
fi
