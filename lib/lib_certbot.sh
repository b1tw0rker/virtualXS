#!/bin/bash

### certbot
###
###
printf "\n\n***********************************************\n\nCreate Let's Enycrypt Cert for Server: $u_srv [y/n]: "
if [ "$u_certbot" = "" ]; then
    read u_certbot
fi

if [ "$u_certbot" = "y" ]; then

    ### create cron
    ###
    ###
    cp $u_path/files/certbot/certbotcron /etc/cron.weekly/certbot
    chmod 700 /etc/cron.weekly/certbot

    ### create temporary virtual host
    ###
    ###
    cp $u_path/files/certbot/vhost.conf /etc/httpd/conf.d/$u_srv.conf

    sed -i 's/VirtualHost XXX/VirtualHost '"$u_ip"'/' /etc/httpd/conf.d/$u_srv.conf
    sed -i 's/^ServerName XXX/ServerName '"$u_srv"'/' /etc/httpd/conf.d/$u_srv.conf

    systemctl restart httpd

    ### get cert from Let's Encrypt
    ###
    ###
    certbot -d $u_srv -d $u_domain

fi

printf "\n\n***********************************************\n\nCreate Let's Enycrypt Cert for dovecot [y/n]: "
if [ "$u_certbot_dovecot" = "" ]; then
    read u_certbot_dovecot
fi

if [ "$u_certbot_dovecot" = "y" ]; then

    ### ask for servername
    u_tmp_imap=imap.$u_domain
    read -p "Servername for Dovecot (mostly imap.$u_domain): " -ei $u_tmp_imap u_imap

    ### get cert from Let's Encrypt
    ###
    ###
    certbot --apache certonly -d $u_imap

    ### update dovecot to new cert
    ###
    ###
    sed -i 's/^ssl_cert =/#ssl_cert =/' /etc/dovecot/conf.d/10-ssl.conf
    sed -i 's/^ssl_key =/#ssl_key =/' /etc/dovecot/conf.d/10-ssl.conf
    sed -i 's/^ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem/#ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem\n\nssl_cert = \<\/etc\/letsencrypt\/live\/'"$u_imap"'\/fullchain.pem\nssl_key = \<\/etc\/letsencrypt\/live\/'"$u_imap"'\/privkey.pem\n/' /etc/dovecot/conf.d/10-ssl.conf

fi
