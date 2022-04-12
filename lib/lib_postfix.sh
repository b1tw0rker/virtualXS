#!/bin/bash

### /etc/postfix/main.cf
###
###
printf "\n\n***********************************************\n\nConfigure /etc/postfix/main.cf [y/n]: "
if [ "$u_postfix" = "" ]; then
    read u_postfix
fi

if [ "$u_postfix" = "y" ]; then

    file_postfix001=/etc/postfix/main.cf
    file_postfix002=/etc/postfix/master.cf

    #grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/postfix/main.cf)

    if [ -f "$file_postfix001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/postfix/main.cf >>$file_postfix001
    fi

    cp $u_path/files/postfix/bounce.de.default /etc/postfix/
    cp $u_path/files/postfix/mysql-domains.cf /etc/postfix/
    cp $u_path/files/postfix/mysql-virtual.cf /etc/postfix/

    sed -i 's/^password = XXX/password = '"$u_mysql_pwd"'/' /etc/postfix/mysql-virtual.cf
    sed -i 's/^password = XXX/password = '"$u_mysql_pwd"'/' /etc/postfix/mysql-domains.cf

    sed -i 's/^#soft_bounce = no/soft_bounce = no/' $file_postfix001
    sed -i 's/^#myhostname = host.domain.tld/myhostname = '"$u_srv"'/' $file_postfix001
    sed -i 's/^#mydomain = domain.tld/mydomain = '"$u_domain"'/' $file_postfix001
    sed -i 's/^#myorigin = $myhostname/myorigin = $myhostname/' $file_postfix001
    sed -i 's/^#inet_interfaces = $myhostname, localhost/inet_interfaces = $myhostname, localhost/' $file_postfix001
    sed -i 's/^inet_interfaces = localhost/#inet_interfaces = localhost/' $file_postfix001
    sed -i 's/^#mynetworks_style = class/mynetworks_style = class/' $file_postfix001
    sed -i 's/^#mynetworks = 168.100.189.0\/28/mynetworks = '"$u_ip"'\/32/' $file_postfix001
    sed -i 's/^#relay_domains = $mydestination/relay_domains = $mydestination/' $file_postfix001
    sed -i 's/^#mail_spool_directory = \/var\/spool\/mail/mail_spool_directory = \/var\/spool\/mail/' $file_postfix001
    sed -i 's/^inet_protocols = all/inet_protocols = ipv4/' $file_postfix001

    ### config master.cf
    ### grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/postfix/master.cf)

    if [ "$u_bitworker" != "### by BitWorker" ]; then
        sed -i 's/^#tlsproxy  unix  -       -       n       -       0       tlsproxy/#tlsproxy  unix  -       -       n       -       0       tlsproxy\n### by BitWorker\n### port 587/' $file_postfix002
        sed -i 's/^#submission inet n       -       n       -       -       smtpd/submission inet n       -       n       -       -       smtpd/' $file_postfix002
        sed -i 's/^#  -o syslog_name=postfix\/submission/  -o syslog_name=postfix\/submission/' $file_postfix002
        sed -i 's/^#  -o smtpd_tls_security_level=encrypt/  -o smtpd_tls_security_level=encrypt/' $file_postfix002
        sed -i 's/^#  -o smtpd_tls_auth_only=yes/  -o smtpd_tls_auth_only=yes/' $file_postfix002

        ### nur erstes vorkommen ersetzen
        ### demo sed -i '0,/one/ s/one/Hello/' test.txt
        ### https://stackoverflow.com/questions/31869731/what-is-the-meaning-of-0-xxx-in-sed
        sed -i '0,/^#  -o smtpd_sasl_auth_enable=yes/ s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/' $file_postfix002
        sed -i '0,/^#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject/ s/^#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject/  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject/' $file_postfix002
        sed -i '0,/^#  -o milter_macro_daemon_name=ORIGINATING/ s/^#  -o milter_macro_daemon_name=ORIGINATING/#  -o milter_macro_daemon_name=ORIGINATING\n\n### port 465/' $file_postfix002

    fi

    if [ -f "/etc/postfix/access" ]; then
        postmap /etc/postfix/access
    fi

    echo "Restart Postfix"
    postfix reload
    systemctl restart postfix

fi
