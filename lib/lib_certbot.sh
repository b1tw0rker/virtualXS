#!/bin/bash



### /certbot/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure Certbot Certificate [y/n]: "
    if [ "$u_certbot" = "" ]; then
        read u_certbot
    fi

else 
    u_certbot=y
fi




if [ "$u_certbot" = "y" ]; then


    #create cron
    cp $u_path/files/certbot/certbotcron /etc/cron.weekly/certbot
    chmod 700 /etc/cron.weekly/certbot

    # create temporary virtual host
    #printf "Include /etc/httpd/conf/$u_srv.conf" >> /etc/httpd/conf/httpd.conf
    cp $u_path/files/certbot/vhost.conf /etc/httpd/conf.d/$u_srv.conf

    sed -i 's/VirtualHost XXX/VirtualHost '"$u_ip"'/' /etc/httpd/conf.d/$u_srv.conf
    sed -i 's/^ServerName XXX/ServerName '"$u_srv"'/' /etc/httpd/conf.d/$u_srv.conf


    systemctl restart httpd


    ### get the certificate 
    certbot -d $u_hostname




fi




