#!/bin/bash

printf "\n********************************************************************\n\n%d) SELinux konfigurieren (Modus + Booleans + Dateikontexte) [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_selinux" = "" ]; then
    read u_selinux
fi

if [ "$u_selinux" = "y" ]; then
    printf "\n"

    ### --- Persistente fcontext-Regeln setzen oder korrigieren ---
    ### Usage: _selinux_fcontext_add <regex-spec> <type>
    ###
    _selinux_fcontext_add() {
        local spec="$1"
        local ctx="$2"
        local _existing

        if ! command -v semanage &>/dev/null; then
            _log error "semanage nicht verfuegbar – fcontext kann nicht gesetzt werden"
            return 1
        fi

        _existing=$(semanage fcontext -l 2>/dev/null | grep -F "$spec" || true)
        if [ -z "$_existing" ]; then
            if semanage fcontext -a -t "$ctx" "$spec" 2>/dev/null; then
                _log ok "semanage fcontext -a -t $ctx '$spec'"
            else
                _log error "semanage fcontext -a -t $ctx '$spec' – fehlgeschlagen"
            fi
            return
        fi

        if printf '%s\n' "$_existing" | grep -q " $ctx "; then
            _log info "fcontext bereits vorhanden: $spec"
            return
        fi

        if semanage fcontext -m -t "$ctx" "$spec" 2>/dev/null; then
            _log ok "semanage fcontext -m -t $ctx '$spec'"
        else
            _log error "semanage fcontext -m -t $ctx '$spec' – fehlgeschlagen"
        fi
    }

    ### --- SELinux Projektmodul bauen, laden und Altmodule entfernen ---
    ###
    _selinux_load_module() {
        local srcdir="/opt/virtualXS/selinux"
        local name="virtualxs"

        if [ ! -f "$srcdir/$name.te" ]; then
            _log error "SELinux Modulquelle fehlt: $srcdir/$name.te"
            return 1
        fi

        if ! command -v checkmodule &>/dev/null; then
            _log info "checkpolicy fehlt – wird nachinstalliert"
            if ! dnf -y install checkpolicy >/dev/null 2>&1; then
                _log error "checkpolicy konnte nicht installiert werden"
                return 1
            fi
            _log ok "checkpolicy installiert"
        fi

        if ! command -v semodule_package &>/dev/null; then
            _log info "semodule_package fehlt – installiere policycoreutils-python-utils"
            if ! dnf -y install policycoreutils-python-utils >/dev/null 2>&1; then
                _log error "policycoreutils-python-utils konnte nicht installiert werden"
                return 1
            fi
            _log ok "policycoreutils-python-utils installiert"
        fi

        if ! command -v semodule &>/dev/null; then
            _log info "semodule fehlt – installiere policycoreutils"
            if ! dnf -y install policycoreutils >/dev/null 2>&1; then
                _log error "policycoreutils konnte nicht installiert werden"
                return 1
            fi
            _log ok "policycoreutils installiert"
        fi

        if checkmodule -M -m -o "$srcdir/$name.mod" "$srcdir/$name.te" 2>/dev/null \
            && semodule_package -o "$srcdir/$name.pp" -m "$srcdir/$name.mod" 2>/dev/null \
            && semodule -i "$srcdir/$name.pp" 2>/dev/null; then
            _log ok "SELinux Modul '$name' geladen"
        else
            _log error "SELinux Modul '$name' – Kompilierung oder Laden fehlgeschlagen"
            return 1
        fi

        if semodule -l 2>/dev/null | awk '{print $1}' | grep -qx "fail2ban_httpd"; then
            if semodule -r fail2ban_httpd 2>/dev/null; then
                _log ok "Altes SELinux Modul entfernt: fail2ban_httpd"
            else
                _log error "Konnte altes Modul fail2ban_httpd nicht entfernen"
            fi
        fi

        if semodule -l 2>/dev/null | awk '{print $1}' | grep -qx "postfix_mysql"; then
            if semodule -r postfix_mysql 2>/dev/null; then
                _log ok "Altes SELinux Modul entfernt: postfix_mysql"
            else
                _log error "Konnte altes Modul postfix_mysql nicht entfernen"
            fi
        fi
    }

    ### --- Tools sicherstellen ----------------------------------
    ###
    ###
    if ! _selinux_ensure_tools; then
        _log error "SELinux Tools fehlen – einige Schritte koennen fehlschlagen"
    fi

    ### --- Enforcing-Pruefung ----------------------------------
    ###  SELinux muss auf Enforcing stehen. Der Modus wird hier nicht
    ###  veraendert – bei Abweichung wird ein Fehler ausgegeben.
    ###
    _selinux_current=$(getenforce 2>/dev/null || echo "unbekannt")
    if [ "$_selinux_current" != "Enforcing" ]; then
        _log error "SELinux ist nicht auf Enforcing – aktuell: $_selinux_current"
    fi

    ### --- Booleans – HTTPD (Apache) ---------------------------
    ###   httpd_can_network_connect     – Verbindung zu externen Diensten
    ###   httpd_can_network_connect_db  – Verbindung zu Datenbank (z.B. MySQL)
    ###   httpd_can_sendmail            – E-Mail-Versand aus PHP/CGI
    ###   httpd_unified                 – httpd liest alle httpd-Label
    ###   httpd_enable_homedirs         – Zugriff auf /home/* (UserDir)
    ###   httpd_read_user_content       – Lesen von Benutzer-Inhalten
    ###
    printf "\n--- SELinux Booleans: HTTPD ---\n"
    _selinux_set_bool httpd_can_network_connect
    _selinux_set_bool httpd_can_network_connect_db
    _selinux_set_bool httpd_can_sendmail
    _selinux_set_bool httpd_unified
    _selinux_set_bool httpd_enable_homedirs
    _selinux_set_bool httpd_read_user_content

    ### --- Booleans – FTP (vsftpd) -----------------------------
    ###   ftpd_connect_db      – vsftpd verbindet sich mit Datenbank (PAM/MySQL)
    ###   ftpd_use_passive_mode – passiver FTP-Modus erlaubt
    ###
    printf "\n--- SELinux Booleans: VSFTPD ---\n"
    _selinux_set_bool ftpd_connect_db
    _selinux_set_bool ftpd_use_passive_mode

    ### --- Booleans – MySQL / MariaDB --------------------------
    ###   mysql_connect_any – MySQL verbindet sich auf beliebige Ports/Sockets
    ###
    printf "\n--- SELinux Booleans: MySQL ---\n"
    _selinux_set_bool mysql_connect_any

    ### --- Booleans – Mail (Postfix / Dovecot) -----------------
    ###   allow_postfix_local_write_mail_spool – Postfix schreibt in Mail-Spool
    ###
    printf "\n--- SELinux Booleans: Mail ---\n"
    _selinux_set_bool allow_postfix_local_write_mail_spool

    ### --- fcontext: /home/httpd dauerhaft markieren ------------
    ###  Ohne semanage fcontext faellt restorecon nach Reboot auf
    ###  user_home_dir_t/user_home_t zurueck.
    ###
    printf "\n--- SELinux fcontext: /home/httpd ---\n"
    _selinux_fcontext_add '/home/httpd(/.*)?' httpd_sys_content_t
    _selinux_fcontext_add '/home/httpd(/[^/]+)?/logs(/.*)?' httpd_log_t
    _selinux_restorecon /home/httpd

    ### --- Dateikontexte (restorecon) --------------------------
    ###  Setzt SELinux-Dateikontexte fuer alle relevanten Verzeichnisse zurueck.
    ###  Wird nach Kopieroperationen oder strukturellen Aenderungen benoetigt.
    ###
    printf "\n--- SELinux Dateikontexte (restorecon) ---\n"
    _restorecon_paths=(
        /home/httpd
        /home/pop
        /home/mysql
        /etc/httpd
        /var/www
        /var/log
        /etc/postfix
        /etc/dovecot
    )
    for _path in "${_restorecon_paths[@]}"; do
        _selinux_restorecon "$_path"
    done

    ### --- SELinux Modul: virtualxs ----------------------------
    ###
    printf "\n--- SELinux Modul: virtualxs ---\n"
    _selinux_load_module

    printf "\n"; _log ok "SELinux Konfiguration abgeschlossen"

fi
