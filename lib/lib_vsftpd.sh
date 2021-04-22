#!/bin/bash



### /etc/vsftpd/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure Vsftpd [y/n]: "
    if [ "$u_vsftpd" = "" ]; then
        read u_vsftpd
    fi

else 
    u_vsftpd=y
fi





if [ "$u_vsftpd" = "y" ]; then

    file_vsftpd001=/etc/vsftpd/vsftpd_user_conf
    file_vsftpd002=/etc/vsftpd/vsftpd.conf
    file_vsftpd003=/etc/pam.d/vsftpd


    sed -i 's/^#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to BitWorker FTP service./' $file_vsftpd002
    sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' $file_vsftpd002



    if [ ! -d "$file_vsftpd001" ]; then
      mkdir $file_vsftpd001
    fi

    #grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/vsftpd/vsftpd.conf)
    

    if [ -f "$file_vsftpd002" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
            cat $u_path/files/vsftpd/vsftpd.conf >> $file_vsftpd002
    fi



    # pam stuff
    if [ -f "$file_vsftpd003" ]; then
        cat $u_path/files/vsftpd/pam_vsftpd > $file_vsftpd003
        sed -i 's/passwd=XXX/passwd='"$u_root_pwd"'/' $file_vsftpd003
    fi




fi