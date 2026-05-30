#!/bin/bash

file001=/etc/dnf/automatic.conf

### install
###
###
printf "\n********************************************************************\n\n"
printf "\e[2m%d) Install apps via dnf [y/N]: N  [derzeit deaktiviert]\e[0m\n" "$(( ++_vxs_step ))"
u_dnf="n"

if [ "$u_dnf" = "y" ]; then
    printf "\n"
    date +%s >/tmp/time.log
    dnf clean all
    dnf -y update
    date +%s >>/tmp/time.log
    
    ###
    ###
    ###
    dnf -y install epel-release yum-utils
    dnf -y install at bind-utils borgbackup bubblwrap bzip2 certbot chrony conntrack-tools createrepo dnf-automatic dovecot dovecot-mysql dovecot-pigeonhole fail2ban figlet install freeipa-client gd gd-devel git glibc-langpack-de goaccess htop httpd iftop iptables-nft iptraf-ng jq lftp libidn libidn2 lsof lynis mlocate mod_http2 mod_proxy_fcgid mod_security mod_security_crs mysql ncftp net-tools nodejs perl perl-DBI perl-DBD-MySQL perl-Encode-Detect perl-JSON perl-Net-LibIDN2 perl-Net-SSLeay php php-bcmath php-gd php-gmp php-imap php-intl php-ldap php-mbstring php-mysqlnd php-pecl-zip php-process php-soap php-xml postfix postfix-mysql python3 python3-certbot-apache quota ripgrep rkhunter rsync rsyslog spamassassin tar tcp_wrappers tripwire unzip vsftpd wget which whois
    

    ### dnf module ist seit rocky10 deprecated. Es gibt keine Module mehr, sondern nur noch Pakete.
    ###
    ###

    ### to newest nodejs version
    #dnf module enable nodejs:22
    #dnf -y install nodejs

    ### php 8.4 from remi repo
    #dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    #dnf module enable php:remi-8.4
    
    


    ### Solange wir die Signatur nicht ändern können, müssen wir lokal installieren
    ###
    ###
    #rpm -Uvh --nosignature $u_path/files/rpm/pam_mysql-0.8.1-0.6.el8.x86_64.rpm
    


    ### setze automatic dnf
    ### https://www.tecmint.com/setup-automatic-updates-for-centos-8/
    ###
    if [ -f "$file001" ]; then
        sed -i 's/^upgrade_type = default/upgrade_type = security/' $file001
        sed -i 's/^apply_updates = no/apply_updates = yes/' $file001
        sed -i 's/^emit_via = stdio/emit_via = motd/' $file001
        _log ok "dnf-automatic.conf updated"

        if systemctl enable --now dnf-automatic.timer; then
            _log ok "dnf-automatic.timer enabled"
        else
            _log error "dnf-automatic.timer could not be enabled"
        fi
    else
        _log info "$file001 not found – dnf-automatic skipped"
    fi
    
fi
