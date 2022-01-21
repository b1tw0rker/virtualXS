#!/bin/bash



### /certbot/
###
###
printf "\n\n***********************************************\n\nConfigure Certbot Certificate [y/n]: "
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


    ### get the certificate from lets encrypt
    ###
    ###
    certbot -d $u_srv




fi




