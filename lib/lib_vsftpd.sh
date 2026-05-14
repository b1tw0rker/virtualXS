#!/bin/bash

### /etc/vsftpd/
###
###
printf "\n********************************************************************\n\nConfigure Vsftpd [y/N]: "
if [ "$u_vsftpd" = "" ]; then
    read u_vsftpd
fi

#else
#    u_vsftpd=y
#fi

if [ "$u_vsftpd" = "y" ]; then

    useradd -d /dev/null -s /sbin/nologin -g users vsftpd >>/dev/null 2>&1

    # /sbin/nologin must be in /etc/shells for vsftpd's internal shell check
    grep -qxF '/sbin/nologin'     /etc/shells || echo '/sbin/nologin'     >> /etc/shells
    grep -qxF '/usr/sbin/nologin' /etc/shells || echo '/usr/sbin/nologin' >> /etc/shells

    file_vsftpd001=/etc/vsftpd/vsftpd_user_conf
    file_vsftpd002=/etc/vsftpd/vsftpd.conf
    file_vsftpd003=/etc/pam.d/vsftpd
    file_vsftpd004=/etc/letsencrypt/live/$u_hostname/fullchain.pem

    set_vsftpd_option() {
        local key="$1"
        local value="$2"

        sed -i '/^#\?'"$key"'=.*/d' "$file_vsftpd002"
        printf '%s=%s\n' "$key" "$value" >>"$file_vsftpd002"
    }

    sed -i 's/^#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to HOST-X FTP service./' "$file_vsftpd002"
    sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' "$file_vsftpd002"

    if [ ! -d "$file_vsftpd001" ]; then
        mkdir $file_vsftpd001
    fi

    ### grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/vsftpd/vsftpd.conf)

    if [ -f "$file_vsftpd002" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/vsftpd/vsftpd.conf >>$file_vsftpd002
    fi

    set_vsftpd_option listen YES
    set_vsftpd_option listen_ipv6 NO
    set_vsftpd_option anonymous_enable NO
    set_vsftpd_option local_enable YES
    set_vsftpd_option write_enable YES
    set_vsftpd_option userlist_enable YES
    set_vsftpd_option pam_service_name vsftpd
    set_vsftpd_option ssl_enable YES
    set_vsftpd_option allow_anon_ssl NO
    set_vsftpd_option force_local_data_ssl YES
    set_vsftpd_option force_local_logins_ssl YES
    set_vsftpd_option ssl_tlsv1_1 YES
    set_vsftpd_option ssl_tlsv1_2 YES
    set_vsftpd_option ssl_tlsv1 NO
    set_vsftpd_option ssl_sslv2 NO
    set_vsftpd_option ssl_sslv3 NO
    set_vsftpd_option require_ssl_reuse NO
    set_vsftpd_option ssl_ciphers HIGH
    set_vsftpd_option allow_writeable_chroot YES
    set_vsftpd_option nopriv_user vsftpd
    set_vsftpd_option userlist_deny YES
    set_vsftpd_option guest_enable YES
    set_vsftpd_option guest_username vsftpd
    set_vsftpd_option local_root '/home/httpd/$USER'
    set_vsftpd_option user_sub_token '$USER'
    set_vsftpd_option virtual_use_local_privs YES
    set_vsftpd_option user_config_dir /etc/vsftpd/vsftpd_user_conf

    ### pam_exec script + PAM config
    ###
    ###
    if [ -f "$file_vsftpd003" ]; then
        cat "$u_path/files/vsftpd/pam_vsftpd" >"$file_vsftpd003"
        install -m 700 -o root -g root \
            "$u_path/files/vsftpd/vsftpd-pam-check.sh" \
            /usr/local/sbin/vsftpd-pam-check.sh

        ### MySQL credentials file for PAM script (etc_t context, readable by ftpd_t)
        mysql_pwd=$(grep '^password=' /root/.my.cnf 2>/dev/null | cut -d= -f2-)
        printf '[client]\nuser=root\npassword=%s\nhost=localhost\n' "$mysql_pwd" \
            > /etc/vsftpd/mysql-pam.cnf
        chmod 600 /etc/vsftpd/mysql-pam.cnf
        chown root:root /etc/vsftpd/mysql-pam.cnf
    fi

    ### Cert stuff
    ###
    ###
    if [ -f "$file_vsftpd004" ]; then
        sed -i \
            -e "s|^#\?rsa_cert_file=.*|rsa_cert_file=/etc/letsencrypt/live/${u_hostname}/fullchain.pem|" \
            -e "s|^#\?rsa_private_key_file=.*|rsa_private_key_file=/etc/letsencrypt/live/${u_hostname}/privkey.pem|" \
            "$file_vsftpd002"
        printf "[\e[32mOK\e[0m] SSL cert aktiviert: /etc/letsencrypt/live/${u_hostname}/\n"
    else
        printf "[\e[33mWARN\e[0m] SSL cert nicht gefunden – rsa_cert_file bleibt auskommentiert\n"
    fi

    ### Start or restart vsftpd
    if systemctl is-active --quiet vsftpd; then
        systemctl restart vsftpd
        printf "[\e[32mOK\e[0m] Vsftpd restarted\n"
    else
        systemctl enable --now vsftpd
        printf "[\e[32mOK\e[0m] Vsftpd gestartet\n"
    fi

fi
