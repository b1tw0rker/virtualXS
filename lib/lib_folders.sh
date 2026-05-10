#!/bin/bash

printf "\n********************************************************************\n\nCreate virtualx standard folders (/home/httpd, /home/pop, /home/mysql, /etc/bitworker, /var/log/rsync, /etc/httpd/virtualx.d) [y/N]: "
if [ "$u_folders_create" = "" ]; then
  read u_folders_create
fi

if [ "$u_folders_create" = "y" ]; then

  folders=(
    /home/httpd
    /home/pop
    /home/mysql
    /etc/bitworker
    /var/log/rsync
    /etc/httpd/virtualx.d
  )

  for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
      mkdir "$folder"

      if [ "$folder" = "/home/pop" ]; then
        chmod 777 "$folder"
      fi
    fi
  done

  printf "[\e[32mOK\e[0m]\n"

fi
