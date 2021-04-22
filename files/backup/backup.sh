#!/bin/bash

file="/etc/bitworker/rsynclist.txt"
target="srv002.bit-worker.com"
active="false"

#!/bin/bash

if [ ! -f "$file" ]; then
   exit
fi



for i in `cat $file`; do

   # chomp - the bash way :-)
   i="${i//$'\r'/$'\n'}"

 if [ -e $i ]; then
   folder="$folder $i"
 fi
done



#echo $folder

if [ "$active" = "true" ]; then
  rsync -avz --delete $folder $target:/backup/
fi


exit 0
