---
applyTo: "lib/lib_firewall.sh"
description: "Use when editing firewall setup logic. Preserve remote access safety, role-specific behavior for web vs DNS servers, and the contract with files/firewall assets."
---

# Firewall Instructions

- `lib/lib_firewall.sh` ist sicherheitskritisch. Aendere hier nichts breit oder spekulativ.
- Behalte immer die Notfall-Erreichbarkeit per SSH im Blick. Die Logik injiziert eine explizite Client-IP-Regel in `files/firewall/rules.fw`.
- Beruecksichtige die Serverrolle aus `vxs`: DNS-Server und Webserver erhalten unterschiedliche Firewall-Anpassungen.
- Aendere Platzhalter- oder `sed`-Ersetzungen nur, wenn klar ist, welche Zeilen in `files/firewall/rules.fw` dadurch konkret getroffen werden.
- Behandle `files/firewall/rules.fw`, `stop.sh`, `firewall.service` und `firewall-test` als zusammengehoeriges Paket, auch wenn du nur `lib/lib_firewall.sh` bearbeitest.
- Portbereiche nicht raten oder pauschalisieren. Im Repo ist `10000:10255` fachlich bereits belegt und darf nicht versehentlich fuer fremde Zwecke umgedeutet werden.
- Aendere Hardening-Regeln oder das Abschalten von `firewalld` nur mit klarer fachlicher Begruendung.
- Nach Aenderungen mindestens `bash -n lib/lib_firewall.sh` ausfuehren und zusaetzlich die betroffenen Ersatzmuster in `files/firewall/rules.fw` gegentesten.
