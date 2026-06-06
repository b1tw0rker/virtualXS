#!/bin/bash

file004=/etc/bitworker

printf "\n********************************************************************\n\n%d) Install Borg Backup [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_borg_install" = "" ]; then
    read -r u_borg_install
else
    printf "%s\n" "$u_borg_install"
fi

case "${u_borg_install,,}" in
    y|yes|j|ja)
        if command -v borg >/dev/null 2>&1; then
            _log ok "borg already installed"
        else
            if dnf -y install borgbackup; then
                _log ok "borgbackup installed"
            else
                _log error "borgbackup konnte nicht installiert werden"
            fi
        fi
        ;;
esac

printf "\n********************************************************************\n\n%d) Borg Pull-Backup konfigurieren? [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_borg_configure" = "" ]; then
    read -r u_borg_configure
else
    printf "%s\n" "$u_borg_configure"
fi

case "${u_borg_configure,,}" in
    y|yes|j|ja)
        if ! command -v borg >/dev/null 2>&1; then
            _log error "borg ist nicht installiert"
        fi

        if [ ! -d "$file004" ]; then
            mkdir "$file004"
        fi

        if [ -d "$u_path/files/bitworker/borg" ]; then
            if ! cp -a "$u_path/files/bitworker/borg" "$file004/"; then
                _log error "cp failed: $u_path/files/bitworker/borg -> $file004/"
            else
                chown -R root:root "$file004/borg"

                for helper_file in "$file004"/borg/*.sh; do
                    if [ -f "$helper_file" ]; then
                        chmod 700 "$helper_file"
                    fi
                done

                for borg_conf_file in "$file004"/borg/*.conf; do
                    if [ -f "$borg_conf_file" ]; then
                        chmod 400 "$borg_conf_file"
                    fi
                done

                _log ok "borg helper scripts copied"
            fi
        else
            _log error "$u_path/files/bitworker/borg fehlt"
        fi

        read -p "IP von der gepullt werden soll: " -ei "$u_borg_pull_ip" u_borg_pull_ip

        if [[ ! "$u_borg_pull_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            _log error "ungueltige Borg Pull-IP: $u_borg_pull_ip"
        else
            borg_dir="$file004/borg"
            borg_template_ip="192.168.0.10"
            borg_template_ip_sed="${borg_template_ip//./\\.}"
            borg_conf="$borg_dir/$u_borg_pull_ip.conf"
            borg_paths="$borg_dir/$u_borg_pull_ip.paths"
            borg_patterns="$borg_dir/$u_borg_pull_ip.patterns"
            borg_service_name="borg-backup-$u_borg_pull_ip.service"
            borg_timer_name="borg-backup-$u_borg_pull_ip.timer"
            borg_service="$borg_dir/$borg_service_name"
            borg_timer="$borg_dir/$borg_timer_name"

            for borg_file_ext in conf paths patterns; do
                borg_template_file="$borg_dir/$borg_template_ip.$borg_file_ext"
                borg_target_file="$borg_dir/$u_borg_pull_ip.$borg_file_ext"
                if [ -f "$borg_template_file" ]; then
                    mv -f "$borg_template_file" "$borg_target_file"
                    sed -i "s/$borg_template_ip_sed/$u_borg_pull_ip/g" "$borg_target_file"
                fi
            done

            for borg_unit_ext in service timer; do
                borg_template_file="$borg_dir/borg-backup-$borg_template_ip.$borg_unit_ext"
                borg_target_file="$borg_dir/borg-backup-$u_borg_pull_ip.$borg_unit_ext"
                if [ -f "$borg_template_file" ]; then
                    mv -f "$borg_template_file" "$borg_target_file"
                    sed -i "s/$borg_template_ip_sed/$u_borg_pull_ip/g" "$borg_target_file"
                    sed -i 's#/etc/bitworker/borg/pulljob.sh#/etc/bitworker/borg/bw-pulljob.sh#g' "$borg_target_file"
                fi
            done

            if [ -f "$borg_dir/bw-pulljob.sh" ]; then
                sed -i "s#$borg_template_ip_sed#$u_borg_pull_ip#g" "$borg_dir/bw-pulljob.sh"
                sed -i 's#/etc/borg/#/etc/bitworker/borg/#g' "$borg_dir/bw-pulljob.sh"
                chmod 700 "$borg_dir/bw-pulljob.sh"
            fi

            if [ -f "$borg_conf" ]; then
                chown root:root "$borg_conf"
                chmod 400 "$borg_conf"
            fi
            [ -f "$borg_paths" ] && chmod 644 "$borg_paths"
            [ -f "$borg_patterns" ] && chmod 644 "$borg_patterns"

            if [ -x "$borg_dir/bw-pulljob.sh" ] && [ -f "$borg_conf" ]; then
                if CONFIG_FILE="$borg_conf" "$borg_dir/bw-pulljob.sh" init; then
                    _log ok "Borg repository initialized"
                else
                    _log error "Borg repository initialization failed"
                fi
            else
                _log error "Borg pulljob oder Config fehlt"
            fi

            if [ -f "$borg_service" ] && [ -f "$borg_timer" ]; then
                cp "$borg_service" "/etc/systemd/system/$borg_service_name"
                cp "$borg_timer" "/etc/systemd/system/$borg_timer_name"
                chmod 644 "/etc/systemd/system/$borg_service_name" "/etc/systemd/system/$borg_timer_name"
                systemctl daemon-reload
                if systemctl enable --now "$borg_timer_name"; then
                    _log ok "$borg_timer_name enabled"
                else
                    _log error "$borg_timer_name could not be enabled"
                fi
            else
                _log error "Borg systemd templates fehlen fuer $u_borg_pull_ip"
            fi

            if [ ! -f "/etc/cron.daily/copyjob" ] && [ -f "$u_path/files/backup/copyjobcron" ]; then
                cp "$u_path/files/backup/copyjobcron" /etc/cron.daily/copyjob
                chmod 700 /etc/cron.daily/copyjob
            fi

            if [ -f "/etc/cron.daily/copyjob" ]; then
                sed -i '/^### VXS borg pull backup start$/,/^### VXS borg pull backup end$/d' /etc/cron.daily/copyjob
                sed -i '/^exit 0$/d' /etc/cron.daily/copyjob
                cat >> /etc/cron.daily/copyjob <<EOF
### VXS borg pull backup start
if [ -x "/etc/bitworker/borg/bw-pulljob.sh" ]; then
    for borg_config in /etc/bitworker/borg/*.conf; do
        [ -f "\$borg_config" ] || continue
        CONFIG_FILE="\$borg_config" /etc/bitworker/borg/bw-pulljob.sh backup >> /dev/null 2>&1
    done
fi
### VXS borg pull backup end

exit 0
EOF
                chmod 700 /etc/cron.daily/copyjob
                _log ok "borg pulljob added to nightly cronjob"
            else
                _log error "nightly cronjob /etc/cron.daily/copyjob konnte nicht angelegt werden"
            fi
        fi
        ;;
esac
