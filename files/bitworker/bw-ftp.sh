#!/bin/bash

### Variablen
###
###
HOST='ftp://HOST'   # sftp as option possible
USER='XXX'
PASSWORD='XXX'

# DISTANT DIRECTORY
REMOTE_DIR='/htdocs/storage'

#LOCAL DIRECTORY
LOCAL_DIR='/tmp/storage'


### prework
###
###
if [ ! -d $LOCAL_DIR ]; then

  mkdir $LOCAL_DIR

fi




### Action
###
###
if [ -f /etc/firewall/reset.sh ]; then
 /etc/firewall/reset.sh
fi

if [ -d "$LOCAL_DIR" ]; then
 
lftp -u "$USER","$PASSWORD" $HOST <<EOF
# the next 3 lines put you in ftpes mode. Uncomment if you are having trouble connecting.
# set ftp:ssl-force true
# set ftp:ssl-protect-data true
# set ssl:verify-certificate no
# set sftp:auto-confirm yes
set ssl-allow no
mirror --use-pget-n=10 $REMOTE_DIR $LOCAL_DIR;
exit
EOF
echo
echo "Transfer finished"
date


fi

 

if [ -f /etc/firewall/rules.fw ]; then
  /etc/firewall/rules.fw
fi



### exit
###
###
exit 0