#!/bin/bash

mysql_perf_source="$u_path/files/mysql/99-bw-performance.cnf"
mysql_perf_target=/etc/my.cnf.d/99-bw-performance.cnf

if [ -f "$mysql_perf_source" ]; then
    mkdir -p /etc/my.cnf.d
    if cp "$mysql_perf_source" "$mysql_perf_target"; then
        _log ok "Copied 99-bw-performance.cnf to /etc/my.cnf.d/"
    else
        _log error "Could not copy 99-bw-performance.cnf to /etc/my.cnf.d/"
    fi
else
    _log info "$mysql_perf_source not found - MySQL tuning skipped"
fi

_log info "Starting MySQL"
if systemctl start mysqld >/dev/null 2>&1; then
    _log ok "MySQL Server started"
else
    _log error "Could not start MySQL Server"
fi

if [ "${u_mysql_pwd_change_requested:-n}" = "y" ] && [ -n "${u_mysql_pwd:-}" ]; then
    if mysqladmin -u root password "$u_mysql_pwd" >/dev/null 2>&1; then
        _log ok "Changed MySQL root password successfully"
    else
        _log error "Could not change MySQL root password"
    fi
fi