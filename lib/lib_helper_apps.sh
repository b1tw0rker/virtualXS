#!/bin/bash

### /etc/bitworker/
###
###
printf "\n********************************************************************\n\nCopy helper apps to /etc/bitworker [y/N]: "
if [ "$u_helper_apps" = "" ]; then
    read u_helper_apps
fi

if [ "$u_helper_apps" = "y" ]; then
    
    file004=/etc/bitworker
    
    if [ ! -d "$file004" ]; then
        mkdir $file004
    fi
    
    ###
    ###
    ###
    cp $u_path/files/bitworker/bw-* $file004/

    ###
    ###
    ###
    for helper_file in $file004/bw-*.sh; do
        if [ -f "$helper_file" ]; then
            chmod 700 "$helper_file"
        fi
    done

    for helper_file in $file004/bw-*.cfg; do
        if [ -f "$helper_file" ]; then
            chmod 644 "$helper_file"
        fi
    done

    ###
    ###
    ###
    for helper_file in $file004/bw-*.sh; do
        if [ -f "$helper_file" ]; then
            helper_name=$(basename "$helper_file" .sh)
            ln -sf "$helper_file" "/bin/$helper_name"
        fi
    done
    printf "\e[32mSuccess\e[0m\n"
fi
