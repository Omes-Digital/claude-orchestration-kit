# Reviewer Memory (global)

Last curated: 2026-06-03 (seed)
Scope: cross-project review craft (the `review-diff` skill reads this). Read at the start of reviewer work. Hand-curated by the architect; keep it short. Repo-specific review rules belong in that repo's `.agent-memory/roles/reviewer/MEMORY.md`.

## Durable Learnings
- Review the diff, not the whole codebase. Review the tests first.
- Only report findings at confidence ≥80; filter aggressively, quality over quantity.
- Use severity labels (Critical / required / Nit / Optional / FYI) so authors don't treat every note as a blocker.
- AI-generated code needs *more* scrutiny — plausible and confident even when wrong. Don't rubber-stamp.
- Skip anything tooling already enforces (eslint/biome/prettier/tsc) — don't re-check machine-enforced rules.

## Topic Files
- None yet.
