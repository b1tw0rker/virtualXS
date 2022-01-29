#!/bin/bash



### /etc/vsftpd/
###
###
#if [ "$u_all" != "y" ]; then
    printf "\n\n***********************************************\n\nConfigure Vsftpd [y/n]: "
    if [ "$u_vsftpd" = "" ]; then
        read u_vsftpd
    fi

#else 
#    u_vsftpd=y
#fi


if [ "$u_vsftpd" = "y" ]; then

    useradd -d /dev/null -s /sbin/nologin -g users vsftpd  >> /dev/null 2>&1


    file_vsftpd001=/etc/vsftpd/vsftpd_user_conf
    file_vsftpd002=/etc/vsftpd/vsftpd.conf
    file_vsftpd003=/etc/pam.d/vsftpd
    file_vsftpd004=/etc/letsencrypt/live/$u_hostname/fullchain.pem


    sed -i 's/^#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to HOST-X FTP service./' $file_vsftpd002
    sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' $file_vsftpd002



    if [ ! -d "$file_vsftpd001" ]; then
      mkdir $file_vsftpd001
    fi

    ### grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/vsftpd/vsftpd.conf)
    

    if [ -f "$file_vsftpd002" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
            cat $u_path/files/vsftpd/vsftpd.conf >> $file_vsftpd002
    fi



    ### pam stuff
    ###
    ###
    if [ -f "$file_vsftpd003" ]; then
        cat $u_path/files/vsftpd/pam_vsftpd > $file_vsftpd003
        sed -i 's/passwd=XXX/passwd='"$u_mysql_pwd"'/' $file_vsftpd003
    fi

    ### Cert stuff
    ###
    ###
    if [ -f "$file_vsftpd004" ]; then
        sed -i 's/^#rsa_cert_file=\/etc\/letsencrypt\/live\/XXX\/fullchain.pem/rsa_cert_file=\/etc\/letsencrypt\/live\/'"$u_hostname"'\/fullchain.pem/' $file_vsftpd002
        sed -i 's/^#rsa_private_key_file=\/etc\/letsencrypt\/live\/XXX\/privkey.pem/rsa_private_key_file=\/etc\/letsencrypt\/live\/'"$u_hostname"'\/privkey.pem/' $file_vsftpd002
    fi




fi