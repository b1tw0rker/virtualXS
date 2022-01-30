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
    #file_fail2ban002=/etc/fail2ban/jail.conf.bak


    if [ -f "$file_fail2ban001" ]; then

        #grep BitWorker
        #u_bitworker=$(grep -m 1 "### by BitWorker" /etc/fail2ban/jail.conf)
#
        #if [ "$u_bitworker" != "### by BitWorker" ]; then
        #    cp $file_fail2ban001 $file_fail2ban002
        #    sed -i 's/^backend = %(sshd_backend)s/backend = %(sshd_backend)s\n### by BitWorker\nenabled = true\nbantime = 24h\nmaxretry = 1\nbanaction = iptables-multiport/' $file_fail2ban001
        #    if [ "$u_server" != "d" ]; then
        #        sed -i 's/^\[apache-badbots\]/\[apache-badbots\]\n### by BitWorker\nenabled = true/' $file_fail2ban001
        #    fi
        #    sed -i 's/^port    = 10000/### by BitWorker\nport    = 88\nenabled = true\nbantime = 1d\n\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
        #    sed -i 's/^\[postfix\]/\[postfix\]\n### by BitWorker\nenabled = true\nbantime = 1d\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
#
        #    echo "Restart fail2ban"
        #    systemctl restart fail2ban
#
        #fi


        cp $u_path/files/fail2ban/virtualxs.conf /etc/fail2ban/jail.d/


        echo "FAIL2BAN STILL TODO up from [postfix-rbl] in jail.conf";
    fi



fi




