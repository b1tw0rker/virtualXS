#!/bin/bash

### /MySQL/
###
###
printf "\n***********************************************\n\nConfigure MySQL (root-Passwort setzen, Backup-Script installieren) [y/N]: "
if [ "$u_mysql" = "" ]; then
  read u_mysql
fi

if [ "$u_mysql" = "y" ]; then

  file_mysql001=/etc/bitworker

  if [ ! -d "$file_mysql001" ]; then
    mkdir $file_mysql001
  fi

  cp $u_path/files/bitworker/bw-mysql-dump.sh $file_mysql001
  chmod 700 $file_mysql001/bw-mysql-dump.sh

  ### Set root Pass ( https://www.dogado.de/faq/artikel/mysql-root-passwort-neu-setzen/ )
  ###
  ###
  mysqladmin -u root password $u_mysql_pwd >>/dev/null 2>&1
  sed -i 's/^MYSQL_PASSWORD=XXX/MYSQL_PASSWORD='"$u_mysql_pwd"'/' $file_mysql001/bw-mysql-dump.sh

fi
