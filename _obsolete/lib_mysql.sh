#!/bin/bash

### /MySQL/
###
###
printf "\n********************************************************************\n\nConfigure MySQL (set root password) [y/N]: "
if [ "$u_mysql" = "" ]; then
  read u_mysql
fi

if [ "$u_mysql" = "y" ]; then

  ### Set root Pass ( https://www.dogado.de/faq/artikel/mysql-root-passwort-neu-setzen/ )
  ###
  ###
  mysql_pwd=$(grep '^password=' /root/.my.cnf | cut -d'=' -f2-)
  mysqladmin -u root password "$mysql_pwd" >>/dev/null 2>&1
  unset mysql_pwd

  ### Ensure backup script is executable (deployed by helper_apps)
  ###
  if [ -f /etc/bitworker/bw-mysql-dump.sh ]; then
    chmod 700 /etc/bitworker/bw-mysql-dump.sh
  fi

  printf "[\e[32mOK\e[0m]\n"

fi
