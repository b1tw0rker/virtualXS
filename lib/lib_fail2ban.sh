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
    file_fail2ban002=/etc/fail2ban/jail.conf.bak


    if [ -f "$file_fail2ban001" ]; then

        #grep BitWorker
        u_bitworker=$(grep -m 1 "### by BitWorker" /etc/fail2ban/jail.conf)

        if [ "$u_bitworker" != "### by BitWorker" ]; then
            cp $file_fail2ban001 $file_fail2ban002
            sed -i 's/^backend = %(sshd_backend)s/backend = %(sshd_backend)s\n### by BitWorker\nenabled = true\nbantime = 24h\nmaxretry = 1\nbanaction = iptables-multiport/' $file_fail2ban001
            if [ "$u_server" != "d" ]; then
                sed -i 's/^\[apache-badbots\]/\[apache-badbots\]\n### by BitWorker\nenabled = true/' $file_fail2ban001
            fi
            sed -i 's/^port    = 10000/### by BitWorker\nport    = 88\nenabled = true\nbantime = 1d\n\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
            ### FAILURE !!!
            ###sed -i 's/^logpath  = %(vsftpd_log)s/### by BitWorker\n#logpath  = %(vsftpd_log)s\nlogpath = /var/log/vsftpd.log\nenabled = true\nbantime = 1h\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
            sed -i 's/^\[postfix\]/\[postfix\]\n### by BitWorker\nenabled = true\nbantime = 1d\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001

            echo "Restart fail2ban"
            systemctl restart fail2ban

        fi


    fi


    file004=/etc/bitworker

    if [ ! -d "$file004" ]; then
      mkdir $file004
    fi

      cp $u_path/files/bitworker/bw-* $file004/
      chmod 700 $file004/bw-show-jails.sh
      chmod 700 $file004/bw-unban-jails.sh
      chmod 700 $file004/bw-import-mysql.sh
      chmod 700 $file004/bw-list-all-zones.sh

      ln -s $file004/bw-show-jails.sh /bin/bw-show-jails.sh
      ln -s $file004/bw-unban-jails.sh /bin/bw-unban-jails.sh
      ln -s $file004/bw-import-mysql.sh /bin/bw-import-mysql.sh
      ln -s $file004/bw-list-all-zones.sh /bin/bw-list-all-zones.sh
    





    echo "FAIL2BAN STILL TODO up from [postfix-rbl] in jail.conf";

fi




