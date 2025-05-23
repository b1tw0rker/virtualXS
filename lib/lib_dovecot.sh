#!/bin/bash
### /etc/dovecot/
###
###
printf "\n\n***********************************************\n\nConfigure Dovecot [y/N]: "
if [ "$u_dovecot" = "" ]; then
    read u_dovecot
fi
u_path=/opt/virtualXS # no ending slash

if [ "$u_dovecot" = "y" ]; then
    
    useradd -s /sbin/nologin -g users spam >>/dev/null 2>&1
    
    file_dovecot001=/etc/dovecot/dovecot-sql.conf.ext
    file_dovecot002=/etc/dovecot/dovecot.conf
    file_dovecot_ssl=/etc/dovecot/conf.d/10-ssl.conf
    
    touch /etc/dovecot/master-users
    cp $u_path/files/dovecot/dovecot-sql.conf.ext /etc/dovecot/
    sed -i 's/password=XXX/password='"$u_mysql_pwd"'/' $file_dovecot001
    sed -i 's/^#protocols = imap pop3 lmtp submission/protocols = imap ### pop3 lmtp submission/' $file_dovecot002
    ###sed -i 's/^#mail_location =/mail_location = maildir:\/home\/pop\/%u/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/^#mail_location =/mail_location = mbox:~\/mail:INBOX=\/var\/spool\/mail\/%u/' /etc/dovecot/conf.d/10-mail.conf
    sed -i 's/#port = 143/port = 0\n    #port=143/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/#port = 110/port = 0\n    #port=110/' /etc/dovecot/conf.d/10-master.conf
    sed -i 's/^#auth_username_translation =/auth_username_translation = \"\@.\"/' /etc/dovecot/conf.d/10-auth.conf
    
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
    
    ###
    ###
    ###
    sed -i 's/^!include auth-system.conf.ext/#!include auth-system.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
    sed -i 's/^#!include auth-sql.conf.ext/!include auth-sql.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
    
    ### SSL-Zertifikat Konfiguration - Let's Encrypt
    ###
    ###
    echo "Konfiguriere SSL-Zertifikate für Let's Encrypt..."
    
    # Backup der ursprünglichen SSL-Konfiguration
    cp $file_dovecot_ssl $file_dovecot_ssl.backup
    
    # Ersetze Standard Dovecot Zertifikate durch Let's Encrypt Zertifikate
    sed -i 's|^ssl_cert = <\/etc\/pki\/dovecot\/certs\/dovecot\.pem|ssl_cert = <\/etc\/letsencrypt\/live\/'"$u_hostname"'\/fullchain.pem|' $file_dovecot_ssl
    sed -i 's|^ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot\.pem|ssl_key = <\/etc\/letsencrypt\/live\/'"$u_hostname"'\/privkey.pem|' $file_dovecot_ssl
    
    # Zusätzlich: SSL aktivieren falls noch nicht aktiv
    sed -i 's/^#ssl = yes/ssl = yes/' $file_dovecot_ssl
    sed -i 's/^ssl = no/ssl = yes/' $file_dovecot_ssl
    
    # Prüfe ob Let's Encrypt Zertifikate existieren
    if [ -f "/etc/letsencrypt/live/$u_hostname/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/$u_hostname/privkey.pem" ]; then
        echo "Let's Encrypt Zertifikate gefunden und konfiguriert für Domain: $u_hostname"
    else
        echo "WARNUNG: Let's Encrypt Zertifikate für Domain $u_hostname nicht gefunden!"
        echo "Pfade überprüfen:"
        echo "  - /etc/letsencrypt/live/$u_hostname/fullchain.pem"
        echo "  - /etc/letsencrypt/live/$u_hostname/privkey.pem"
    fi
    
    echo "Dovecot SSL-Konfiguration abgeschlossen."
fi