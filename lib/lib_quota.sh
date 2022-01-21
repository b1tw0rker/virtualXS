#!/bin/bash

### https://www.server-world.info/en/note?os=CentOS_8&p=diskquota
### https://www.golinuxcloud.com/configure-enable-disable-xfs-quota-grace-time/

file_fstab001=/etc/fstab
file_fstab002=/etc/fstab.bak

### q quota
###
###
#if [ "$u_quota" != "y" ]; then
    printf "\n\n***********************************************\n\nActivate Quota for /home [y/n]: "
    if [ "$u_quota" = "" ]; then
        read u_quota
    fi

#else 
# u_quota=y
#fi


if [ "$u_quota" = "y" ]; then

    ### do some searchs inorder to inspect the system
    ### grep uquota
    ###
    u_quota_uquota=$(grep -m 1 "uquota" /etc/fstab)  ## search for uquota
    u_quota_home=$(grep -m 1 "/home" /etc/fstab) # search for /home



    if [ -f "$file_fstab001" ] && [ "$u_quota_uquota" != "uquota" ] && [ "$u_quota_home" = "/home" ]; then
        cp $file_fstab001 $file_fstab002
        sed -i 's/\/home                   xfs     defaults/\/home                   xfs     defaults,usrquota,nosuid/' $file_fstab001
        umount /home
        mount -o uquota /dev/mapper/cl-home /home
    fi






fi





