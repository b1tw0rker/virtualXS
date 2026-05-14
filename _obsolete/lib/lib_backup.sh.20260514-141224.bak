#!/bin/bash

printf "\n********************************************************************\n\nGIT Clone RSYNC backup script to: /etc/bitworker [y/N]: "
if [ "$u_backup" = "" ]; then
    read u_backup
fi

if [ "$u_backup" = "y" ]; then

    git clone https://github.com/b1tw0rker/rsync.git /etc/bitworker/rsync/
    chmod 700 /etc/bitworker/rsync/copyjob.sh

    sed -i 's/^target="XXX"/host="srv011.bit-worker.com"/' /etc/bitworker/rsync/copyjob.sh
    sed -i 's/^active="false"/active="true"/' /etc/bitworker/rsync/copyjob.sh

    ### create cronjob in cron.daily
    ###
    ###
    cp $u_path/files/backup/copyjobcron /etc/cron.daily/copyjob
    chmod 700 /etc/cron.daily/copyjob
    printf "[\e[32mOK\e[0m]\n"

fi
