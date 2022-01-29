#!/bin/bash



### q enable apps
###
###
printf "\n\n***********************************************\n\nEnable apps at startup [y/n]: "
if [ "$u_enable_apps" = "" ]; then
        read u_enable_apps
fi




if [ "$u_enable_apps" = "y" ]; then

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/httpd.service" ]; then
        systemctl enable httpd
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/php-fpm.service" ]; then
        systemctl enable php-fpm
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/mysqld.service" ]; then
        systemctl enable mysqld
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/postfix.service" ]; then
        systemctl enable postfix
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/vsftpd.service" ]; then
        systemctl enable vsftpd
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/dovecot.service" ]; then
        systemctl enable dovecot
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/spamassassin.service" ]; then
        systemctl enable spamassassin
    fi

fi 





### q start apps
###
###
printf "\n\n***********************************************\n\nStart apps now [y/n]: "
if [ "$u_start_apps" = "" ]; then
        read u_start_apps
fi



if [ "$u_start_apps" = "y" ]; then

    systemctl start httpd
    systemctl start php-fpm
    systemctl start mysqld
    systemctl start postfix
    systemctl start vsftpd
    systemctl start dovecot
    systemctl start spamassassin

fi 


