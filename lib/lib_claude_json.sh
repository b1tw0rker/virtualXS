#!/bin/bash

### Copy /root/.claude.json
###
###
printf "\n********************************************************************\n\n"
if confirm "$(( ++_vxs_step ))) Copy .claude.json to /root/" "$u_claude_json"; then

    if [[ -f /root/.claude.json ]]; then
        _log info "/root/.claude.json already exists, skipping"
    else
        cp "$u_path/files/root/.claude.json" /root/.claude.json
        chmod 600 /root/.claude.json
        _log ok "/root/.claude.json installed"
    fi

fi