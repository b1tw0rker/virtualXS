#!/bin/bash



### /etc/fail2ban/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure fail2ban [y/n]: "
    if [ "$u_fail2ban" = "" ]; then
        read u_fail2ban
    fi

else 
    u_fail2ban=y
fi




if [ "$u_fail2ban" = "y" ]; then

    file_fail2ban001=/etc/fail2ban/jail.conf



    if [ -f "$file_fail2ban001" ]; then

        #grep BitWorker
        u_bitworker=$(grep -m 1 "### by BitWorker" /etc/fail2ban/jail.conf)

        if [ "$u_bitworker" != "### by BitWorker" ]; then
            sed -i 's/^backend = %(sshd_backend)s/backend = %(sshd_backend)s\n### by BitWorker\nenabled = true\nbantime = 24h\nmaxretry = 1\nbanaction = iptables-multiport/' $file_fail2ban001
            sed -i 's/^\[apache-badbots\]/\[apache-badbots\]\n### by BitWorker\nenabled = true/' $file_fail2ban001
            sed -i 's/^port    = 10000/### by BitWorker\nport    = 88\nenabled = true\nbantime = 1d\n\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
            sed -i 's/^logpath  = %(vsftpd_log)s/### by BitWorker\n#logpath  = %(vsftpd_log)s\nlogpath = /var/log/vsftpd.log\nenabled = true\nbantime = 1h\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001
            sed -i 's/^\[postfix\]/\[postfix\]\n### by BitWorker\nenabled = true\nbantime = 1d\nmaxretry = 3\nbanaction = iptables-multiport/' $file_fail2ban001

            echo "Restart fail2ban"
            systemctl restart fail2ban

        fi


    fi


    echo "FAIL2BAN STILL TODO up from [postfix-rbl] in jail.conf";

fi




