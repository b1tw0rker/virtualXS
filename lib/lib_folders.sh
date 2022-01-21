#!/bin/bash



printf "\n\n***********************************************\n\nCreate standard folders [y/n]: "
if [ "$u_folders_create" = "" ]; then
    read u_folders_create
fi




if [ "$u_folders_create" = "y" ]; then

    file001=/home/httpd
    file002=/home/pop
    file003=/home/mysql
    file004=/etc/bitworker
    file005=/root/.ssh
    file006=/var/log/rsync

    if [ ! -d "$file001" ]; then
      mkdir $file001
    fi

    if [ ! -d "$file002" ]; then
      mkdir $file002
      chmod 777 $file002
    fi

    if [ ! -d "$file003" ]; then
      mkdir $file003
    fi

    if [ ! -d "$file004" ]; then
      mkdir $file004
    fi
    

    if [ ! -d "$file005" ]; then
      mkdir $file005
    fi

    if [ ! -d "$file006" ]; then
      mkdir $file006
    fi


fi 

