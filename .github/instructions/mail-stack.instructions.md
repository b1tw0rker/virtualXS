---
description: "Use when editing the mail and auth stack around Postfix, Dovecot, and VSFTPD. Preserve MySQL-backed authentication assumptions, TLS/certificate paths, and service interplay."
---

# Mail And Auth Stack Instructions

- Diese Anweisung gilt fuer Aenderungen rund um `lib/lib_postfix.sh`, `lib/lib_dovecot.sh`, `lib/lib_vsftpd.sh` sowie die zugehoerigen Templates unter `files/postfix/`, `files/dovecot/` und `files/vsftpd/`.
- Behandle Postfix, Dovecot und VSFTPD hier nicht als isolierte Einzelteile. In diesem Repo teilen sie sich Annahmen zu Benutzern, Passwoertern, TLS-Dateien und Authentifizierung ueber lokale Konfigurationsbausteine.
- Aendere Pfade, Benutzernamen, PAM-Referenzen, SQL-Konfigurationsdateien oder Zertifikatspfade nur, wenn du den ganzen betroffenen Ablauf nachvollzogen hast.
- Viele Werte werden zur Laufzeit per `sed`, `postconf` oder direktem Dateiersatz in Systemdateien geschrieben. Pruefe immer, welche Datei am Ende wirklich wirksam ist.
- In `lib/lib_dovecot.sh` und `lib/lib_vsftpd.sh` wird das MySQL-Passwort in ausgelieferte Konfigurationsdateien eingesetzt. Gib diese Werte niemals in Logs, Beispielen oder Fehlermeldungen aus.
- In `lib/lib_vsftpd.sh` wird die Distro-Konfiguration nicht komplett neu erzeugt, sondern erweitert und punktuell ueberschrieben. Verlasse dich deshalb nicht darauf, dass nur die Repo-Datei den Endzustand bestimmt.
- In `lib/lib_postfix.sh` existiert ein explizit als ungetestet markierter `header_checks`-Block. Erweitere oder refactore diesen Teil nicht ohne klaren Grund und gezielte Pruefung.
- Bei TLS-Aenderungen immer pruefen, ob Zertifikatspfade zum echten Laufzeitkontext passen; im Repo werden Lets-Encrypt-Dateien je nach Dienst unterschiedlich referenziert.
- Aendere Service-Reloads, Aktivierungslogik oder Abhaengigkeiten nur sparsam. Schon kleine Aenderungen koennen Login, Mailzustellung oder FTPS brechen.
- Vor kritischen Aenderungen in diesem Bereich Backups unter `_obsolete/` anlegen, wie in der globalen Copilot-Anweisung beschrieben.
- Nach Aenderungen mindestens `bash -n` fuer die betroffenen `lib/`-Skripte ausfuehren. Wenn Templates betroffen sind, pruefe zusaetzlich die daraus resultierenden Zielpfade und Ersetzungslogik.