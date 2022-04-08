#!/bin/bash

### /etc/dovecot/
###
###
#if [ "$u_all" != "y" ]; then
printf "\n\n***********************************************\n\nConfigure Dovecot [y/n]: "
if [ "$u_dovecot" = "" ]; then
    read u_dovecot
fi

#else
#    u_dovecot=y
#fi

u_path=/opt/virtualXS # no ending slash

if [ "$u_dovecot" = "y" ]; then

    useradd -s /sbin/nologin -g users spam >>/dev/null 2>&1

    file_dovecot001=/etc/dovecot/dovecot-sql.conf.ext
    file_dovecot002=/etc/dovecot/dovecot.conf

    touch /etc/dovecot/master-users
    cp $u_path/files/dovecot/dovecot-sql.conf.ext /etc/dovecot/

    sed -i 's/^password=XXX/password='"$u_mysql_pwd"'/' $file_dovecot001

    sed -i 's/^#protocols = imap pop3 lmtp submission/protocols = imap pop3 ### lmtp submission/' $file_dovecot002

    ###sed -i 's/^#mail_location =/mail_location = maildir:\/home\/pop\/%u/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^#mail_location =/mail_location = mbox:~\/mail:INBOX=\/var\/spool\/mail\/%u/' /etc/dovecot/conf.d/10-mail.conf

    sed -i 's/#port = 143/port = 0\n    #port=143/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/#port = 110/port = 0\n    #port=110/' /etc/dovecot/conf.d/10-master.conf

    # this action we do later when retrieving the certs from Let's Encrypt
    #sed -i 's/^ssl_cert =/#ssl_cert =/' /etc/dovecot/conf.d/10-ssl.conf
    #sed -i 's/^ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem/#ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem\n\nssl_cert = \<\/etc\/letsencrypt\/live\/'"$u_srv"'\/fullchain.pem\nssl_key = \<\/etc\/letsencrypt\/live\/'"$u_srv"'\/privkey.pem\n/' /etc/dovecot/conf.d/10-ssl.conf

    sed -i 's/^#auth_username_translation =/auth_username_translation = \"\@.\"/' /etc/dovecot/conf.d/10-auth.conf

    ### 10-logging.conf
    ###
    ###
    touch /var/log/dovecot.log
    sed -i 's/^#log_path = syslog/#log_path = syslog\nlog_path = /var/log/dovecot.log/' /etc/dovecot/conf.d/10-logging.conf

    ### TODO UNCOMMEND THIS
    # Postfix smtp-auth
    #unix_listener /var/spool/postfix/private/auth {
    #  mode = 0666
    #}
    printf "HINT: You must manuelly uncomment \"unix_listener /var/spool/postfix/private/auth\" in File: /etc/dovecot/conf.d/10-master.conf\n"

### TODO 10-auto.conf
### #!include auth-deny.conf.ext
### #!include auth-master.conf.ext # commented by Nick 4.1.22
### #!include auth-system.conf.ext # commented by Nick 4.1.22
### !include auth-sql.conf.ext
### #!include auth-ldap.conf.ext
### #!include auth-passwdfile.conf.ext
### #!include auth-checkpassword.conf.ext
### #!include auth-vpopmail.conf.ext
### #!include auth-static.conf.ext

fi
