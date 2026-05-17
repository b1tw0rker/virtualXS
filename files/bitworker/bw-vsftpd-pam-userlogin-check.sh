#!/bin/bash
#
# bw-vsftpd-pam-userlogin-check.sh
# PAM exec authentication script for vsftpd against virtualx MySQL db.
#
# Called by pam_exec with expose_authtok; password arrives on stdin.
# PAM_USER is set as environment variable by PAM.
#
# Deployed to: /etc/bitworker/bw-vsftpd-pam-userlogin-check.sh (chmod 700, root:root)
# MySQL vsftpd user credentials are read from /etc/vsftpd/.my.cnf (written during MySQL setup in vxs)
# Password hash in DB: SHA2(password, 256) - 64 hex chars
#
# Test on terminal:
# echo 'PASSWORD' | PAM_USER=srv016.host-x.de /etc/bitworker/bw-vsftpd-pam-userlogin-check.sh --debug; echo "Exit code: $?"
# Exit code 0 = success, 1 = failure
# Debug mode prints the failure reason to stderr and is intended for manual tests only.

MYSQL_DB="virtualx"
debug_enabled=0

if [[ "${BW_VSFTPD_DEBUG:-0}" == "1" || "${1:-}" == "--debug" ]]; then
    debug_enabled=1
fi

debug_log() {
    if [[ "$debug_enabled" -eq 1 ]]; then
        printf 'bw-vsftpd-pam-userlogin-check: %s\n' "$1" >&2
    fi
}

fail() {
    debug_log "$1"
    exit 1
}

success() {
    debug_log "$1"
    exit 0
}

mysql_query() {
    MYSQL_PWD="$mysql_vsftpd_pwd" mysql \
        --host=127.0.0.1 \
        --user=vsftpd \
        --skip-column-names \
        --silent \
        "$MYSQL_DB" \
        -e "$1" \
        2>/dev/null
}

# Read password from stdin (provided by pam_exec expose_authtok)
read -r password || password=""

mysql_vsftpd_pwd=$(grep '^password=' /etc/vsftpd/.my.cnf 2>/dev/null | cut -d= -f2-)

# Reject empty credentials
if [[ -z "$PAM_USER" ]]; then
    fail "PAM_USER is empty or unset"
fi

if [[ -z "$password" ]]; then
    fail "No password was received on stdin"
fi

if [[ -z "$mysql_vsftpd_pwd" ]]; then
    fail "No MySQL password was found in /etc/vsftpd/.my.cnf"
fi

# Validate username: only allow hostname-safe characters (a-z A-Z 0-9 . _ -)
# This prevents SQL injection via PAM_USER
if [[ ! "$PAM_USER" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    fail "PAM_USER contains unsupported characters"
fi

# Hash the password with SHA-256
hash=$(printf '%s' "$password" | sha256sum | awk '{print $1}')

# Guard: ensure hash is exactly 64 lowercase hex characters
if [[ ! "$hash" =~ ^[0-9a-f]{64}$ ]]; then
    fail "Password hashing did not produce a valid SHA-256 hex digest"
fi

# Query MySQL - PAM_USER is regex-validated, hash is hex-only: no injection possible
result=$(mysql_query "SELECT COUNT(*) FROM passwd WHERE username='${PAM_USER}' AND passwd='${hash}' AND status='A';")
mysql_status=$?

if [[ "$mysql_status" -ne 0 ]]; then
    fail "MySQL query failed"
fi

if [[ ! "$result" =~ ^[0-9]+$ ]]; then
    fail "Unexpected MySQL result: ${result:-<empty>}"
fi

if [[ "$result" == "1" ]]; then
    success "Authentication succeeded"
fi

if [[ "$debug_enabled" -eq 1 ]]; then
    user_status=$(mysql_query "SELECT status FROM passwd WHERE username='${PAM_USER}' LIMIT 1;")
    mysql_status=$?

    if [[ "$mysql_status" -ne 0 ]]; then
        fail "MySQL status lookup failed"
    fi

    if [[ -z "$user_status" ]]; then
        fail "User '${PAM_USER}' was not found in virtualx.passwd"
    fi

    if [[ "$user_status" != "A" ]]; then
        fail "User '${PAM_USER}' exists but status is '${user_status}', not 'A'"
    fi

    fail "User '${PAM_USER}' exists and is active, but the password does not match"
fi

fail "Authentication failed"