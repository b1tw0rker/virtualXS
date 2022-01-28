#!/bin/bash

### Variablen
###
###
ftpuser=XXX
pass=XXX
host=XXX
local_dir=/home/httpd/www.domainname.de/htdocs
remote_dir=/htdocs


### prework
###
###
if [ ! -d $local_dir ]; then

  mkdir $local_dir

fi




### Action
###
###
if [ -f /etc/firewall/reset.sh ]; then
 /etc/firewall/reset.sh
fi

if [ -d "$local_dir" ]; then
 ncftpget -T -R -v -u "$ftpuser" $host $local_dir $remote_dir
fi

## test password problematik
#ncftpget -u $ftpuser -p $pass -T -R -v $host $local_dir $remote_dir

if [ -f /etc/firewall/rules.fw ]; then
  /etc/firewall/rules.fw
fi



### exit
###
###
exit 0