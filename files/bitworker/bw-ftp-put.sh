#!/bin/bash

### Variablen
###
###
IPTABLES="/usr/sbin/iptables"
HOST='vh4015.1blu.de'
USR='u317356'
PASS='dd(dhHW!223hZuT'
REMOTE_DIR='/'                     # no ending slash
LOCAL_FILE='/tmp/storage/boot.iso' # no ending slash

### Check if firewall is active
###
###
if [[ $(systemctl status firewall | grep 'active (exited)') ]]; then
    ftprule='true'
    
    #http://www.devops-blog.net/iptables/iptables-settings-for-outgoing-ftp
    $IPTABLES -A OUTPUT -p tcp --dport 21 -d $HOST -m state --state NEW,ESTABLISHED -j ACCEPT
    $IPTABLES -A OUTPUT -p tcp --dport 20 -d $HOST -m state --state ESTABLISHED -j ACCEPT
    $IPTABLES -A OUTPUT -p tcp --sport 1024: --dport 1024: -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
    
fi

### Action
### add no cert check to permanent to config file -> echo "set ssl:verify-certificate no" >> ~/.lftp/rc
### oder in /etc/lftp.conf -> set ssl:verify-certificate no
### ChatGPT Prompt: wie setze ich in /etc/lftp.conf diese Eigenschaft: ssl:verify-certificate no

### Alternativer Befehl mit Verschlüsselgun aber ohne sll-verification
### lftp -c "set ssl:verify-certificate no ; open -u $USR,$PASS $HOST ; put -O $REMOTE_DIR $LOCAL_FILE ; quit"
###
###
lftp -c "set ftp:ssl-allow no ; open -u $USR,$PASS $HOST ; put -O $REMOTE_DIR $LOCAL_FILE ; quit"

### exit
###
###
exit 0
