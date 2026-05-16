# feat: Introduce `_log` helper function in `functions.sh` for consistent output formatting

## Summary

All `lib/` scripts currently use raw `printf` with inline ANSI escape codes for status output:

```bash
printf "[\e[32mOK\e[0m] policycoreutils installiert\n"
printf "[\e[31mERROR\e[0m] policycoreutils konnte nicht installiert werden\n"
printf "[\e[36mINFO\e[0m] semanage fehlt – installiere policycoreutils-python-utils\n"
```

This pattern is repeated ~50+ times across the codebase with no single source of truth for colors, label names, or formatting.

## Problem

- ANSI escape codes are duplicated everywhere — a color change means touching every file
- Labels (`OK`, `ERROR`, `INFO`) and their colors are inconsistently applied across scripts
- No easy way to add features later (e.g. log-to-file, suppress color on non-TTY, `WARN` level)
- New contributors copy the inline pattern instead of a clean abstraction

## Proposed Solution

Add a small `_log` function to `lib/functions.sh` (already sourced by all scripts via `vxs`):

```bash
_log() {
    local level="${1^^}"   # ok | error | info | warn  →  uppercase
    shift
    local msg="$*"
    case "$level" in
        OK)    printf "[\e[32mOK\e[0m]    %s\n" "$msg" ;;
        ERROR) printf "[\e[31mERROR\e[0m] %s\n" "$msg" ;;
        INFO)  printf "[\e[36mINFO\e[0m]  %s\n" "$msg" ;;
        WARN)  printf "[\e[33mWARN\e[0m]  %s\n" "$msg" ;;
        *)     printf "[%s] %s\n" "$level" "$msg" ;;
    esac
}
```

Usage after migration:

```bash
_log ok    "policycoreutils installiert"
_log error "policycoreutils konnte nicht installiert werden"
_log info  "semanage fehlt – installiere policycoreutils-python-utils"
```

## Migration Strategy

Step-by-step, no Big Bang:

1. **Schritt 1** — `_log` in `functions.sh` einführen. Alle alten Skripte laufen unverändert weiter.
2. **Schritt 2** — `lib_selinux.sh` als Pilot vollständig migrieren (betrifft ~15 `printf`-Zeilen).
3. **Schritt 3** — Bei jeder folgenden Änderung an einem `lib/`-Skript: das Skript mitmigieren.
4. **Schritt 4** — (Optional, später) Einmaliger Cleanup aller verbleibenden Skripte.

## Affected Files

| File | Raw printf lines (approx.) |
|------|---------------------------|
| `lib/functions.sh` | — (Ziel der neuen Funktion) |
| `lib/lib_selinux.sh` | ~15 (Pilot) |
| `lib/lib_firewall.sh` | ~20 |
| `lib/lib_postfix.sh` | ~15 |
| `lib/lib_dovecot.sh` | ~10 |
| `lib/lib_vsftpd.sh` | ~10 |
| alle weiteren `lib/lib_*.sh` | jeweils 5–20 |

## Acceptance Criteria

- [ ] `_log ok|error|info|warn "message"` ist in `functions.sh` definiert und per `bash -n` + `shellcheck` geprüft
- [ ] `lib_selinux.sh` ist vollständig auf `_log` umgestellt, kein direktes ANSI-`printf` mehr
- [ ] Alle bestehenden Skripte laufen weiterhin korrekt (keine Regression)
- [ ] `copilot-instructions.md` enthält eine kurze Konventionszeile: _"Ausgaben immer via `_log ok|error|info|warn` — kein direktes printf mit ANSI-Codes"_

## Labels

`enhancement` · `refactor` · `dx` · `good first issue`
