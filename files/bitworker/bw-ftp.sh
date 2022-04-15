#!/bin/bash

### Variablen
###
###
HOST='ftp://srv002.host-x.de' # sftp as option possible - HOST-X uses ftp
USER='XXX'
PASSWORD='XXX'

### DESTINATION DIR
###
###
REMOTE_DIR='/htdocs' # no ending slash

### LOCAL DIR
###
###
LOCAL_DIR='/tmp/storage' # no ending shlash

### prework
###
###
if [ ! -d $LOCAL_DIR ]; then

  mkdir $LOCAL_DIR

fi

### Action
###
###
if [ -f /etc/firewall/stop.sh ]; then
  systemctl stop firewall
fi

if [ -d "$LOCAL_DIR" ]; then

  lftp -u "$USER","$PASSWORD" $HOST <<EOF
# the next 3 lines put you in ftpes mode. Uncomment if you are having trouble connecting.
# use it for HOST-X FTP Service. HOST-X only uses enryption
set ftp:ssl-force true
set ftp:ssl-protect-data true
set ssl:verify-certificate no
set sftp:auto-confirm yes
#set ssl-allow no
mirror --use-pget-n=10 $REMOTE_DIR $LOCAL_DIR;
exit
EOF
  echo
  echo "Transfer finished"
  date

fi

if [ -f /etc/firewall/rules.fw ]; then
  systemctl start firewall
fi

### exit
###
###
exit 0
