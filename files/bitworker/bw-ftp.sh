#!/bin/bash

### version 1.0.1
### 17.05.2022
###

### Choose App (ncftpget, lftp)
### ncftpget has no SSL support!
###
APP='lftp'

### Variablen
###
###
HOST='XXX'
REMOTE_USR='XXX'
LOCAL_USR='XXX'
PASS='XXX'

### DESTINATION DIR
###
###
REMOTE_DIR='/htdocs' # no ending shlash

### LOCAL DIR
###
###
#LOCAL_DIR='/tmp/storage' # no ending shlash
LOCAL_DIR="/home/httpd/www.$LOCAL_USR/htdocs" # no ending shlash

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

    lftp -c 'set ftp:ssl-force true ; set ftp:ssl-allow true ; set ssl:verify-certificate no; set ftp:list-options -a ; open -u '$REMOTE_USR','$PASS' -e "mirror -c --parallel=20 '$REMOTE_DIR' '$LOCAL_DIR' ; quit" '$HOST''
    #lftp -c 'set ftp:ssl-force true ; set ftp:ssl-allow true ; set ssl:verify-certificate no; open -u '$REMOTE_USR','$PASS' -e "mirror -c --parallel=20 --ignore-time --ignore-size --transfer-all '$REMOTE_DIR' '$LOCAL_DIR' ; quit" '$HOST''

    echo
    echo "Transfer finished"
    date
    echo ""

    ### check for /WEBSTATS
    ###
    ###
    if [ -d "$LOCAL_DIR/WEBSTATS2" ]; then
      mv $LOCAL_DIR/WEBSTATS2 $LOCAL_DIR/WEBSTATS
    fi

    if [ ! -f "$LOCAL_DIR/WEBSTATS/.htaccess.virtualx" ]; then
      touch $LOCAL_DIR/WEBSTATS/.htaccess.virtualx
    fi

    ### set chown
    ###
    ###
    chown -R $LOCAL_USR:users $LOCAL_DIR

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

### Check for .sql.gz file
###
###
TMP="${LOCAL_USR//[.-]/_}"
DBNAME="${TMP}_1"
DBZIP="${DBNAME}.sql.gz"

if [ -f "$LOCAL_DIR/$DBZIP" ]; then

  echo "Unzipping and importing Database"
  echo ""
  gunzip $LOCAL_DIR/$DBZIP

  mysql -u root -pG0lden_12 $DB <$LOCAL_DIR/${DBNAME}.sql

  #rm -f $LOCAL_DIR/${DBNAME}.sql

fi

### exit
###
###
exit 0
