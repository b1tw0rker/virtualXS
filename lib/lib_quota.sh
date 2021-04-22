#!/bin/bash

### https://www.server-world.info/en/note?os=CentOS_8&p=diskquota
### https://www.golinuxcloud.com/configure-enable-disable-xfs-quota-grace-time/

file_fstab001=/etc/fstab


### q quota
###
###
if [ "$u_quota" != "y" ]; then
    printf "\n***********************************************\n\nSet Quota [y/n]: "
    if [ "$u_quota" = "" ]; then
        read u_quota
    fi

else 
 u_quota=y
fi


if [ "$u_quota" = "y" ]; then

    ### check if uquota ia allready setted
    ### grep uquota
    ###
    u_uquota=$(grep -m 1 "uquota" /etc/fstab)


    if [ -f "$file_fstab001" ] && [ "$u_uquota" != "uquota" ]; then
        sed -i 's/\/home                   xfs     defaults/\/home                   xfs     defaults,uquota/' $file_fstab001

        umount /home
        mount -o uquota /dev/mapper/cl-home /home
    fi


fi





