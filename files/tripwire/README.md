# Tripwire Konfiguration für VirtualXS

## Übersicht
Diese Konfiguration erweitert Tripwire um VirtualXS-spezifische Überwachungsregeln.

## Überwachte Verzeichnisse

### Standard-Verzeichnisse
- `/etc/` - Systemkonfiguration
- `/bin/`, `/sbin/` - Systembinärdateien
- `/usr/bin/`, `/usr/sbin/` - Benutzerbinärdateien

### VirtualXS-spezifische Verzeichnisse
- `/home/httpd/` - Web-Content (mit SEC_BIN Regeln)
- `/var/log/httpd/` - Apache-Logs
- `/var/log/php-fpm/` - PHP-FPM Logs
- `/var/log/mysql/` - MySQL/MariaDB Logs
- `/var/log/postfix/` - Postfix Logs
- `/var/log/dovecot/` - Dovecot Logs

### Wichtige Konfigurationsdateien
- `/etc/httpd/conf/httpd.conf` - Apache-Konfiguration
- `/etc/php.ini` - PHP-Konfiguration
- `/etc/my.cnf` - MySQL/MariaDB Konfiguration
- `/etc/postfix/main.cf` - Postfix-Konfiguration
- `/etc/dovecot/dovecot.conf` - Dovecot-Konfiguration

## Verwendung

### Integritätsprüfung durchführen
```bash
tripwire --check
```

### Interaktive Integritätsprüfung mit Report
```bash
tripwire --check --interactive
```

### Datenbank nach legitimen Änderungen aktualisieren
```bash
tripwire --update
```

### Policy-Datei bearbeiten
```bash
tripwire --update-policy /etc/tripwire/twpol.txt
```

## Installation
Die Installation erfolgt automatisch über das VirtualXS-Installationsskript (`vxs`).
Tripwire wird bei der Frage "Install & Configure Tripwire [y/N]:" aktiviert.

## Hinweise
- Bei der Initialisierung werden Passphrases für Site-Key und Local-Key abgefragt
- Diese Passphrases sollten sicher aufbewahrt werden
- Regelmäßige Integritätsprüfungen werden empfohlen
- Bei DNS-Servern wird Tripwire automatisch aktiviert