#!/bin/bash

print_virtualx_access_summary() {
    local sftp_address="${u_ip}:1122"
    local ftps_address="${u_ip}:21"

    printf "\n----------------------------\n"
    _log ok "VirtualX API ready"
    printf "User: \e[1m%s\e[0m\n" "$u_srv"
    printf "Password: \e[1;33m%s\e[0m\n" "$u_srv_pwd"

    printf -- "---\n"
    printf "Connection checks via server IP %s\n" "$u_ip"
    printf "SFTP  -> %s  authenticated login + directory listing\n" "$sftp_address"
    printf "FTPS  -> %s  explicit TLS login + directory listing\n" "$ftps_address"
}

print_virtualx_check_result() {
    local label="$1"
    local address="$2"
    local status="$3"
    local detail="$4"
    local success_detail="$5"

    if [ "$status" -eq 0 ]; then
        printf "%s: [\e[32mOK\e[0m] %s (%s)\n" "$label" "$success_detail" "$address"
        return
    fi

    printf "%s: [\e[31mFAILED\e[0m] %s (%s)\n" "$label" "$(compact_virtualx_check_error "$detail")" "$address"
}

run_virtualx_sftp_check() {
    local output
    local status
    local address="${u_ip}:1122"

    if ! command -v curl >/dev/null 2>&1; then
        print_virtualx_check_result "SFTP" "$address" 1 "curl not installed" ""
        return
    fi

    output=$(timeout 15 curl -k -s -S --connect-timeout 10 --list-only \
        -u "${u_srv}:${u_srv_pwd}" "sftp://${u_ip}:1122/" 2>&1)
    status=$?

    if [ "$status" -eq 0 ]; then
        print_virtualx_check_result "SFTP" "$address" 0 "$output" "Authenticated login succeeded"
        return
    fi

    if [ "$status" -eq 124 ]; then
        output="connection timed out"
    elif [ -z "$output" ]; then
        output="authentication or directory listing failed"
    fi

    print_virtualx_check_result "SFTP" "$address" 1 "$output" ""
}

run_virtualx_ftps_check() {
    local output
    local status
    local address="${u_ip}:21"

    if ! command -v curl >/dev/null 2>&1; then
        print_virtualx_check_result "FTPS" "$address" 1 "curl not installed" ""
        return
    fi

    output=$(timeout 15 curl --ssl-reqd -k -s -S --connect-timeout 10 --list-only \
        -u "${u_srv}:${u_srv_pwd}" "ftp://${u_ip}:21/" 2>&1)
    status=$?

    if [ "$status" -eq 0 ]; then
        print_virtualx_check_result "FTPS" "$address" 0 "$output" "Authenticated explicit TLS login succeeded"
        return
    fi

    if [ "$status" -eq 124 ]; then
        output="connection timed out"
    elif [ -z "$output" ]; then
        output="unknown error"
    fi

    print_virtualx_check_result "FTPS" "$address" 1 "$output" ""
}

printf "\n********************************************************************\n\n%d) Install VirtualX API server [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_virtualx" = "" ]; then
    read u_virtualx
fi

