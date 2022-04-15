#!/bin/bash

### Choose App (ncftpget, lftp)
### ncftpget has no SSL support!
###
APP='lftp'

### Variablen
###
###
HOST='XXX'
USR='XXX'
PASS='XXX'

### DESTINATION DIR
###
###
REMOTE_DIR='/htdocs' # no ending shlash

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

### Check if firewall is active
###
###
if [[ $(systemctl status firewall | grep 'active (exited)') ]]; then
  ftprule='true'

  iptables -A OUTPUT -p tcp -m tcp -d $HOST --dport 21 -m state --state NEW -j ACCEPT
  iptables -A OUTPUT -p tcp -m tcp -d $HOST --dport 10000:11000 -m state --state NEW -j ACCEPT
fi

### Action
###
###

if [ -d "$LOCAL_DIR" ]; then

  if [ "$APP" == "lftp" ]; then

    lftp -c 'set ftp:ssl-force true ; set ftp:ssl-allow true ; set ssl:verify-certificate no; open -u '$USR','$PASS' -e "mirror -c --parallel=20 --ignore-time --ignore-size --transfer-all '$REMOTE_DIR' '$LOCAL_DIR' ; quit" '$HOST''

    echo
    echo "Transfer finished"
    date
    echo ""

  else
    ncftpget -T -R -v -u "$USR" -p $PASS $HOST $LOCAL_DIR $REMOTE_DIR
  fi

fi

if [ "$ftprule" == "true" ]; then
  iptables -D OUTPUT -p tcp -m tcp -d $HOST --dport 21 -m state --state NEW -j ACCEPT
  iptables -D OUTPUT -p tcp -m tcp -d $HOST --dport 10000:11000 -m state --state NEW -j ACCEPT

  systemctl restart firewall

  echo "Firewall restarted"
  echo ""
fi

### exit
###
###
exit 0
