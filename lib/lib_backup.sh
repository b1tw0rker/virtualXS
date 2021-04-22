#!/bin/bash



if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nCreate Backupscript [y/n]: "
    if [ "$u_backup" = "" ]; then
        read u_backup
    fi

else 
    u_backup=y
fi



if [ "$u_backup" = "y" ]; then

    cp $u_path/files/backup/backup.sh /etc/bitworker/
    cp $u_path/files/backup/rsynclist.txt /etc/bitworker/
    chmod 700 /etc/bitworker/backup.sh

    #create cronjob
    cp $u_path/files/backup/copyjobcron /etc/cron.daily/copyjob
    chmod 700 /etc/cron.daily/copyjob
    
    ## ACHTUNG: das backup.sh script muss noch active gestellt werden - var active = true

fi






