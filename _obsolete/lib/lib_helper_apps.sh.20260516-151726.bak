#!/bin/bash

### /etc/bitworker/
###
###
printf "\n********************************************************************\n\nCopy helper-apps to /etc/bitworker [y/N]: "
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
    if ! cp $u_path/files/bitworker/bw-* $file004/; then
        printf "[\e[31mERROR\e[0m] cp failed: %s → %s\n" "$u_path/files/bitworker/bw-*" "$file004/"
    else

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
        printf "[\e[32mOK\e[0m] helper scripts linked\n"
    fi
fi

### Install chk-service (/opt/chk-service)
###
### Required for the .bashrc entry: /opt/chk-service/bw-chk-service.sh dev
###
printf "\n********************************************************************\n\n"
if confirm "Install chk-service from GitHub" "$u_chk_service"; then

    if [ -d "/opt/chk-service" ]; then
        printf "[\e[36mINFO\e[0m] /opt/chk-service already exists – pulling latest changes\n"
        git -C /opt/chk-service pull
    else
        git clone https://github.com/b1tw0rker/chk-service /opt/chk-service
    fi

    if [ -f "/opt/chk-service/bw-chk-service.sh" ]; then
        chmod 700 /opt/chk-service/bw-chk-service.sh
        printf "[\e[32mOK\e[0m] chk-service installed at /opt/chk-service\n"
    else
        printf "[\e[31mERROR\e[0m] bw-chk-service.sh not found after clone\n"
    fi

fi
