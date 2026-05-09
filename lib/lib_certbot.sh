#!/bin/bash

certbot_dns_hook_dir=/etc/letsencrypt/hooks
certbot_dns_config_dir=/etc/letsencrypt/config
certbot_dns_auth_hook=$certbot_dns_hook_dir/auto-hook.sh
certbot_dns_cleanup_hook=$certbot_dns_hook_dir/cleanup-hook.sh
certbot_dns_config_file=$certbot_dns_config_dir/dns-config.conf

certbot_dns_prepare() {

    if [ ! -d "$certbot_dns_hook_dir" ]; then
        mkdir -p "$certbot_dns_hook_dir"
    fi

    if [ ! -d "$certbot_dns_config_dir" ]; then
        mkdir -p "$certbot_dns_config_dir"
    fi

    cp "$u_path/files/certbot/certbot-renew" /etc/cron.weekly/certbot-renew
    chmod 700 /etc/cron.weekly/certbot-renew

    cp "$u_path/files/certbot/hooks/auto-hook.sh" "$certbot_dns_auth_hook"
    cp "$u_path/files/certbot/hooks/cleanup-hook.sh" "$certbot_dns_cleanup_hook"
    cp "$u_path/files/certbot/config/dns-config.conf" "$certbot_dns_config_file"

    chmod 700 "$certbot_dns_auth_hook"
    chmod 700 "$certbot_dns_cleanup_hook"
    chmod 600 "$certbot_dns_config_file"
}

certbot_dns_issue() {
    certbot_domain=$1
    certbot_email=""
    certbot_agree_tos="--agree-tos"
    certbot_staging_flag=""
    certbot_cmd=()

    if [ -f "$certbot_dns_config_file" ]; then
        # shellcheck disable=SC1090
        source "$certbot_dns_config_file"
        certbot_email="$EMAIL"
        certbot_agree_tos="$AGREE_TOS"

        if [ "$STAGING_MODE" = "true" ]; then
            certbot_staging_flag="--staging"
        fi
    fi

    certbot_cmd=(
        certbot certonly
        --manual
        --preferred-challenges dns
        --manual-auth-hook "$certbot_dns_auth_hook"
        --manual-cleanup-hook "$certbot_dns_cleanup_hook"
        --non-interactive
    )

    if [ "$certbot_agree_tos" != "" ]; then
        certbot_cmd+=("$certbot_agree_tos")
    fi

    if [ "$certbot_email" != "" ]; then
        certbot_cmd+=(--email "$certbot_email")
    fi

    if [ "$certbot_staging_flag" != "" ]; then
        certbot_cmd+=("$certbot_staging_flag")
    fi

    certbot_cmd+=(-d "$certbot_domain")

    printf "\nRequesting a certificate via DNS-Challenge for: %s\n\n" "$certbot_domain"

    "${certbot_cmd[@]}"
}

### certbot
###
###
printf "\n********************************************************************\n\nCreate initiales Let's Enycrypt Cert: $u_srv [y/N]: "
if [ "$u_certbot" = "" ]; then
    read u_certbot
fi

if [ "$u_certbot" = "y" ]; then

    certbot_dns_prepare

    ### get cert from Let's Encrypt
    ###
    ###
    certbot_dns_issue "$u_srv"

fi

printf "\n********************************************************************\n\nCreate Let's Enycrypt Cert for dovecot (imap.$u_domain) [y/N]: "
if [ "$u_certbot_dovecot" = "" ]; then
    read u_certbot_dovecot
fi

if [ "$u_certbot_dovecot" = "y" ]; then

    ### ask for servername
    u_tmp_imap=imap.$u_domain
    read -p "Servername for Dovecot (mostly imap.$u_domain): " -ei $u_tmp_imap u_imap

    certbot_dns_prepare

    ### get cert from Let's Encrypt
    ###
    ###
    certbot_dns_issue "$u_imap"

    ### update dovecot to new cert
    ###
    ###
    sed -i 's/^ssl_cert =/#ssl_cert =/' /etc/dovecot/conf.d/10-ssl.conf
    sed -i 's/^ssl_key =/#ssl_key =/' /etc/dovecot/conf.d/10-ssl.conf
    printf "[\e[32mOK\e[0m]\n"
    sed -i 's/^ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem/#ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem\n\nssl_cert = \<\/etc\/letsencrypt\/live\/'"$u_imap"'\/fullchain.pem\nssl_key = \<\/etc\/letsencrypt\/live\/'"$u_imap"'\/privkey.pem\n/' /etc/dovecot/conf.d/10-ssl.conf

fi
