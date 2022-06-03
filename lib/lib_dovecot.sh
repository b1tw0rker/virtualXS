#!/bin/bash

### /etc/dovecot/
###
###

printf "\n\n***********************************************\n\nConfigure Dovecot [y/n]: "
if [ "$u_dovecot" = "" ]; then
    read u_dovecot
fi

u_path=/opt/virtualXS # no ending slash

if [ "$u_dovecot" = "y" ]; then

    useradd -s /sbin/nologin -g users spam >>/dev/null 2>&1

    file_dovecot001=/etc/dovecot/dovecot-sql.conf.ext
    file_dovecot002=/etc/dovecot/dovecot.conf

    touch /etc/dovecot/master-users
    cp $u_path/files/dovecot/dovecot-sql.conf.ext /etc/dovecot/

    sed -i 's/password=XXX/password='"$u_mysql_pwd"'/' $file_dovecot001
    sed -i 's/^#protocols = imap pop3 lmtp submission/protocols = imap pop3 ### lmtp submission/' $file_dovecot002

    ###sed -i 's/^#mail_location =/mail_location = maildir:\/home\/pop\/%u/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^#mail_location =/mail_location = mbox:~\/mail:INBOX=\/var\/spool\/mail\/%u/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/#port = 143/port = 0\n    #port=143/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/#port = 110/port = 0\n    #port=110/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/^#auth_username_translation =/auth_username_translation = \"\@.\"/' /etc/dovecot/conf.d/10-auth.conf

    ### 10-logging.conf
    ###
    ###
    touch /var/log/dovecot.log
    sed -i 's/^#log_path = syslog/#log_path = syslog\n\nlog_path = /var/log/dovecot.log/' /etc/dovecot/conf.d/10-logging.conf

    ### TODO UNCOMMEND THIS
    # Postfix smtp-auth
    #unix_listener /var/spool/postfix/private/auth {
    #  mode = 0666
    #}
    printf "TODO: You must manuelly uncomment \"unix_listener /var/spool/postfix/private/auth\" in File: /etc/dovecot/conf.d/10-master.conf\n"

    sed -i 's/^!include auth-system.conf.ext/#!include auth-system.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
    sed -i 's/^#!include auth-sql.conf.ext/!include auth-sql.conf.ext/' /etc/dovecot/conf.d/10-auth.conf

### TODO 10-auth.conf
### #!include auth-deny.conf.ext
### #!include auth-master.conf.ext
### #!include auth-system.conf.ext # commented by Nick 4.1.22
### !include auth-sql.conf.ext
### #!include auth-ldap.conf.ext
### #!include auth-passwdfile.conf.ext
### #!include auth-checkpassword.conf.ext
### #!include auth-vpopmail.conf.ext
### #!include auth-static.conf.ext

fi
