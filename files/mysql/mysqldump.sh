#!/bin/bash
# https://mensfeld.pl/2013/04/backup-mysql-dump-all-your-mysql-databases-in-separate-files/


TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/mysql/$TIMESTAMP"
MYSQL_USER=root
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD=XXX
MYSQLDUMP=/usr/bin/mysqldump

mkdir -p "$BACKUP_DIR"

databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.sql.gz"
done

### Optimize Tables
###
###
mysqlcheck -p$MYSQL_PASSWORD --auto-repair --optimize --all-databases