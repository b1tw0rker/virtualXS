#!/bin/bash

### Append root .bashrc additions
###
###
printf "\n********************************************************************\n\n"
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
printf "\n********************************************************************\n\n"
if confirm "Copy .claude.json to /root/" "$u_claude_json"; then

    cp "$u_path/files/root/.claude.json" /root/.claude.json
    chmod 600 /root/.claude.json
    printf "[\e[32mOK\e[0m] /root/.claude.json installed\n"

fi
