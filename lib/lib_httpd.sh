#!/bin/bash

file005=/etc/httpd/conf/httpd.conf
file008=/etc/httpd/conf.d

printf "\n********************************************************************\n\n%d) Configure /etc/httpd/conf/httpd.conf [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_httpd" = "" ]; then
    read u_httpd
fi

if [ "$u_httpd" = "y" ]; then
    printf "\n"
    if [ -f "$file005" ]; then

        sed -i 's/^#ServerName www.example.com:80/ServerName '"$u_ip"':80/' $file005

    fi

    # Disable default httpd config files in-place – dnf-update-safe (%config noreplace)
    # RPM preserves modified files on update; new versions land as .rpmnew
    if [ -f "/etc/httpd/conf.d/autoindex.conf" ]; then
        echo "# Disabled by virtualXS" > /etc/httpd/conf.d/autoindex.conf
    fi
    if [ -f "/etc/httpd/conf.d/userdir.conf" ]; then
        echo "# Disabled by virtualXS" > /etc/httpd/conf.d/userdir.conf
    fi
    if [ -f "/etc/httpd/conf.d/welcome.conf" ]; then
        echo "# Disabled by virtualXS" > /etc/httpd/conf.d/welcome.conf
    fi
    if [ -f "/etc/httpd/conf.modules.d/00-dav.conf" ]; then
        echo "# Disabled by virtualXS" > /etc/httpd/conf.modules.d/00-dav.conf
    fi
    if [ -f "/etc/httpd/conf.modules.d/00-lua.conf" ]; then
        echo "# Disabled by virtualXS" > /etc/httpd/conf.modules.d/00-lua.conf
    fi

    if [ -d "/var/www/html" ]; then
        cp $u_path/files/httpd/index.html /var/www/html
    fi

    ### Autoindex
    ###
    ###
    if [ -d "/usr/share/httpd/noindex" ]; then
        cp -rf $u_path/files/httpd/index.html /usr/share/httpd/noindex/
    fi

    ### systemd drop-in: ProtectHome=no fuer /home/httpd Webhosting
    ### Ohne diesen Drop-in blockiert ProtectHome=read-only den Schreibzugriff
    ### auf /home/httpd/<kunde>/logs, den httpd benoetigt.
    ###
    _dropin_dir="/etc/systemd/system/httpd.service.d"
    _dropin_file="${_dropin_dir}/virtualx-hosting.conf"
    if [ ! -d "$_dropin_dir" ]; then
        mkdir -p "$_dropin_dir"
    fi
    cat > "$_dropin_file" << 'DROPIN'
# Drop-in Override fuer httpd.service.
#
# Die mitgelieferte Unit /usr/lib/systemd/system/httpd.service haertet httpd
# mit ProtectHome=read-only ab. Auf diesem Webhosting-Server liegen
# Kundendaten (DocumentRoot UND Logs) unter /home/httpd/<kunde>/..., damit
# Kunden ihre Logs per FTP abrufen koennen. httpd muss daher in /home
# schreiben duerfen -> ProtectHome deaktiviert.
#
# Aenderungen an dieser Datei mit `systemctl daemon-reload` aktivieren.

[Service]
ProtectHome=no
DROPIN
    systemctl daemon-reload
    _log ok "httpd drop-in virtualx-hosting.conf created, daemon-reload done"

    ### if the apache server never has been started before, /etc/pki/certs/localhost.crt and /etc/pki/private/localhost.key are missing. Create self-signed certs for localhost.
    ### start and stop httpd to create the certs if they are missing.
    ###
    if [ ! -f "/etc/pki/certs/localhost.crt" ] || [ ! -f "/etc/pki/private/localhost.key" ]; then
         systemctl start httpd
    fi

    ### http/2
    ###
    ###
    if [ "$u_server" = "w" ] && [ -d "$file008" ]; then
        cp $u_path/files/httpd/http2.conf $file008/
        cp $u_path/files/httpd/security.conf $file008/
        cp $u_path/files/httpd/virtualx-performance.conf $file008/
    fi

    ### Check Apache State
    ###
    ###
    u_state=$(apachectl -t 2>&1)

    if [ "$u_state" = "Syntax OK" ]; then
        systemctl restart httpd
        _log ok "httpd restarted"
    else
        _log error "httpd restart failed:"
        apachectl -t
    fi

    ### --- SELinux: HTTPD Booleans + Dateikontexte ---------------
    ###   httpd_can_network_connect     – Verbindung zu externen Diensten
    ###   httpd_can_network_connect_db  – Verbindung zu Datenbank (z.B. MySQL)
    ###   httpd_can_sendmail            – E-Mail-Versand aus PHP/CGI
    ###   httpd_unified                 – httpd liest alle httpd-Label
    ###   httpd_enable_homedirs         – Zugriff auf /home/* (UserDir)
    ###   httpd_read_user_content       – Lesen von Benutzer-Inhalten
    ###
    printf "\n********************************************************************\n\n"
    if confirm "$(( ++_vxs_step ))) SELinux: HTTPD Booleans + Dateikontexte setzen" "$u_httpd_selinux"; then
        printf "\n--- SELinux: HTTPD ---\n"
        _selinux_ensure_tools
        _selinux_set_bool httpd_can_network_connect
        _selinux_set_bool httpd_can_network_connect_db
        _selinux_set_bool httpd_can_sendmail
        _selinux_set_bool httpd_unified
        _selinux_set_bool httpd_enable_homedirs
        _selinux_set_bool httpd_read_user_content
        _selinux_restorecon /etc/httpd
        _selinux_restorecon /var/www
    fi

fi
