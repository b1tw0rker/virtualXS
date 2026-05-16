#!/bin/bash

printf "\n********************************************************************\n\nSELinux konfigurieren (Modus + Booleans + Dateikontexte) [y/N]: "
if [ "$u_selinux" = "" ]; then
    read u_selinux
fi

if [ "$u_selinux" = "y" ]; then

    ### --- Tools sicherstellen ----------------------------------
    ###
    ###
    if ! command -v setsebool &>/dev/null || ! command -v restorecon &>/dev/null || ! command -v setenforce &>/dev/null; then
        printf "[\e[33mINFO\e[0m] policycoreutils fehlt – wird nachinstalliert\n"
        if dnf -y install policycoreutils 2>/dev/null; then
            printf "[\e[32mOK\e[0m] policycoreutils installiert\n"
        else
            printf "[\e[31mERROR\e[0m] policycoreutils konnte nicht installiert werden\n"
        fi
    fi

    if ! command -v semanage &>/dev/null; then
        printf "[\e[33mINFO\e[0m] semanage fehlt – installiere policycoreutils-python-utils\n"
        if dnf -y install policycoreutils-python-utils 2>/dev/null; then
            printf "[\e[32mOK\e[0m] policycoreutils-python-utils installiert\n"
        else
            printf "[\e[31mERROR\e[0m] policycoreutils-python-utils konnte nicht installiert werden\n"
        fi
    fi

    ### --- Aktueller Status ------------------------------------
    ###
    ###
    _selinux_current=$(getenforce 2>/dev/null || echo "unbekannt")
    printf "[\e[33mINFO\e[0m] SELinux aktuell: %s\n" "$_selinux_current"

    ### --- Modus setzen ----------------------------------------
    ###
    ###
    printf "\n Modus waehlen:\n"
    printf "   [e] enforcing  – Policy wird durchgesetzt, Verstoesze werden blockiert\n"
    printf "   [p] permissive – Verstoesze werden geloggt, NICHT blockiert  (Standard)\n"
    printf "   [d] disabled   – SELinux deaktiviert (erfordert Reboot)\n\n"

    if [ "$u_selinux_mode" = "" ]; then
        read -p "SELinux Modus [e/P/d]: " u_selinux_mode
        u_selinux_mode=${u_selinux_mode:-p}
    fi

    case "$u_selinux_mode" in
        e|E) _sl_mode=enforcing;  _sl_rt=1  ;;
        d|D) _sl_mode=disabled;   _sl_rt="" ;;
        *)   _sl_mode=permissive; _sl_rt=0  ;;
    esac

    if [ -f /etc/selinux/config ]; then
        sed -i "s/^SELINUX=.*$/SELINUX=${_sl_mode}/" /etc/selinux/config
        if grep -q "^SELINUX=${_sl_mode}" /etc/selinux/config; then
            printf "[\e[32mOK\e[0m] /etc/selinux/config: SELINUX=%s\n" "$_sl_mode"
        else
            printf "[\e[31mERROR\e[0m] /etc/selinux/config – SELINUX konnte nicht gesetzt werden\n"
        fi
    else
        printf "[\e[31mERROR\e[0m] /etc/selinux/config nicht gefunden\n"
    fi

    if [ -n "$_sl_rt" ]; then
        if setenforce "$_sl_rt" 2>/dev/null; then
            printf "[\e[32mOK\e[0m] setenforce %s – sofort aktiv\n" "$_sl_rt"
        else
            printf "[\e[33mINFO\e[0m] setenforce %s – konnte nicht gesetzt werden (System evtl. bereits disabled)\n" "$_sl_rt"
        fi
    else
        printf "[\e[33mINFO\e[0m] Modus 'disabled' wird erst nach Reboot wirksam\n"
    fi

    ### --- Hilfsfunktion: Boolean setzen ------------------------
    ###  Prueft Verfuegbarkeit via getsebool, setzt den Boolean persistent (-P).
    ###
    _selinux_set_bool() {
        local bool="$1" val="${2:-on}"
        if ! getsebool "$bool" &>/dev/null; then
            printf "[\e[33mINFO\e[0m] Boolean %-40s – auf diesem System nicht verfuegbar\n" "$bool"
            return
        fi
        if setsebool -P "$bool" "$val" 2>/dev/null; then
            printf "[\e[32mOK\e[0m] setsebool -P %-40s %s\n" "$bool" "$val"
        else
            printf "[\e[31mERROR\e[0m] setsebool -P %s %s – fehlgeschlagen\n" "$bool" "$val"
        fi
    }

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
        if [ -e "$_path" ]; then
            if restorecon -Rv "$_path" >/dev/null 2>&1; then
                printf "[\e[32mOK\e[0m] restorecon -Rv %s\n" "$_path"
            else
                printf "[\e[31mERROR\e[0m] restorecon -Rv %s – fehlgeschlagen\n" "$_path"
            fi
        else
            printf "[\e[33mINFO\e[0m] %s nicht vorhanden – restorecon uebersprungen\n" "$_path"
        fi
    done

    printf "\n[\e[32mOK\e[0m] SELinux Konfiguration abgeschlossen\n"

fi
