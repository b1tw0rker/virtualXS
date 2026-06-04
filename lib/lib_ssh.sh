#!/bin/bash

### /etc/ssh/sshd_config
###
###
# Smart default: Y if BitWorker block not yet present, N if already configured
_ssh_default="n"
_ssh_prompt="[y/N]"
if grep -q "### by BitWorker" /etc/ssh/sshd_config 2>/dev/null; then
    _ssh_default="n"
    _ssh_prompt="[y/N]"
fi
printf "\n********************************************************************\n\n%d) Configure SSH-Server /etc/ssh/sshd_config %s: " "$(( ++_vxs_step ))" "$_ssh_prompt"
if [ "$u_ssh" = "" ]; then
        read u_ssh
        [ "$u_ssh" = "" ] && u_ssh="$_ssh_default"
fi

if [ "$u_ssh" = "y" ]; then
    printf "\n"

        file_ssh001=/etc/ssh/sshd_config
        file_ssh002=/etc/ssh/sshd_config.d/01-permitrootlogin.conf

        sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
        sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
        #sed -i 's/^#MaxAuthTries 6/MaxAuthTries 2/' $file_ssh001
        sed -i 's/^#UseDNS no/UseDNS no/' $file_ssh001

        if [ -f "$file_ssh002" ]; then
                if grep -Eq '^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]]+' "$file_ssh002"; then
                        sed -i -E 's|^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]]+.*$|PermitRootLogin no|' "$file_ssh002"
                else
                        printf '\nPermitRootLogin no\n' >>"$file_ssh002"
                fi
                _log ok "sshd permitrootlogin drop-in updated"
        else
                install -d -m 0755 /etc/ssh/sshd_config.d
                printf 'PermitRootLogin no\n' >"$file_ssh002"
                chmod 0644 "$file_ssh002"
                _log ok "sshd permitrootlogin drop-in created"
        fi

        ### grep BitWorker
        ###
        ###
        u_bitworker=$(grep -m 1 "### by BitWorker" /etc/ssh/sshd_config)

        ###
        ###
        ###
        if [ -f "$file_ssh001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
                cat $u_path/files/ssh/sshd_config >>$file_ssh001
                _log ok "sshd_config updated"
                #sed -i 's/^Match User root Address XXX/Match User root Address '"$u_client_ip"'/' $file_ssh001
        else
                _log info "sshd_config BitWorker block already present – skipped"
        fi


        if systemctl restart sshd; then
                _log ok "sshd restarted"
        else
                _log error "sshd restart failed"
        fi

fi
