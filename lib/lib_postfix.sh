#!/bin/bash

### /etc/postfix/main.cf
###
###
printf "\n********************************************************************\n\nConfigure /etc/postfix/main.cf [y/N]: "
if [ "$u_postfix" = "" ]; then
    read u_postfix
fi

if [ "$u_postfix" = "y" ]; then
    
    postfix_config_dir=/etc/postfix
    file_postfix001=/etc/postfix/main.cf
    file_postfix002=/etc/postfix/master.cf
    file_postfix003=/etc/postfix/header_checks
    
    ### grep BitWorker
    ###
    ###
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/postfix/main.cf)
    
    if [ -f "$file_postfix001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/postfix/main.cf >>$file_postfix001
    fi
    
    cp $u_path/files/postfix/bounce.de.default /etc/postfix/
    cp $u_path/files/postfix/mysql-domains.cf /etc/postfix/
    cp $u_path/files/postfix/mysql-virtual.cf /etc/postfix/
    
    sed -i 's/^password = XXX/password = '"$u_mysql_pwd"'/' /etc/postfix/mysql-virtual.cf
    sed -i 's/^password = XXX/password = '"$u_mysql_pwd"'/' /etc/postfix/mysql-domains.cf
    
    postconf -c "$postfix_config_dir" -e 'soft_bounce = no'
    postconf -c "$postfix_config_dir" -e "myhostname = $u_srv"
    postconf -c "$postfix_config_dir" -e "mydomain = $u_domain"
    postconf -c "$postfix_config_dir" -e 'myorigin = $myhostname'
    ### inet_interfaces: internal/private IP → all; public IP → $myhostname, localhost
    ###
    if [[ "$u_ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.) ]]; then
        postconf -c "$postfix_config_dir" -e 'inet_interfaces = all'
    else
        postconf -c "$postfix_config_dir" -e 'inet_interfaces = $myhostname, localhost'
    fi
    postconf -c "$postfix_config_dir" -e 'mynetworks_style = class'
    postconf -c "$postfix_config_dir" -e "mynetworks = $u_ip/32"
    postconf -c "$postfix_config_dir" -e 'relay_domains = $mydestination'
    postconf -c "$postfix_config_dir" -e 'mail_spool_directory = /var/spool/mail'
    postconf -c "$postfix_config_dir" -e 'smtp_address_preference = ipv4'
    postconf -c "$postfix_config_dir" -e 'inet_protocols = ipv4'
    # Security fix: https://cisofy.com/lynis/controls/MAIL-8818/
    postconf -c "$postfix_config_dir" -e 'smtpd_banner = HOST-X MAILSRV'



    ######################
    ### UNTESTED START ###
    ######################
    header_checks_rule='/^User-Agent:.*$/ REPLACE User-Agent: HOST-X Agent/1.3 '
    postconf -c "$postfix_config_dir" -e 'header_checks = regexp:/etc/postfix/header_checks'
    grep -qxF "$header_checks_rule" "$file_postfix003" 2>/dev/null || printf '%s\n' "$header_checks_rule" >>"$file_postfix003"
    ######################
    ###  UNTESTED END  ###
    ######################
    
    ### config master.cf
    postconf -c "$postfix_config_dir" -Me 'submission/inet=submission inet n - n - - smtpd'
    postconf -c "$postfix_config_dir" -Pe 'submission/inet/syslog_name=postfix/submission'
    postconf -c "$postfix_config_dir" -Pe 'submission/inet/smtpd_tls_security_level=encrypt'
    postconf -c "$postfix_config_dir" -Pe 'submission/inet/smtpd_sasl_auth_enable=yes'
    postconf -c "$postfix_config_dir" -Pe 'submission/inet/smtpd_tls_auth_only=yes'
    postconf -c "$postfix_config_dir" -Pe 'submission/inet/smtpd_relay_restrictions=permit_sasl_authenticated,reject'
    
    if [ -f "/etc/postfix/access" ]; then
        postmap /etc/postfix/access
    fi
    
    echo "Restart Postfix"
    postfix reload
    systemctl restart postfix
    printf "[\e[32mOK\e[0m]\n"
    
fi
