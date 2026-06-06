#!/bin/bash

printf "\n********************************************************************\n\n%d) Jetzt Datei-chattr-Attribute setzen [j/N]: " "$(( ++_vxs_step ))"
if [ "$u_chattr" = "" ]; then
    read u_chattr
fi

case "${u_chattr,,}" in
    j|ja|y|yes)
        u_chattr=y
        ;;
    *)
        u_chattr=n
        ;;
esac

if [ "$u_chattr" = "y" ]; then
    printf "\n"

    if ! command -v chattr >/dev/null 2>&1; then
        _log error "chattr nicht gefunden - Attribute konnten nicht gesetzt werden"
        return 1
    fi

    chattr_files=(
        /etc/fstab
        /etc/default/grub
        /etc/crypttab
        /etc/hosts
        /etc/hostname
        /etc/ssh/sshd_config
        /etc/sudoers
        /etc/selinux/config
        /etc/sysctl.conf
        /etc/security/limits.conf
        /etc/login.defs
        /etc/dnf/dnf.conf
        /etc/yum.repos.d/virtualx.repo
        /etc/firewalld/firewalld.conf
        /etc/firewalld/zones/public.xml
        /etc/sysconfig/network
        /etc/sysconfig/sshd
        /etc/crontab
        /etc/chrony.conf
        /etc/audit/auditd.conf
        /etc/my.cnf
        /etc/my.cnf.d/99-bw-performance.cnf
        /etc/postfix/main.cf
        /etc/postfix/master.cf
        /etc/dovecot/dovecot.conf
    )

    for chattr_file in "${chattr_files[@]}"; do
        if [ ! -e "$chattr_file" ]; then
            _log info "$chattr_file nicht vorhanden - uebersprungen"
            continue
        fi

        if chattr +i "$chattr_file"; then
            _log ok "chattr +i $chattr_file"
        else
            _log error "chattr +i $chattr_file fehlgeschlagen"
        fi
    done
fi
