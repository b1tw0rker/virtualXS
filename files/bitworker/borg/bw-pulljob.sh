#!/bin/bash

### Borg pull-controlled backup job.

set -euo pipefail

script=$(readlink -f "$0")
script_dir=$(dirname "$script")
start_ts=$(date +%s)

find_config_file() {
   if [ -n "${CONFIG_FILE:-}" ]; then
      printf "%s\n" "$CONFIG_FILE"
      return
   fi

   if [ -r "$script_dir/config.cf" ]; then
      printf "%s\n" "$script_dir/config.cf"
      return
   fi

   if [ -r "$script_dir/borg-setup/192.168.0.10.conf" ]; then
      printf "%s\n" "$script_dir/borg-setup/192.168.0.10.conf"
      return
   fi

   printf "%s\n" "/etc/bitworker/borg/192.168.0.10.conf"
}

CONFIG_FILE=$(find_config_file)

if [ ! -r "$CONFIG_FILE" ]; then
   echo "ERROR: Config nicht lesbar: $CONFIG_FILE" >&2
   exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

ACTION="${1:-backup}"
RUN_TS="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_NAME="${JOB_NAME}-${RUN_TS}"
REPOSITORY_URL="ssh://${REPOSITORY_SSH_USER}@${BACKUP_HOST}${REPOSITORY_PATH}"
LOG_FILE="${LOG_DIR}/${JOB_NAME}-${RUN_TS}.log"

ssh_opts=(
   -i "$SSH_KEY"
   -o BatchMode=yes
   -o StrictHostKeyChecking=accept-new
   -o ConnectTimeout="$SSH_CONNECT_TIMEOUT"
)

die() {
   echo "ERROR: $*" >&2
   exit 1
}

quote() {
   printf "%q" "$1"
}

format_duration() {
   local total_seconds=$1
   local hours=$((total_seconds / 3600))
   local minutes=$(((total_seconds % 3600) / 60))
   local seconds=$((total_seconds % 60))

   printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"
}

resolve_job_file() {
   local configured_path=$1
   local basename_path
   local fallback_path

   if [ -f "$configured_path" ]; then
      printf "%s\n" "$configured_path"
      return
   fi

   basename_path=$(basename "$configured_path")
   fallback_path="$(dirname "$CONFIG_FILE")/$basename_path"

   if [ -f "$fallback_path" ]; then
      printf "%s\n" "$fallback_path"
      return
   fi

   printf "%s\n" "$configured_path"
}

