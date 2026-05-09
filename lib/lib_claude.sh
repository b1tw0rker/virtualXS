#!/bin/bash

### Install Claude settings and API files
###
###
printf "\n********************************************************************\n\nInstall Claude settings and API files [y/N]: "
if [ "$u_claude" = "" ]; then
    read u_claude
fi

if [ "$u_claude" = "y" ]; then

    claude_src=$u_path/files/claude
    claude_dst=$HOME

    # copy .claude.json
    if [ -f "$claude_src/.claude.json" ]; then
        cp "$claude_src/.claude.json" "$claude_dst/.claude.json"
        chmod 600 "$claude_dst/.claude.json"
        printf "  [OK] .claude.json installed\n"
    else
        printf "  [SKIP] .claude.json not found in $claude_src\n"
    fi

    # copy .claude/ settings directory
    if [ -d "$claude_src/.claude" ]; then
        cp -r "$claude_src/.claude" "$claude_dst/"
        chmod 700 "$claude_dst/.claude"
        printf "  [OK] .claude/ settings directory installed\n"
    else
        printf "  [SKIP] .claude/ directory not found in $claude_src\n"
    fi

fi
