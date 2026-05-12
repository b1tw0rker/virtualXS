---
applyTo: "files/certbot/hooks/*.sh"
description: "Use when editing Certbot DNS hook scripts under files/certbot/hooks. Preserve auth/cleanup symmetry, protect dns-config secrets, and avoid reintroducing obsolete Webmin behavior."
---

# Certbot Hook Instructions

- Diese Hooks arbeiten gegen PowerDNS per API und laden lokale, nicht versionierte Konfiguration aus `files/certbot/config/dns-config.conf`.
- Gib niemals Secrets aus `dns-config.conf` in Logs, Fehlermeldungen oder Beispielen aus.
- Halte `auto-hook.sh` und `cleanup-hook.sh` in Struktur, Logging und Fehlerbehandlung moeglichst symmetrisch, sofern die Aufgabe nicht bewusst asymmetrisches Verhalten verlangt.
- `auto-hook.sh` ist fail-fast: bei HTTP-Fehlern beendet der Hook den Lauf mit Exit-Code ungleich null. Verschlechtere dieses Verhalten nicht.
- `cleanup-hook.sh` darf Cleanup-Fehler protokollieren, soll aber nur dann haerter gemacht werden, wenn die Aufgabe das ausdruecklich verlangt.
- Reaktiviere oder erweitere auskommentierte Webmin-Restlogik nicht ohne expliziten Auftrag; im Repo gilt Webmin derzeit als auskommentierte Altlast.
- Wenn du JSON fuer RRsets aenderst, pruefe immer Name, Typ, Changetype und Quoting des TXT-Inhalts gemeinsam.
- Nach Aenderungen mindestens `bash -n` auf beiden Hook-Dateien ausfuehren, nicht nur auf der geaenderten Datei.
