#!/bin/bash

### /etc/fail2ban/
###
###
printf "\n\n***********************************************\n\nConfigure fail2ban [y/n]: "
if [ "$u_fail2ban" = "" ]; then
        read u_fail2ban
fi

if [ "$u_fail2ban" = "y" ]; then

        dnf -y install fail2ban

        if [ ! -f "/etc/systemd/system/multi-user.target.wants/fail2ban.service" ]; then
                systemctl enable fail2ban
        fi

        systemctl start fail2ban

        file_fail2ban001=/etc/fail2ban/jail.conf

        if [ -f "$file_fail2ban001" ]; then

                cp $u_path/files/fail2ban/jail.d/virtualxs.conf /etc/fail2ban/jail.d/
                cp $u_path/files/fail2ban/jail.d/wordpress.conf /etc/fail2ban/jail.d/

                cp $u_path/files/fail2ban/filter.d/wordpress.conf /etc/fail2ban/filter.d/

        fi

fi
