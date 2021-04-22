#!/bin/bash

### q run upate
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nRun dnf update [y/n]: "
    if [ "$u_dnf_update" = "" ]; then
        read u_dnf_update
    fi

else 
 u_dnf_update=y
fi


if [ "$u_dnf_update" = "y" ]; then
    dnf -y update
fi




### install
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nInstall apps via dnf [y/n]: "
    if [ "$u_dnf" = "" ]; then
        read u_dnf
    fi

else 
    u_dnf=y
fi




if [ "$u_dnf" = "y" ]; then

     dnf -y install epel-release yum-utils
     dnf -y install httpd mysql mysql-server webalizer php php-mysqlnd net-tools which fail2ban certbot bind-utils whois postfix postfix-mysql figlet php-json mod_fcgid vsftpd php-mbstring dovecot dovecot-mysql rsyslog iptraf-ng dnf-automatic perl-DBI perl-DBD-MySQL perl-Encode-Detect gd gd-devel php-gd perl-Net-SSLeay python3-certbot-apache spamassassin tcp_wrappers php-soap php-xml mod_http2 at conntrack-tools rsync tar wget ncftp unzip

     #dnf -y install pam_mysql
     rpm -Uvh --nosignature $u_path/files/rpm/pam_mysql-0.8.1-0.6.el8.x86_64.rpm


    ### setze automatic dnf
    ### https://www.tecmint.com/setup-automatic-updates-for-centos-8/
    sed -i 's/^upgrade_type = default/upgrade_type = security/' /etc/dnf/automatic.conf
    sed -i 's/^apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
    sed -i 's/^emit_via = stdio/emit_via = motd/' /etc/dnf/automatic.conf


    systemctl enable --now dnf-automatic.timer


fi 


