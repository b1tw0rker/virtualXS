#!/bin/bash
#
# bw-vsftpd-pam-userlogin-check.sh
# PAM exec authentication script for vsftpd against virtualx MySQL db.
#
# Called by pam_exec with expose_authtok; password arrives on stdin.
# PAM_USER is set as environment variable by PAM.
#
# Deployed to: /etc/bitworker/bw-vsftpd-pam-userlogin-check.sh (chmod 700, root:root)
# MySQL client credentials are read from /root/.my.cnf
# Password hash in DB: SHA-512-crypt ($6$salt$hash) - verified via openssl passwd -6
#
# Test on terminal:
# echo 'PASSWORD' | PAM_USER=srv016.host-x.de /etc/bitworker/bw-vsftpd-pam-userlogin-check.sh --debug; echo "Exit code: $?"
# Exit code 0 = success, 1 = failure
# Debug mode prints the failure reason to stderr and is intended for manual tests only.

MYSQL_DB="virtualx"
MYSQL_TABLE="ftp_accounts"
MYSQL_DEFAULTS_FILE="/root/.my.cnf"
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
    mysql \
        --defaults-file="$MYSQL_DEFAULTS_FILE" \
        --skip-column-names \
        --silent \
        "$MYSQL_DB" \
        -e "$1" \
        2>/dev/null
}

# Read password from stdin (provided by pam_exec expose_authtok)
# Akzeptiere sowohl NUL- als auch Newline-terminierte Passwörter (pam_exec: kein \n, ggf. NUL)
IFS= read -r -d '' password 2>/dev/null || true
if [[ -z "$password" ]]; then
    IFS= read -r password 2>/dev/null || true
fi

# Reject empty credentials
if [[ -z "$PAM_USER" ]]; then
    fail "PAM_USER is empty or unset"
fi

if [[ -z "$password" ]]; then
    fail "No password was received on stdin"
fi

if [[ ! -r "$MYSQL_DEFAULTS_FILE" ]]; then
    fail "MySQL defaults file is missing or unreadable: $MYSQL_DEFAULTS_FILE"
fi

# Validate username: only allow hostname-safe characters (a-z A-Z 0-9 . _ -)
# This prevents SQL injection via PAM_USER
if [[ ! "$PAM_USER" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    fail "PAM_USER contains unsupported characters"
fi

# Fetch stored hash for active user - PAM_USER is regex-validated: no injection possible
stored_hash=$(mysql_query "SELECT password_hash FROM ${MYSQL_TABLE} WHERE username='${PAM_USER}' AND status='active' LIMIT 1;")
mysql_status=$?

if [[ "$mysql_status" -ne 0 ]]; then
    fail "MySQL query failed"
fi

if [[ -z "$stored_hash" ]]; then
    if [[ "$debug_enabled" -eq 1 ]]; then
        user_status=$(mysql_query "SELECT status FROM ${MYSQL_TABLE} WHERE username='${PAM_USER}' LIMIT 1;")
        if [[ -z "$user_status" ]]; then
            fail "User '${PAM_USER}' was not found in ${MYSQL_DB}.${MYSQL_TABLE}"
        else
            fail "User '${PAM_USER}' exists but status is '${user_status}', not 'active'"
        fi
    fi
    fail "Authentication failed"
fi

# Guard: stored hash must be SHA-512-crypt format
if [[ ! "$stored_hash" =~ ^\$6\$ ]]; then
    fail "Stored hash is not in expected SHA-512-crypt format (\$6\$)"
fi

# Verify password against stored hash - password passed via stdin, never in process args
salt=$(printf '%s' "$stored_hash" | cut -d'$' -f3)
computed=$(printf '%s' "$password" | openssl passwd -6 -salt "$salt" -stdin 2>/dev/null)

if [[ "$computed" == "$stored_hash" ]]; then
    success "Authentication succeeded"
fi

if [[ "$debug_enabled" -eq 1 ]]; then
    fail "User '${PAM_USER}' exists and is active, but the password does not match"
fi

fail "Authentication failed"
