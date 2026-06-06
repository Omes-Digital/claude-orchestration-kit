# Global instructions (all projects)

> Drop-in agent-orchestration layer for Claude Code. Put this file at `~/.claude/CLAUDE.md`
> (or paste the section below into your existing one). It pairs with the `agents/`,
> `skills/`, and `agent-memory/` directories in this bundle. See `INSTALL.md`.
>
> **New here?** This file shapes how Claude behaves in *every* project. Adopt it deliberately —
> see `START-HERE.md` (Level 2), and start with just a skill or two if you're not ready for that.

## Agent Orchestration — tier by task weight

Keep a frontier model as the **architect**; route bounded work **down** to a cheaper model. Frontier tokens are for design, cross-file judgement, and triage — not for mechanical edits. This is how you get the most from a token budget.

| Tier | Model | Use for |
|---|---|---|
| **Architect** | Opus (this session) | Design, drafting contracts, cross-file judgement, triage. Only role that amends a contract. |
| **Implementer — heavy** | `implementer-sonnet` (Sonnet) | Multi-file changes, cross-file invariants, schema/migration risk, service splits. Escalated default when task weight is unclear. |
| **Implementer — light** | `implementer-haiku` (Haiku) | Single-file, tightly-scoped, mechanical edits with no cross-file invariants. |

**As the architect:** for any implementation that is bounded and well-specified, hand it to `implementer-haiku` (single-file/mechanical) or `implementer-sonnet` (multi-file/cross-cutting) instead of doing it on Opus tokens. Give the sub-agent an explicit file list, the exact change, and the verification command. Reserve Opus for the design, the contract, and reviewing what comes back. When weight is unclear, escalate to Sonnet.

**Strict-mode executor rules** (what the implementers follow, and what the architect enforces when reviewing their output):
- Touch only the files named in the task; the out-of-scope list is a deny-list.
- Halt on the first FAIL or any unexpected state; report verbatim — no improvised recovery.
- Never amend the contract mid-execution; record the bug for the architect.
- Re-read after every edit; anchor search/replace patterns.
- No destructive git (`reset --hard`, `push --force`, `clean -fd`) and no migration downgrades.
- Never `git push`, never self-merge, don't commit unless asked — the human owns the push moment.

> **Optional local lane.** If you run a capable local model (e.g. Qwen via Aider/Ollama) you can add a third "free local tokens" tier for cheap bounded work, gated behind a machine check so it stays dormant on cloud-only machines. This bundle ships cloud-only; wire a local lane in yourself if you want one.

### Skills in orchestration

Skills are reusable prompts/workflows. Route them by phase and tier. **Mechanics that govern routing:**
- Personal skills (`~/.claude/skills/`) are available in **every** project; project skills (`.claude/skills/`) only in that repo. This section is the universal layer — it rides in this global file, so it applies everywhere without per-project copies.
- The model picks a skill from its own `description`/`when_to_use`, **not** from prose. So this table guides *the architect*; each implementer also carries its own "Skills you may reach for" block in its agent definition.
- Sub-agents **can** invoke skills, but a sub-agent **cannot spawn another sub-agent**. So orchestrating skills (`deep-research`, `code-review ultra`, `dispatch`) run **only in the architect/main session** — never delegate them into an implementer.

| Phase | Who runs it | Skills (examples) |
|---|---|---|
| Align / confirm scope | Architect (main) | `align` (confidence gate → confirmed brief, *before* any work) |
| Research / understand | Architect (main) | `deep-research` (web, orchestrating) · `Explore` agent (code) |
| Design / plan | Architect | `grill-me` · `grill-with-docs` · `prototype` · `to-prd` · `to-issues` · `Plan` agent |
| Decompose / delegate | Architect | `dispatch` (write the handoff contract + pick tier) · `triage` |
| Implement | implementer-sonnet / -haiku | `tdd` · `diagnose` · `frontend-design` · `claude-api` |
| Verify | implementer self-check → architect | `verify` · `run` (implementer); then `review-diff` (rubric) · `code-review` / `ultra` · `simplify` · `security-review` (architect, orchestrating) |
| Manage / handoff | Architect | `handoff` · `caveman` · `loop` · `schedule` |
| Harness / config | Architect (main only) | `update-config` · `fewer-permission-prompts` · `keybindings-help` |

