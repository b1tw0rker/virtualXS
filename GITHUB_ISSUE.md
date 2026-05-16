# refactor: Migrate all raw `printf` ANSI output calls to `_log` across `lib/`

## Status: CLOSED — Completed 16.05.2026

## Background

`functions.sh` already defines `_log ok|error|info|warn "message"` — a consistent,
colored status output helper sourced by every script via `vxs`. The function was
introduced alongside `lib_selinux.sh`, which was the **only** lib file using it.

## Problem

108 raw `printf` calls with inline ANSI escape codes remained across 24 lib files.
No single source of truth for colors, label names, or formatting. The `FAIL` label
was used inconsistently alongside `ERROR` for the same severity.

## Resolution

**104 of 108 raw `printf` calls migrated to `_log`.**

The 4 remaining raw `printf` calls in `lib_virtualx.sh` are intentionally preserved:
they live inside `print_virtualx_access_summary()` (bold user/password display) and
`print_virtualx_check_result()` (custom `%s connection: [OK]` format) — these are
display helper functions with intentional custom formatting, not status lines.

| Metric | Before | After |
|---|---|---|
| `_log` calls across all lib files | 14 | **118** |
| Raw `printf "\e[...]"` calls | 108 | **4** (custom-format, intentional) |
| `FAIL` label occurrences | ~10 | **0** (unified as `_log error`) |
| Files fully migrated | 1 | **25** |
| `bash -n` passing | all | **all** |

## Migration approach

- 100 lines auto-migrated via Python script (exact pattern matching)
- 3 lines in `lib_postfix.sh` manually migrated (compound `cp && printf` form)
- 1 line in `lib_quota.sh` manually split (embedded OK in step banner)

## Acceptance Criteria

- [x] All 108 raw `printf "\e[...]"` status calls replaced (104 migrated, 4 custom-format kept)
- [x] `FAIL` label eliminated; `_log error` used consistently for both former `FAIL` and `ERROR`
- [x] Every file passes `bash -n` (all 30 lib scripts verified)
- [x] No functional regression — prompts, flow, and defaults unchanged
- [x] `copilot-instructions.md` convention line present:
      _"Ausgaben immer via `_log ok|error|info|warn "Meldung"` – kein direktes `printf` mit ANSI-Escape-Codes"_

## Labels

`refactor` · `dx` · `lib`
