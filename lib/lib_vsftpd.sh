#!/bin/bash

### /etc/vsftpd/
###
###
printf "\n********************************************************************\n\nConfigure Vsftpd [y/N]: "
if [ "$u_vsftpd" = "" ]; then
    read u_vsftpd
fi



if [ "$u_vsftpd" = "y" ]; then

    file_vsftpd001=/etc/vsftpd/vsftpd_user_conf
    file_vsftpd002=/etc/vsftpd/vsftpd.conf
    file_vsftpd003=/etc/pam.d/vsftpd
    file_vsftpd004=/etc/letsencrypt/live/$u_srv/fullchain.pem
    file_vsftpd007=/etc/bitworker/bw-vsftpd-pam-userlogin-check.sh

    if [ ! -f "$file_vsftpd007" ]; then
        printf "[\e[31mERROR\e[0m] Missing helper script: %s\n" "$file_vsftpd007"
        printf "[\e[33mWARN\e[0m] Run helper-apps first so files/bitworker is copied to /etc/bitworker\n"
        return 1
    fi

    useradd -d /dev/null -s /sbin/nologin -g users vsftpd >>/dev/null 2>&1

    # /sbin/nologin must be in /etc/shells for vsftpd's internal shell check
    grep -qxF '/sbin/nologin'     /etc/shells || echo '/sbin/nologin'     >> /etc/shells
    grep -qxF '/usr/sbin/nologin' /etc/shells || echo '/usr/sbin/nologin' >> /etc/shells

    if [ ! -d "$file_vsftpd001" ]; then
        mkdir "$file_vsftpd001"
    fi

    # One-time backup of the original vsftpd.conf
    if [ -f "$file_vsftpd002" ] && [ ! -f /etc/vsftpd/vsftpd.orig ]; then
        cp "$file_vsftpd002" /etc/vsftpd/vsftpd.orig
        printf "[\e[32mOK\e[0m] Original gesichert: /etc/vsftpd/vsftpd.orig\n"
    fi

    cat "$u_path/files/vsftpd/vsftpd.conf" >"$file_vsftpd002"

    ### pam_exec script + PAM config
    ###
    ###
    if [ -f "$file_vsftpd003" ]; then
        cat "$u_path/files/vsftpd/pam_vsftpd" >"$file_vsftpd003"
    fi

    ### Cert stuff
    ###
    ###
    if [ -f "$file_vsftpd004" ]; then
        sed -i \
            -e "s|^#\?rsa_cert_file=.*|rsa_cert_file=/etc/letsencrypt/live/${u_srv}/fullchain.pem|" \
            -e "s|^#\?rsa_private_key_file=.*|rsa_private_key_file=/etc/letsencrypt/live/${u_srv}/privkey.pem|" \
            "$file_vsftpd002"
        printf "[\e[32mOK\e[0m] SSL cert aktiviert: /etc/letsencrypt/live/${u_srv}/\n"
    else
        printf "[\e[33mWARN\e[0m] SSL cert nicht gefunden – rsa_cert_file bleibt auskommentiert\n"
    fi

    ### Start or restart vsftpd
    if systemctl is-active --quiet vsftpd; then
        if systemctl restart vsftpd; then
            printf "[\e[32mOK\e[0m] Vsftpd restarted\n"
        else
            printf "[\e[31mERROR\e[0m] Vsftpd restart failed – check: journalctl -xeu vsftpd.service\n"
        fi
    else
        if systemctl enable --now vsftpd; then
            printf "[\e[32mOK\e[0m] Vsftpd gestartet\n"
        else
            printf "[\e[31mERROR\e[0m] Vsftpd start failed – check: journalctl -xeu vsftpd.service\n"
        fi
    fi

fi