validate_settings() {
   [ -n "${JOB_NAME:-}" ] || die "JOB_NAME fehlt in $CONFIG_FILE"
   [ -n "${SOURCE_SSH:-}" ] || die "SOURCE_SSH fehlt in $CONFIG_FILE"
   [ -n "${SOURCE_HOST:-}" ] || die "SOURCE_HOST fehlt in $CONFIG_FILE"
   [ -n "${BACKUP_HOST:-}" ] || die "BACKUP_HOST fehlt in $CONFIG_FILE"
   [ -n "${REPOSITORY_SSH_USER:-}" ] || die "REPOSITORY_SSH_USER fehlt in $CONFIG_FILE"
   [ -n "${REPOSITORY_PATH:-}" ] || die "REPOSITORY_PATH fehlt in $CONFIG_FILE"
   [ -n "${PATHS_FILE:-}" ] || die "PATHS_FILE fehlt in $CONFIG_FILE"
   [ -n "${PATTERNS_FILE:-}" ] || die "PATTERNS_FILE fehlt in $CONFIG_FILE"
   [ -n "${LOG_DIR:-}" ] || die "LOG_DIR fehlt in $CONFIG_FILE"
   [ -n "${BORG_PASSPHRASE:-}" ] || die "BORG_PASSPHRASE fehlt in $CONFIG_FILE"
   [ -n "${BORG_COMPRESSION:-}" ] || die "BORG_COMPRESSION fehlt in $CONFIG_FILE"
   [ -n "${KEEP_DAILY:-}" ] || die "KEEP_DAILY fehlt in $CONFIG_FILE"
   [ -n "${KEEP_WEEKLY:-}" ] || die "KEEP_WEEKLY fehlt in $CONFIG_FILE"
   [ -n "${KEEP_MONTHLY:-}" ] || die "KEEP_MONTHLY fehlt in $CONFIG_FILE"
   [ -n "${REMOTE_BORG:-}" ] || die "REMOTE_BORG fehlt in $CONFIG_FILE"
   [ -n "${SSH_KEY:-}" ] || die "SSH_KEY fehlt in $CONFIG_FILE"
   [ -n "${SSH_CONNECT_TIMEOUT:-}" ] || die "SSH_CONNECT_TIMEOUT fehlt in $CONFIG_FILE"

   case "${ONE_FILE_SYSTEM:-true}" in
      true|false)
         ;;
      *)
         die "ONE_FILE_SYSTEM muss true oder false sein in $CONFIG_FILE"
         ;;
   esac

   [[ "$REPOSITORY_PATH" == /* ]] || die "REPOSITORY_PATH muss absolut sein: $REPOSITORY_PATH"
   [[ "$LOG_DIR" == /* ]] || die "LOG_DIR muss absolut sein: $LOG_DIR"
}

prepare_logging() {
   mkdir -p "$LOG_DIR"
   chmod 700 "$LOG_DIR"
   exec > >(tee -a "$LOG_FILE") 2>&1
}

ssh_source() {
   ssh "${ssh_opts[@]}" "$SOURCE_SSH" "$@"
}

scp_to_source() {
   scp "${ssh_opts[@]}" "$@"
}

require_file() {
   local file=$1
   [ -f "$file" ] || die "Datei fehlt: $file"
}

filter_config_file() {
   local input=$1
   local output=$2

   awk '
      {
         sub(/\r$/, "")
         sub(/^[[:space:]]+/, "")
         sub(/[[:space:]]+$/, "")
      }
      $0 == "" { next }
      /^#/ { next }
      { print }
   ' "$input" > "$output"
}

init_repo() {
   mkdir -p "$REPOSITORY_PATH"
   chmod 700 "$REPOSITORY_PATH"

   if [ -f "$REPOSITORY_PATH/config" ]; then
      echo "Repository existiert bereits: $REPOSITORY_PATH"
      return
   fi

   if [ -n "$(find "$REPOSITORY_PATH" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
      die "Zielordner ist nicht leer und kein Borg-Repository: $REPOSITORY_PATH
Bitte vorhandenen Inhalt beiseitelegen oder REPOSITORY_PATH auf einen leeren Ordner setzen."
   fi

   echo "Initialisiere Borg-Repository: $REPOSITORY_PATH"
   BORG_PASSPHRASE="$BORG_PASSPHRASE" borg init --encryption=repokey-blake2 "$REPOSITORY_PATH"
}

prepare_remote_tmp() {
   ssh_source "mktemp -d /tmp/borg-${JOB_NAME}.XXXXXX"
}

cleanup_remote_tmp() {
   local remote_tmp=$1

   [ -n "$remote_tmp" ] || return
   ssh_source "rm -rf $(quote "$remote_tmp")" >/dev/null 2>&1 || true
}

copy_job_files_to_source() {
   local remote_tmp=$1
   local paths_tmp=$2
   local patterns_tmp=$3

   scp_to_source "$paths_tmp" "${SOURCE_SSH}:${remote_tmp}/paths" >/dev/null
   scp_to_source "$patterns_tmp" "${SOURCE_SSH}:${remote_tmp}/patterns" >/dev/null
}

run_remote_backup() {
   local remote_tmp=$1
   local remote_repo
   local remote_archive
   local remote_compression
   local remote_one_file_system
   local remote_borg

   remote_repo=$(quote "$REPOSITORY_URL")
   remote_archive=$(quote "$ARCHIVE_NAME")
   remote_compression=$(quote "$BORG_COMPRESSION")
   remote_one_file_system=$(quote "${ONE_FILE_SYSTEM:-true}")
   remote_borg=$(quote "$REMOTE_BORG")

   ssh_source "bash -s" <<REMOTE_SCRIPT
set -euo pipefail

export BORG_REPO=$remote_repo
export BORG_PASSPHRASE=$(quote "$BORG_PASSPHRASE")

remote_tmp=$(quote "$remote_tmp")
archive_name=$remote_archive
compression=$remote_compression
one_file_system=$remote_one_file_system
borg_bin=$remote_borg

command -v "\$borg_bin" >/dev/null 2>&1 || {
   echo "ERROR: Borg ist auf dem Quellserver nicht installiert: \$borg_bin" >&2
   exit 1
}

strip_trailing_slashes() {
   local value=\$1

   while [ "\$value" != "/" ] && [[ "\$value" == */ ]]; do
      value="\${value%/}"
   done

   printf '%s\n' "\$value"
}

paths_file="\$remote_tmp/paths"
patterns_file="\$remote_tmp/patterns"
resolved_file="\$remote_tmp/resolved-paths"

while IFS= read -r path || [ -n "\$path" ]; do
   normalized_path=\$(strip_trailing_slashes "\$path")

   case "\$path" in
      *['*''?''[']*)
         match_count=0
         while IFS= read -r match; do
            [ -n "\$match" ] || continue
            printf '%s\n' "\$(strip_trailing_slashes "\$match")"
            match_count=\$((match_count + 1))
         done < <(compgen -G "\$normalized_path" || true)
         if [ "\$match_count" -eq 0 ]; then
            echo "WARNUNG: Muster ohne Treffer: \$path" >&2
         fi
         ;;
      *)
         if [ -e "\$normalized_path" ]; then
            printf '%s\n' "\$normalized_path"
         else
            echo "WARNUNG: Pfad existiert nicht: \$path" >&2
         fi
         ;;
   esac
