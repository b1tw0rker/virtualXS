#!/bin/bash

if [ -f "/etc/crontab" ]; then

    sed -i 's/^MAILTO=root/#MAILTO=root/' /etc/crontab

    systemctl reload crond

fi
