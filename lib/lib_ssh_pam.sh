#!/bin/bash

### /etc/pam.d/sshd
###
###
printf "\n********************************************************************\n\n%d) Configure PAM for SSHD [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_ssh_pam" = "" ]; then
    read u_ssh_pam
fi

if [ "$u_ssh_pam" = "y" ]; then
    printf "\n"

    file_ssh_pam001=/etc/pam.d/sshd
    file_ssh_pam002=/etc/bitworker/bw-sshd-pam-userlogin-check.sh

    if [ ! -f "$file_ssh_pam002" ]; then
        _log error "Missing helper script: $file_ssh_pam002"
        _log warn "Run helper-apps first so files/bitworker is copied to /etc/bitworker"
        return 1
    fi

    if [ -f "$file_ssh_pam001" ]; then
        cp "$file_ssh_pam001" "$file_ssh_pam001.bak"
        _log ok "PAM backup created: $file_ssh_pam001.bak"
        cat "$u_path/files/ssh/pam_sshd" >"$file_ssh_pam001"
        _log ok "sshd PAM config updated"
    else
        _log error "Missing PAM target file: $file_ssh_pam001"
        return 1
    fi

    if systemctl restart sshd; then
        _log ok "sshd restarted"
    else
        _log error "sshd restart failed"
    fi
fi