#!/bin/bash
# https://mensfeld.pl/2013/04/backup-mysql-dump-all-your-mysql-databases-in-separate-files/

### Grundkonfiguration fuer den MySQL-Dump
###
###
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/mysql/$TIMESTAMP"
MYSQL_USER=root
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD=XXX
MYSQLDUMP=/usr/bin/mysqldump

### Alte Backup-Ordner loeschen, wenn das Datum im Ordnernamen aelter als 30 Tage ist
###
###
cleanup_before_epoch=$(date -d '30 days ago 00:00:00' +%s)

for backup_path in /home/mysql/*; do
  [ -d "$backup_path" ] || continue

  backup_name=$(basename "$backup_path")

  if ! backup_epoch=$(date -d "$backup_name" +%s 2>/dev/null); then
    continue
  fi

  if [ "$backup_epoch" -lt "$cleanup_before_epoch" ]; then
    rm -rf "$backup_path"
  fi
done

### Backup-Ordner fuer den heutigen Dump anlegen
###
###
mkdir -p "$BACKUP_DIR"

### Verfuegbare Datenbanken ermitteln und als gzip-Dumps sichern
###
###
databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.sql.gz"
done

### Alle Tabellen optimieren und reparieren
###
###
mysqlcheck -p$MYSQL_PASSWORD --auto-repair --optimize --all-databases