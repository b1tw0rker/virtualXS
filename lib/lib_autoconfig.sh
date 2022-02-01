#!/bin/bash

file001=/etc/httpd/conf.d/

printf "\n\n***********************************************\n\nCopy Autoconfig to  /etc/httpd/conf.d/ [y/n]: "
if [ "$u_autoconfig" = "" ]; then
    read u_autoconfig
fi

if [ "$u_autoconfig" = "y" ]; then

    if [ -d "$file001" ]; then

        cp $u_path/files/autoconfig/autoconfig.html $file001/

    fi

fi
