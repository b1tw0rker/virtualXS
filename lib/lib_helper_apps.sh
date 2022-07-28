#!/bin/bash

### /etc/fail2ban/
###
###
printf "\n\n***********************************************\n\nCopy helper apps to /etc/bitworker [y/n]: "
if [ "$u_helper_apps" = "" ]; then
  read u_helper_apps
fi

if [ "$u_helper_apps" = "y" ]; then

  file004=/etc/bitworker

  if [ ! -d "$file004" ]; then
    mkdir $file004
  fi

  cp $u_path/files/bitworker/bw-* $file004/

  chmod 700 $file004/bw*

  ln -s $file004/bw-show-jails.sh /bin/bw-show-jails.sh
  ln -s $file004/bw-unban-jails.sh /bin/bw-unban-jails.sh
  ln -s $file004/bw-import-mysql.sh /bin/bw-import-mysql.sh
  ln -s $file004/bw-list-zones.sh /bin/bw-list-zones.sh
  ln -s $file004/bw-multichange.sh /bin/bw-multichange.sh
  ln -s $file004/bw-createDkimKey.sh /bin/bw-createDkimKey.sh

fi