done < "\$paths_file" > "\$resolved_file"

if [ ! -s "\$resolved_file" ]; then
   echo "ERROR: Keine gueltigen Quellpfade gefunden." >&2
   exit 1
fi

mapfile -t resolved_paths < "\$resolved_file"

create_args=(
   create
   --verbose
   --stats
   --show-rc
   --compression "\$compression"
   --numeric-ids
   --patterns-from "\$patterns_file"
)

if [ "\$one_file_system" = "true" ]; then
   create_args+=(--one-file-system)
fi

"\$borg_bin" "\${create_args[@]}" "::\$archive_name" "\${resolved_paths[@]}"
REMOTE_SCRIPT
}

run_backup() {
   local paths_tmp=""
   local patterns_tmp=""
   local remote_tmp=""

   cleanup() {
      [ -z "${paths_tmp:-}" ] || rm -f "$paths_tmp"
      [ -z "${patterns_tmp:-}" ] || rm -f "$patterns_tmp"
      cleanup_remote_tmp "${remote_tmp:-}"
   }

   PATHS_FILE=$(resolve_job_file "$PATHS_FILE")
   PATTERNS_FILE=$(resolve_job_file "$PATTERNS_FILE")

   require_file "$PATHS_FILE"
   require_file "$PATTERNS_FILE"
   init_repo

   paths_tmp=$(mktemp)
   patterns_tmp=$(mktemp)
   trap cleanup EXIT

   filter_config_file "$PATHS_FILE" "$paths_tmp"
   filter_config_file "$PATTERNS_FILE" "$patterns_tmp"

   echo "Pruefe SSH zum Quellserver: $SOURCE_SSH"
   ssh_source "true"

   remote_tmp=$(prepare_remote_tmp)
   copy_job_files_to_source "$remote_tmp" "$paths_tmp" "$patterns_tmp"

   echo "Starte Borg-Pull-Backup $ARCHIVE_NAME von $SOURCE_HOST nach $REPOSITORY_URL"
   run_remote_backup "$remote_tmp"
   echo "Backup abgeschlossen: $ARCHIVE_NAME"
}

run_prune() {
   init_repo
   echo "Bereinige alte Archive in $REPOSITORY_PATH"
   BORG_PASSPHRASE="$BORG_PASSPHRASE" borg prune \
      --list \
      --stats \
      --keep-daily "$KEEP_DAILY" \
      --keep-weekly "$KEEP_WEEKLY" \
      --keep-monthly "$KEEP_MONTHLY" \
      "$REPOSITORY_PATH"
}

run_compact() {
   init_repo
   echo "Kompaktiere Repository $REPOSITORY_PATH"
   BORG_PASSPHRASE="$BORG_PASSPHRASE" borg compact "$REPOSITORY_PATH"
}

run_check() {
   init_repo
   echo "Pruefe Repository $REPOSITORY_PATH"
   BORG_PASSPHRASE="$BORG_PASSPHRASE" borg check --repository-only "$REPOSITORY_PATH"
}

run_list() {
   init_repo
   BORG_PASSPHRASE="$BORG_PASSPHRASE" borg list "$REPOSITORY_PATH"
}

run_doctor() {
   echo "Lokaler Host: $(hostname -f 2>/dev/null || hostname)"
   echo "Quellserver: $SOURCE_SSH"
   echo "Repository lokal: $REPOSITORY_PATH"
   echo "Repository remote: $REPOSITORY_URL"
   echo "Config: $CONFIG_FILE"
   echo "Pfadliste: $(resolve_job_file "$PATHS_FILE")"
   echo "Patternliste: $(resolve_job_file "$PATTERNS_FILE")"
   echo
   echo "SELinux:"
   if command -v getenforce >/dev/null 2>&1; then
      getenforce
   else
      echo "getenforce nicht gefunden"
   fi
   echo
   echo "Lokales Borg:"
   borg --version
   echo
   echo "SSH zum Quellserver:"
   ssh_source "hostname; command -v borg; borg --version"
   echo
   echo "Rueckweg vom Quellserver zum Backup-Repository:"
   ssh_source "ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=$(quote "$SSH_CONNECT_TIMEOUT") $(quote "${REPOSITORY_SSH_USER}@${BACKUP_HOST}") 'hostname; command -v borg; borg --version'"
}

main() {
   validate_settings
   prepare_logging

   case "$ACTION" in
      init)
         init_repo
         ;;
      backup|pull)
         run_backup
         run_prune
         run_compact
         ;;
      prune)
         run_prune
         ;;
      compact)
         run_compact
         ;;
      check)
         run_check
         ;;
      list)
         run_list
         ;;
      doctor)
         run_doctor
         ;;
      *)
         echo "Usage: $0 [init|backup|pull|prune|compact|check|list|doctor]" >&2
         exit 2
         ;;
   esac

   end_ts=$(date +%s)
   echo "Runtime: $(format_duration "$((end_ts - start_ts))")"
}

main "$@"
