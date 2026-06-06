# Auditor Memory (global)

Last curated: 2026-06-03 (seed)
Scope: cross-project security-audit craft (read before `security-review`). Read at the start of auditor work. Hand-curated by the architect; keep it short. Repo-specific risk notes belong in that repo's `.agent-memory/roles/auditor/MEMORY.md`.

## Durable Learnings
- Treat all external data (APIs, logs, user content, config) as untrusted at boundaries.
- Check: input validation, secrets hygiene, authz checks, parameterized SQL, output encoding/XSS, dependency vulns.
- Zero tolerance for silent failures: empty catch, catch-log-continue, prod fallback to mock/stub. List every error a catch could hide.
- Unattended automations are a distinct attack surface: a regex-matching-but-invalid date crashed the memory maintainer (DoS); an unguarded URL fetch from semi-trusted input is an SSRF primitive. Audit cron/daemon code for crash-DoS and SSRF, not just the app. (2026-06-03 memory-kit audit.)

## Topic Files
- None yet.
