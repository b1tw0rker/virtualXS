---
applyTo: "helper/**"
description: "Use when editing RPM build, deploy, release, or packaging helper files. Keep version synchronization, RPM metadata, and deployed artifact paths consistent."
---

# Packaging Instructions

- `helper/build.sh`, `helper/deploy.sh`, `helper/git.sh` und `helper/virtualXS.spec` bilden zusammen den verifizierten Packaging-Workflow dieses Repos.
- Wenn du Versionierung anfasst, halte mindestens `helper/virtualXS.spec`, `vxs` und die README-Version konsistent.
- Fuehre keinen parallelen Build- oder Deploy-Workflow ein, solange der bestehende Helper-Pfad weiterverwendet werden kann.
- Aendere Zielpfade, Dateirechte, `%files`-Eintraege oder Symlink-Verhalten in der Spec nur bewusst und mit Blick auf das installierte System.
- Behandle Dry-Run-, Signatur-, Upload- und Repo-Update-Logik in `helper/deploy.sh` als Betriebslogik, nicht als rein kosmetischen Code.
- Wenn du Build-Skripte aenderst, pruefe immer auch, welche Dateien sie implizit synchron halten oder kopieren.
- Vor kritischen Packaging-Aenderungen Backups unter `_obsolete/` anlegen, wie in der globalen Copilot-Anweisung beschrieben.
- Nach Aenderungen mindestens `bash -n` auf den betroffenen Helper-Skripten ausfuehren; bei Spec-Aenderungen zusaetzlich die geaenderten `%files`- und Pfadannahmen gegen den Repo-Aufbau pruefen.