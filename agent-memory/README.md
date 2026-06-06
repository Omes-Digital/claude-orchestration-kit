# Agent memory & self-improvement — GLOBAL tier

Cross-project, per-role memory for the orchestration tiers. This is the **user-level** half of a two-tier system:

| Tier | Where | Holds | Maintained by |
|---|---|---|---|
| **Global (this dir)** | `~/.claude/agent-memory/<role>/MEMORY.md` | cross-project role *craft* | architect, by hand (low-churn, single-user) |
| **Repo-local** | each repo's `.agent-memory/roles/<role>/MEMORY.md` | project-specific facts | a repo-local maintainer (e.g. a daily cron) + architect |

**This bundle ships only the global tier** (the directory you're reading) — it needs no tooling; the architect curates it by hand. The repo-local tier is optional: drop the same `.agent-memory/roles/<role>/` layout into a project and point a small deterministic maintainer script (or just curate by hand) at it to give that repo its own memory. The global tier alone is enough to get started.

## Roles
`architect` · `explorer` · `researcher` · `implementer` (sonnet+haiku) · `reviewer` · `auditor` · `memory-curator` — matching the kit.

## The loop (architect-curated — Anthropic "Dreaming" done by hand)
1. **Read.** At the start of role work, consult `<role>/MEMORY.md` (global) and, in a repo, that repo's `.agent-memory/roles/<role>/MEMORY.md`.
2. **Work.**
3. **Propose.** End meaningful work with a `memory_proposal` block (format below) — *only* for reusable, evidence-backed learnings. No transcript summaries or one-off task state.
4. **Curate.** The architect (or the `memory-curator` role) promotes keepers — use the `memory-curate` skill to triage, `memory-maintain` to run the repo-local maintainer. Promote the smallest durable artifact; recurring procedures graduate to a skill; mark stale entries, don't delete.

CoALA framing: **episodic** (the proposal) → **semantic** (a `MEMORY.md` entry) → **procedural** (a skill).

## Read-path caveat
We own the `implementer-*` agent defs and the `review-diff` skill → they self-read their role memory. We do **not** own built-in `Explore`/`Plan`/`general-purpose`/`security-review` → the architect must **inject** the relevant `MEMORY.md` into their spawn prompt.

## `memory_proposal` format (shared with the kit)
```yaml
memory_proposal:
  role: architect | explorer | researcher | implementer | reviewer | auditor | memory-curator
  scope: project | user | local
  type: convention | invariant | workflow | pitfall | source | eval | risk
  confidence: observed_once | repeated | verified
  evidence:
    - path, command, source URL, or review finding
  proposed_entry: concise durable memory text
  suggested_target: .agent-memory/roles/<role>/MEMORY.md   # or ~/.claude/agent-memory/<role>/MEMORY.md for global craft
  review_after: YYYY-MM-DD or "on next related change"
```

## Bounds
Keep each `MEMORY.md` short — context is a finite attention budget and long memory files rot (Anthropic context-engineering). Consolidate when a file grows; move detail to a topic file linked from the index.

## Enabling automation on the global tier (optional, later)
This tier is hand-curated. To put it under the same daily maintainer, deploy a kit instance with the canonical `.agent-memory/roles/` layout and point `memory_maintainer.py --root` at it. Not wired today.
