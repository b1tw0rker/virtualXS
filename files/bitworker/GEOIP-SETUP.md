# GeoIP-Einrichtung für goaccess

Für die Länder-Statistik in den GoAccess-Reports (`--geoip-database`) wird
eine MaxMind-kompatible Country-mmdb benötigt. Die kostenlose DB-IP
Country-Lite-Datenbank ist ein funktionierender Ersatz.

- Verzeichnis anlegen: `mkdir -p /usr/share/GeoIP/`
- Aktuelle Download-URL hat das Format
  `https://download.db-ip.com/free/dbip-country-lite-YYYY-MM.mmdb.gz`
  (Jahr/Monat der aktuellen Veröffentlichung einsetzen)
- `curl -sSL -o /tmp/dbip-country-lite.mmdb.gz "https://download.db-ip.com/free/dbip-country-lite-YYYY-MM.mmdb.gz"`
- `gunzip -c /tmp/dbip-country-lite.mmdb.gz > /usr/share/GeoIP/GeoLite2-Country.mmdb`
- `chmod 644 /usr/share/GeoIP/GeoLite2-Country.mmdb`
- `/tmp/dbip-country-lite.mmdb.gz` löschen

`bw-goaccess-generator.sh` erkennt automatisch, ob
`/usr/share/GeoIP/GeoLite2-Country.mmdb` existiert, und aktiviert
`--geoip-database` nur dann - fehlt die Datei, laufen die Statistiken auch
ohne Länder-Auswertung weiter.
