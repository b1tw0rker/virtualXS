#!/bin/bash

### /etc/ssh/sshd_config SFTP
###
###
# Smart default: Y if internal-sftp not yet configured, N if already set
_sftp_default="n"
_sftp_prompt="[y/N]"
if grep -q "internal-sftp" /etc/ssh/sshd_config 2>/dev/null; then
    _sftp_default="n"
    _sftp_prompt="[y/N]"
fi
printf "\n********************************************************************\n\n%d) Enable SFTP %s: " "$(( ++_vxs_step ))" "$_sftp_prompt"
if [ "$u_ssh_sftp" = "" ]; then
        read u_ssh_sftp
        [ "$u_ssh_sftp" = "" ] && u_ssh_sftp="$_sftp_default"
fi

if [ "$u_ssh_sftp" = "y" ]; then
    printf "\n"

        file_ssh001=/etc/ssh/sshd_config

        if [ -f "$file_ssh001" ]; then
                # #Port 22 aktivieren und Port 1122 darunter einfügen
                sed -i 's/^#Port 22$/Port 22/' "$file_ssh001"
                if ! grep -q '^Port 1122' "$file_ssh001"; then
                        sed -i '/^Port 22/a Port 1122' "$file_ssh001"
                fi

                sed -i -E 's|^[#[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+.*$|Subsystem       sftp    internal-sftp|' "$file_ssh001"

                if ! grep -Eq '^Subsystem[[:space:]]+sftp[[:space:]]+internal-sftp$' "$file_ssh001"; then
                        printf '\nSubsystem       sftp    internal-sftp\n' >>"$file_ssh001"
                fi

                tmp_ssh_sftp=$(mktemp)
                awk '
                BEGIN { skip = 0 }
                /^#? *(Match User [^ ]+ LocalPort 1122|Match Group users LocalPort 1122)$/ {
                        skip = 1
                        next
                }
                skip == 1 {
                        if ($0 ~ /^[[:space:]]/ || $0 ~ /^#[[:space:]]+/) {
                                next
                        }
                        skip = 0
                }
                {
                        print
                }
                ' "$file_ssh001" >"$tmp_ssh_sftp"
                mv "$tmp_ssh_sftp" "$file_ssh001"

                cat <<EOF >>"$file_ssh001"

# Ausnahme für einen speziellen User
Match User ${u_srv} LocalPort 1122
    ChrootDirectory /home/httpd/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes

Match Group users LocalPort 1122
    ChrootDirectory /home/httpd/www.%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes
EOF

                if semanage port -a -t ssh_port_t -p tcp 1122 2>/dev/null; then
                        _log ok "semanage port 1122 added"
                else
                        _log info "semanage port 1122 already exists or skipped"
                fi
                if systemctl restart sshd; then
                        _log ok "sshd restarted"
                else
                        _log error "sshd restart failed"
                fi
        fi

fi