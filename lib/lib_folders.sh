#!/bin/bash

# Smart default: Y if at least one folder is missing, N if all already exist
_vxf_default="n"
_vxf_prompt="[y/N]"
_vxf_all_exist=true
for _vxf in /home/httpd /home/pop /home/mysql /etc/bitworker /var/log/rsync /etc/httpd/virtualx.d; do
  [ -d "$_vxf" ] || { _vxf_all_exist=false; break; }
done
if [ "$_vxf_all_exist" = "true" ]; then
  _vxf_default="n"
  _vxf_prompt="[y/N]"
fi

printf "\n********************************************************************\n\n%d) Create virtualx standard folders (/home/httpd, /home/pop, /home/mysql, /etc/bitworker, /var/log/rsync, /etc/httpd/virtualx.d) %s: " "$(( ++_vxs_step ))" "$_vxf_prompt"
if [ "$u_folders_create" = "" ]; then
  read u_folders_create
  [ "$u_folders_create" = "" ] && u_folders_create="$_vxf_default"
fi

if [ "$u_folders_create" = "y" ]; then

  folders=(
    /home/httpd
    /home/pop
    /home/mysql
    /etc/bitworker
    /var/log/rsync
    /var/virtualx
    /var/virtualx/backups
    /var/virtualx/apps
    /var/virtualx/db
    /var/virtualx/log
    /var/virtualx/skelmail
    /var/virtualx/skel
    /etc/httpd/virtualx.d
  )

  for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
      _log info "$folder already exists"
    else
      mkdir "$folder"

      if [ "$folder" = "/home/pop" ]; then
        chmod 777 "$folder"
      fi

      if [ -d "$folder" ]; then
        _log ok "created $folder successfully"
      else
        _log error "could not create $folder"
      fi
    fi
  done

  ### Copy certbot-apache TLS options to letsencrypt config dir
  ###
  ###
  if [ -f /usr/lib/python3.12/site-packages/certbot_apache/_internal/tls_configs/current-options-ssl-apache.conf ]; then
    if [ -f /etc/letsencrypt/options-ssl-apache.conf ]; then
      _log info "/etc/letsencrypt/options-ssl-apache.conf already exists"
    else
      cp /usr/lib/python3.12/site-packages/certbot_apache/_internal/tls_configs/current-options-ssl-apache.conf /etc/letsencrypt/options-ssl-apache.conf
      if [ -f /etc/letsencrypt/options-ssl-apache.conf ]; then
        _log ok "copy /etc/letsencrypt/options-ssl-apache.conf success"
      else
        _log error "could not copy options-ssl-apache.conf"
      fi
    fi
  fi

fi
