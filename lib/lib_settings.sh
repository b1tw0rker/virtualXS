#!/bin/bash

#printf "\n\n********************************************************************\n\nSet general settings like .exrc [y/N]: "

#if [ "$u_settings" = "" ]; then
#    read u_settings
#fi

if confirm "Set general settings like .exrc" "$u_settings"; then

    if [ -d "/root" ]; then
        cp $u_path/files/settings/.exrc /root/
    fi

fi

### Append root .bashrc additions
###
###
if confirm "Append root .bashrc additions (claude alias, chk-service)" "$u_bashrc_root"; then

    if grep -qF 'bw-chk-service' /root/.bashrc 2>/dev/null; then
        printf "[\e[33mINFO\e[0m] /root/.bashrc additions already present – skipping\n"
    else
        cat "$u_path/files/root/.bashrc" >> /root/.bashrc
        printf "[\e[32mOK\e[0m] /root/.bashrc updated\n"
    fi

fi

### Copy /root/.claude.json
###
###
if confirm "Copy .claude.json to /root/" "$u_claude_json"; then

    cp "$u_path/files/root/.claude.json" /root/.claude.json
    chmod 600 /root/.claude.json
    printf "[\e[32mOK\e[0m] /root/.claude.json installed\n"

fi
