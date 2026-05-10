#!/bin/bash

printf "\n********************************************************************\n\nErsten VirtualX Server installieren [y/N]: "
if [ "$u_virtualx" = "" ]; then
    read u_virtualx
fi

if [ "$u_virtualx" = "y" ]; then

    ### Create user for vhost
    ###
    ###
    if ! id "$u_srv" &>/dev/null; then
        useradd -g 100 -d /home/httpd/$u_srv -s /sbin/nologin -M $u_srv
    fi
    u_srv_pwd=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c 12)
    echo "$u_srv:$u_srv_pwd" | chpasswd
    printf "\n[\e[32mOK\e[0m] User \e[1m$u_srv\e[0m\nPasswort: \e[1;33m$u_srv_pwd\e[0m\n"

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

    chown -R $u_srv:users /home/httpd/$u_srv
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
user = $u_domain
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

    printf "[\e[32mOK\e[0m]\n"

fi
