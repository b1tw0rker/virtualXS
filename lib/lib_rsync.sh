#!/bin/bash



### /rsync/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure rsync [y/n]: "
    if [ "$u_rsync" = "" ]; then
        read u_rsync
    fi

else 
    u_rsync=y
fi




if [ "$u_rsync" = "y" ]; then

printf "RSYNC TODO\n"

fi




