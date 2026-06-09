#!/bin/bash

### /etc/dovecot/
###
###

printf "\n********************************************************************\n\n%d) Configure Dovecot [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_dovecot" = "" ]; then
    read u_dovecot
fi

u_path=/opt/virtualXS # no ending slash

if [ "$u_dovecot" = "y" ]; then
    printf "\n"
    useradd -s /sbin/nologin -g users spam >>/dev/null 2>&1

    ### vmail: virtual mail user – owns all Maildir directories under /home/pop
    ###
    getent group vmail  >/dev/null 2>&1 || groupadd -g 5000 vmail
    getent passwd vmail >/dev/null 2>&1 || useradd -u 5000 -g 5000 -d /home/pop -s /sbin/nologin -M vmail
    chown vmail:vmail /home/pop
    _log ok "vmail system user ensured (uid/gid 5000)"

    file_dovecot001=/etc/dovecot/dovecot-sql.conf.ext
    file_dovecot002=/etc/dovecot/dovecot.conf

    touch /etc/dovecot/master-users
    if cp $u_path/files/dovecot/dovecot-sql.conf.ext /etc/dovecot/; then
        _log ok "dovecot-sql.conf.ext copied"
    else
        _log error "could not copy dovecot-sql.conf.ext"
    fi

    mysql_pwd=$(grep '^password=' /root/.my.cnf | cut -d'=' -f2-)
    sed -i 's/password=XXX/password='"$mysql_pwd"'/' $file_dovecot001
    unset mysql_pwd
    sed -i 's/^#protocols = imap pop3 lmtp submission/protocols = imap lmtp/' $file_dovecot002

    # old - 09.06.2026
    #sed -i 's/^#mail_location =/mail_location = maildir:\/home\/pop\/%u\/Maildir/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^#mail_location =/mail_location = maildir:%h/\/Maildir/' /etc/dovecot/conf.d/10-mail.conf



    sed -i 's/^#mail_uid =/mail_uid = vmail/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^#mail_gid =/mail_gid = vmail/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^first_valid_uid = .*/first_valid_uid = 5000/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/#port = 143/port = 0\n    #port=143/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/#port = 110/port = 0\n    #port=110/' /etc/dovecot/conf.d/10-master.conf
    
    # old - 09.06.2026
    #sed -i 's/^#auth_username_translation =/auth_username_translation = \"\@.\"/' /etc/dovecot/conf.d/10-auth.conf

    ### 10-logging.conf
    ###
    ###
    touch /var/log/dovecot.log
    sed -i 's/^#log_path = syslog/###log_path = syslog\nlog_path = \/var\/log\/dovecot.log/' /etc/dovecot/conf.d/10-logging.conf

    ### https://unix.stackexchange.com/questions/56123/remove-line-containing-certain-string-and-the-following-line
    ###
    ###
    sed -i '/#unix_listener \/var\/spool\/postfix\/private\/auth/,+2 d' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/Postfix smtp-auth/Postfix smtp-auth\n  unix_listener \/var\/spool\/postfix\/private\/auth {\n    mode = 0666\n  }/' /etc/dovecot/conf.d/10-master.conf

    ### LMTP: Postfix-compatible socket for virtual mail delivery
    ###
    sed -i '/unix_listener \/var\/spool\/postfix\/private\/dovecot-lmtp/,+3 d' /etc/dovecot/conf.d/10-master.conf
    sed -i 's|#\?unix_listener lmtp {|unix_listener /var/spool/postfix/private/dovecot-lmtp {\n    mode = 0600\n    user = postfix\n    group = postfix|' /etc/dovecot/conf.d/10-master.conf
    _log ok "Dovecot LMTP socket configured for Postfix"

    ###
    ###
    ###
    sed -i 's/^!include auth-system.conf.ext/#!include auth-system.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
    sed -i 's/^#!include auth-sql.conf.ext/!include auth-sql.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
    _log ok "Dovecot auth configured"

    ### --- SELinux: Dovecot Dateikontexte -----------------------
    ###  /etc/dovecot und /var/log werden nach Konfiguration zurueckgesetzt.
    ###
    printf "\n--- SELinux: Dovecot ---\n"
    _selinux_ensure_tools
    _selinux_restorecon /etc/dovecot
    _selinux_restorecon /var/log

fi