if [ "$u_virtualx" = "y" ]; then
    printf "\n"
    if [ ! -f /etc/letsencrypt/options-ssl-apache.conf ]; then
        _log error "/etc/letsencrypt/options-ssl-apache.conf not found – VirtualX installation skipped"
    elif ! systemctl is-active --quiet mysqld; then
        _log error "MySQL is not running – VirtualX installation skipped"
    else

    ### Create user for vhost
    ###
    ###
    if ! id "$u_srv" &>/dev/null; then
        useradd -g 100 -d /home/httpd/$u_srv -s /sbin/nologin -M $u_srv
    fi
    u_srv_pwd=$(tr -dc 'A-Za-z0-9@_-' < /dev/urandom | head -c 14)
    echo "$u_srv:$u_srv_pwd" | chpasswd
    _log ok "User "$'\e[1m'"$u_srv"$'\e[0m'" created"


    ### Create sudoers entry for virtualx user
    ###
    ###
    _sudoers_file="/etc/sudoers.d/${u_srv}"
    if [ ! -f "$_sudoers_file" ]; then
        printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$u_srv" > "$_sudoers_file"
        chmod 440 "$_sudoers_file"
        _log ok "Sudoers entry for API calls created: $_sudoers_file"
    fi

    ### Create additional directories for VirtualX webroot
    ###
    mkdir -p "/home/httpd/$u_srv/htdocs/dbx"
    mkdir -p "/home/httpd/$u_srv/htdocs/adminx/plugins/virtualx"
    _log ok "Created dbx and adminx/plugins/virtualx directories in htdocs."

    ### Download and extract phpMyAdmin into dbx
    ###
    pma_url="https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip"
    pma_zip="/tmp/phpMyAdmin-5.2.3-all-languages.zip"
    pma_target="/home/httpd/$u_srv/htdocs/dbx"
    if command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
        curl -fsSL "$pma_url" -o "$pma_zip"
        if [ -f "$pma_zip" ]; then
            unzip -q "$pma_zip" -d "$pma_target"
            # Move contents up if needed
            if [ -d "$pma_target/phpMyAdmin-5.2.3-all-languages" ]; then
                mv "$pma_target/phpMyAdmin-5.2.3-all-languages"/* "$pma_target/"
                rmdir "$pma_target/phpMyAdmin-5.2.3-all-languages"
            fi
            rm -f "$pma_zip"
            _log ok "phpMyAdmin 5.2.3 deployed to $pma_target."
        else
            _log error "phpMyAdmin download failed."
        fi
    else
        _log warn "curl or unzip not found, skipping phpMyAdmin deployment."
    fi

    chown -R "$u_srv:users" \
        "/home/httpd/$u_srv/htdocs/dbx" \
        "/home/httpd/$u_srv/htdocs/adminx" \
        "/home/httpd/$u_srv/htdocs/adminx/plugins" \
        "/home/httpd/$u_srv/htdocs/adminx/plugins/virtualx"

    ### Create directories
    ###
    ###
    if [ ! -d "/home/httpd/$u_srv/htdocs" ]; then
        mkdir -p /home/httpd/$u_srv/htdocs
    fi

    if [ ! -d "/home/httpd/$u_srv/logs" ]; then
        mkdir -p /home/httpd/$u_srv/logs
    fi

    if [ ! -d "/home/httpd/$u_srv/tmp" ]; then
        mkdir -p /home/httpd/$u_srv/tmp
    fi


    chown -R "$u_srv:users" /home/httpd/$u_srv/htdocs /home/httpd/$u_srv/logs /home/httpd/$u_srv/tmp

    chmod 755 /home/httpd/$u_srv
    chmod 750 /home/httpd/$u_srv/htdocs

    ### Create /etc/httpd/virtualx.d/ directory if not exists
    ###
    ###
    if [ ! -d "/etc/httpd/virtualx.d" ]; then
        mkdir -p /etc/httpd/virtualx.d
    fi

    ### Ensure IncludeOptional for virtualx.d is in httpd.conf
    ###
    ###
    if [ -f "/etc/httpd/conf/httpd.conf" ]; then
        if ! grep -q 'IncludeOptional virtualx.d/\*\.conf' /etc/httpd/conf/httpd.conf; then
            printf '\n###\n###\n### VirtualX Hosts\nIncludeOptional virtualx.d/*.conf\n' >> /etc/httpd/conf/httpd.conf
        fi
    fi

    ### Write HTTP VirtualHost (Port 80)
    ###
    ###
    cat > /etc/httpd/virtualx.d/$u_srv.conf <<EOF
<VirtualHost $u_ip:80>
DocumentRoot "/home/httpd/$u_srv/htdocs"
ServerName $u_srv
ServerAlias $u_domain
ServerAdmin webmaster@$u_domain
DirectoryIndex index.html index.php
ErrorLog /home/httpd/$u_srv/logs/error.log
CustomLog /home/httpd/$u_srv/logs/access.log "%h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\""
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

<Directory "/home/httpd/$u_srv/htdocs">
  AllowOverride all
  Require all granted
</Directory>

    <IfModule mod_proxy_fcgi.c>
        ProxyPassMatch "^/(.*\.php(/.*)?)$" "unix:/run/php-fpm/$u_srv.sock|fcgi://localhost/home/httpd/$u_srv/htdocs"
    </IfModule>

    <IfModule mod_security2.c>
      SecRuleEngine Off
      SecRequestBodyAccess Off
    </IfModule>

RewriteEngine on
RewriteCond %{SERVER_NAME} =$u_srv
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF

    ### Write HTTPS VirtualHost (Port 443)
    ###
    ###
    cat > /etc/httpd/virtualx.d/$u_srv-le-ssl.conf <<EOF
<IfModule mod_ssl.c>
<VirtualHost $u_ip:443>
DocumentRoot "/home/httpd/$u_srv/htdocs"
ServerName $u_srv
ServerAlias $u_domain
ServerAdmin webmaster@$u_domain
DirectoryIndex index.html index.php
ErrorLog /home/httpd/$u_srv/logs/error.log
CustomLog /home/httpd/$u_srv/logs/access.log "%h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\""
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

<Directory "/home/httpd/$u_srv/htdocs">
  AllowOverride all
  Require all granted
</Directory>

     <IfModule mod_proxy_fcgi.c>
         ProxyPassMatch "^/(.*\.php(/.*)?)$" "unix:/run/php-fpm/$u_srv.sock|fcgi://localhost/home/httpd/$u_srv/htdocs"
     </IfModule>

    <IfModule mod_security2.c>
      SecRuleEngine Off
      SecRequestBodyAccess Off
    </IfModule>

   Include /etc/letsencrypt/options-ssl-apache.conf
   SSLCertificateFile /etc/letsencrypt/live/$u_srv/fullchain.pem
   SSLCertificateKeyFile /etc/letsencrypt/live/$u_srv/privkey.pem

</VirtualHost>
</IfModule>
EOF

    ### Write PHP-FPM pool config
    ###
    ###
    cat > /etc/php-fpm.d/$u_srv.conf <<EOF
[$u_srv]
user = $u_srv
group = users
listen = /run/php-fpm/$u_srv.sock
listen.acl_users = apache
listen.allowed_clients = 127.0.0.1
pm = ondemand
;pm = dynamic
pm.max_children = 50
pm.start_servers = 3
pm.min_spare_servers = 3
pm.max_spare_servers = 10
slowlog = /var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /var/log/php-fpm/www-error.log
;php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 128M
php_value[session.save_handler] = files
php_value[session.save_path]    = /home/httpd/$u_srv/tmp
php_value[soap.wsdl_cache_dir]  = /home/httpd/$u_srv/tmp
php_admin_value[open_basedir] = /
php_admin_value[upload_tmp_dir] = /home/httpd/$u_srv/tmp
php_admin_value[sys_temp_dir] = /home/httpd/$u_srv/tmp
EOF

    ### Create vsftpd virtual user config
    ###
    ###
    vsftpd_user_conf_dir=/etc/vsftpd/vsftpd_user_conf
    if [ -d "$vsftpd_user_conf_dir" ]; then
        cat > "$vsftpd_user_conf_dir/$u_srv" <<EOF
guest_username=$u_srv
write_enable=YES
local_root=/home/httpd/$u_srv
EOF
        _log ok "vsftpd user config created: $vsftpd_user_conf_dir/$u_srv"
    fi

    ### Create virtualx DB entry
    ###
    ###
    mysql -u root virtualx <<EOF
INSERT IGNORE INTO domains (domainname, user, real_dom)
  VALUES ('$u_srv', '$u_srv', '$u_domain');
SET @web_id = LAST_INSERT_ID();
INSERT IGNORE INTO domaininfos (web_id, virtualx_usr, apache, virtuelle_ftp, status, createdate, server)
  VALUES (@web_id, '$u_srv', 1, 1, 'active', CURDATE(), '$u_hostname');
INSERT INTO passwd (dom_id, username, passwd, rootdir, status)
  VALUES (@web_id, '$u_srv', SHA2('$u_srv_pwd', 256), '/home/httpd/$u_srv', 'A')
  ON DUPLICATE KEY UPDATE
    passwd  = SHA2('$u_srv_pwd', 256),
    rootdir = '/home/httpd/$u_srv',
    status  = 'A';
EOF
    _log ok "virtualX DB entry created for $u_srv"

    print_virtualx_access_summary

    run_virtualx_sftp_check
    run_virtualx_ftps_check

    fi # end: mysqld is-active check

fi
