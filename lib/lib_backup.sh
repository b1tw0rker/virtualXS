#!/bin/bash

printf "\n********************************************************************\n\n%d) GIT Clone RSYNC backup script to: /etc/bitworker [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_backup" = "" ]; then
    read u_backup
fi

if [ "$u_backup" = "y" ]; then
    printf "\n"
    if ! git clone https://github.com/b1tw0rker/rsync.git /etc/bitworker/rsync/; then
        _log error "git clone failed"
    else
        chmod 700 /etc/bitworker/rsync/copyjob.sh

        backup_host_ip="$u_ip"
        if [[ "$u_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            last_octet="${u_ip##*.}"
            if (( last_octet < 255 )); then
                backup_host_ip="${u_ip%.*}.$((last_octet + 1))"
            else
                _log warn "backup host IP fallback in use, last octet of u_ip is already 255"
            fi
        else
            _log warn "backup host IP fallback in use, u_ip is not a plain IPv4 address"
        fi

        sed -i "s/^target=\"XXX\"/host=\"${backup_host_ip}\"/" /etc/bitworker/rsync/config.sh
        sed -i 's/^active="false"/active="true"/' /etc/bitworker/rsync/config.sh

        ### create cronjob in cron.daily
        ###
        ###
        if ! cp $u_path/files/backup/copyjobcron /etc/cron.daily/copyjob; then
            _log error "cp copyjobcron failed"
        else
            chmod 700 /etc/cron.daily/copyjob
            _log ok "backup cronjob installed"
        fi
    fi

fi