**Default play.** (0) Ambiguous or under-specified request → `align` first: diverge, drive to ≥95% confidence in one batched question round, emit a confirmed brief — *before* spending tokens on the wrong contract. (1) Heavy or unclear design → keep on Opus; reach for a design skill (`grill-me` / `prototype`). (2) Bounded work → invoke `dispatch` to write the contract and pick the tier, then hand to **implementer-sonnet** (multi-file) or **implementer-haiku** (single-file). (3) The implementer reaches for `tdd` / `diagnose` while building and ends with `verify` / `run`. (4) Back on Opus: `code-review` (or `ultra`), `simplify`, `security-review` on the diff before the human's push moment.

**Hard rule:** never delegate an orchestrating skill (`deep-research`, `code-review ultra`, `dispatch`) into a spawned implementer — sub-agents can't spawn sub-agents. Run those in the architect session. Don't preload situational skills into implementers via the `skills:` frontmatter (it injects full text every run and bloats the cheap tier) — they're discoverable for on-demand invocation already.

**The bundled skills** (in `skills/`):
- `align` — session-start confidence gate: diverge on the request, reason each reading, reach ≥95% confidence in **one batched question round**, then emit a confirmed brief and hand to `dispatch`. The step *before* the contract — a wrong contract dispatched to a cheap tier costs more than a question asked on Opus. (Original to this kit.)
- `dispatch` — the orchestration centerpiece: strict-mode contract + tier pick + two-stage review gate (spec→quality) + evidence-based acceptance + plan-loop + parallel fan-out.
- `tdd` — Iron Law (no prod code without a failing test) + vertical-slice/tracer-bullet + a test-design toolkit + test taxonomy.
- `diagnose` — feedback-loop-first + root-cause Iron Law + 3-fix→question-architecture + error-recovery/untrusted-error-output.
- `review-diff` — multi-axis rubric + ≥80 confidence gate + severity labels + spec-vs-standards split; the rubric behind `dispatch`'s review gate (complements the built-in `/code-review`).

**Tier selection.** Use the *Plan → Execute → Review* pipeline: architect drafts the contract (Opus) → implementer executes (Haiku/Sonnet) → **review returns to the more capable tier** (Opus/Sonnet), never self-review. Haiku gate = "well-defined spec / established pattern / deterministic," not merely "small." **Forced-Opus triggers** (never let Sonnet silently absorb these): security-sensitive changes, cross-file invariant *design*, schema/migration risk. When weight is genuinely unknown, decide the tier at dispatch time rather than baking it in (default escalates to Sonnet). Reinforce context-isolation: each implementer sees only its contract's named files (the deny-list is the token-economy lever). Use bare `Opus`/`Sonnet`/`Haiku` — no version pins.

### Agent memory & self-improvement

Each orchestration role has **persistent, per-role memory** so agents stop relearning the same things every run. The design is grounded in CoALA (episodic/semantic/procedural memory), Cline's Memory Bank, and Anthropic's context-engineering write-ups. Two tiers:

- **Global (cross-project craft):** `~/.claude/agent-memory/<role>/MEMORY.md` — hand-curated by the architect. Roles: `architect` · `explorer` · `researcher` · `implementer` · `reviewer` · `auditor` · `memory-curator`. **This bundle ships the global tier, pre-seeded.**
- **Repo-local (project facts):** optional `.agent-memory/roles/<role>/MEMORY.md` inside a repo — for project-specific build/test facts. Curate by hand or point a small deterministic maintainer at it. Not required to get value from the global tier.

**The loop (architect-curated):** Read role memory at the start of role work → work → agents end with a `memory_proposal` block for reusable, evidence-backed learnings only → **the architect promotes** keepers (smallest durable artifact; recurring procedures graduate to a skill; mark stale, don't delete). CoALA: proposal (episodic) → `MEMORY.md` entry (semantic) → skill (procedural).

**Read-path caveat:** the `implementer-*` agent defs and the `review-diff` skill self-read their role memory. Built-in `Explore`/`Plan`/`general-purpose`/`security-review` **cannot** — when the architect dispatches one, it must **inject** the relevant `MEMORY.md` into the prompt. Keep every `MEMORY.md` short — context is a finite budget and long memory files rot. See `agent-memory/README.md`.
