#!/bin/bash

### /etc/bitworker/
###
###
printf "\n********************************************************************\n\n%d) Copy helper-apps to /etc/bitworker [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_helper_apps" = "" ]; then
    read u_helper_apps
fi

if [ "$u_helper_apps" = "y" ]; then
    printf "\n"
    file004=/etc/bitworker
    
    if [ ! -d "$file004" ]; then
        mkdir $file004
    fi
    
    ###
    ###
    ###
    if ! cp $u_path/files/bitworker/bw-* $file004/; then
        _log error "cp failed: $u_path/files/bitworker/bw-* → $file004/"
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
        _log ok "helper scripts linked"

        if [ -d "$u_path/files/bitworker/borg" ]; then
            if ! cp -a "$u_path/files/bitworker/borg" "$file004/"; then
                _log error "cp failed: $u_path/files/bitworker/borg -> $file004/"
            else
                for helper_file in "$file004"/borg/*.sh; do
                    if [ -f "$helper_file" ]; then
                        chmod 700 "$helper_file"
                    fi
                done
                _log ok "borg helper scripts copied"
            fi
        fi

        printf "\n********************************************************************\n\n%d) borg konfigurieren? [y/N]: " "$(( ++_vxs_step ))"
        if [ "$u_borg_configure" = "" ]; then
            read -r u_borg_configure
        else
            printf "%s\n" "$u_borg_configure"
        fi

        case "${u_borg_configure,,}" in
            y|yes|j|ja)
                read -p "IP von der gepullt werden soll: " -ei "$u_borg_pull_ip" u_borg_pull_ip
                ;;
        esac
    fi
fi

### Install chk-service (/opt/chk-service)
###
### Required for the .bashrc entry: /opt/chk-service/bw-chk-service.sh dev
###
printf "\n********************************************************************\n\n"
if confirm "$(( ++_vxs_step ))) Install chk-service from GitHub" "$u_chk_service"; then

    if [ -d "/opt/chk-service" ]; then
        _log info "/opt/chk-service already exists – pulling latest changes"
        git -C /opt/chk-service pull
    else
        git clone https://github.com/b1tw0rker/chk-service /opt/chk-service
    fi

    if [ -f "/opt/chk-service/bw-chk-service.sh" ]; then
        chmod 700 /opt/chk-service/bw-chk-service.sh

        cat > /opt/chk-service/bw-chk-service.cfg <<'EOF'
mysqld
sshd
httpd
postfix
vsftpd
dovecot
spamassassin
fail2ban
firewall
EOF
        chmod 644 /opt/chk-service/bw-chk-service.cfg

        _log ok "chk-service installed at /opt/chk-service"
    else
        _log error "bw-chk-service.sh not found after clone"
    fi

fi
