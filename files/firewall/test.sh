#!/bin/sh

if [[ $(iptables -L -n | grep 'Chain INPUT (policy ACCEPT)') ]]; then

    echo "Offline"
    echo "Activating Firewall"

    ### test if systemd process is active
    ###
    ###
    if [[ $(systemctl status firewall | grep 'active (exited)') ]]; then

        /etc/firewall/rules.fw

    else

        systemctl start firewall

    fi

fi

exit 0
