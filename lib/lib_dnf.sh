#!/bin/bash

file001=/etc/dnf/automatic.conf

### q run upate
###
###
confirm "Run dnf update" "$u_dnf_update"

if [ "$u_dnf_update" = "y" ]; then
    printf "\n"
    date +%s >/tmp/time.log
    dnf clean all
    dnf -y update
    date +%s >>/tmp/time.log
fi

### install
###
###
printf "\n\n***********************************************\n\nInstall apps via dnf [y/N]: "
if [ "$u_dnf" = "" ]; then
    read u_dnf
fi

if [ "$u_dnf" = "y" ]; then
    
    ### you need to activate unsupported packages first: dnf config-manager --set-enabled crb
    ### mod_fcgid - am 11.06.2025 entfernt. Mir ist noch nicht klar, ob es noch benötigt wird.
    dnf -y install epel-release yum-utils
    dnf -y install chrony httpd mysql $db_server php php-mysqlnd php-imap php-intl php-json php-ldap php-pecl-zip php-process php-bcmath php-gmp net-tools which certbot goaccess createrepo bind-utils whois postfix postfix-mysql figlet mod_proxy_fcgid mod_security mod_security_crs vsftpd php-mbstring dovecot dovecot-mysql dovecot-pigeonhole rsyslog iptraf-ng dnf-automatic perl perl-DBI perl-DBD-MySQL perl-Encode-Detect perl-JSON gd gd-devel php-gd perl-Net-SSLeay python3 python3-certbot-apache spamassassin tcp_wrappers php-soap php-xml php-gmp mod_http2 at conntrack-tools rsync tar bzip2 wget lftp ncftp unzip git quota jq perl-Net-LibIDN2 libidn libidn2 lsof htop iftop glibc-langpack-de tripwire lynis rkhunter mlocate
    
    ### to newest nodejs version
    dnf module enable nodejs:22
    dnf -y install nodejs
    
    
    
    
    
    ### Solange wir die Signatur nicht ändern können, müssen wir lokal installieren
    ###
    ###
    rpm -Uvh --nosignature $u_path/files/rpm/pam_mysql-0.8.1-0.6.el8.x86_64.rpm
    
    ### setze automatic dnf
    ### https://www.tecmint.com/setup-automatic-updates-for-centos-8/
    if [ -f "$file001" ]; then
        sed -i 's/^upgrade_type = default/upgrade_type = security/' $file001
        sed -i 's/^apply_updates = no/apply_updates = yes/' $file001
        sed -i 's/^emit_via = stdio/emit_via = motd/' $file001
        
        systemctl enable --now dnf-automatic.timer
    fi
    
fi
