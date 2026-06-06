# Global instructions (all projects)

> A disciplined **frontier-first** workflow for Claude Code, with multi-agent orchestration as an
> **opt-in scaling tool** — not the default. Put this file at `~/.claude/CLAUDE.md` (or paste the
> sections below into your existing one). It pairs with the `agents/`, `skills/`, and `agent-memory/`
> directories in this bundle. See `INSTALL.md`.
>
> **Why "opt-in"?** This kit ships an A/B harness (`ab-test/`) and we ran it. Across three tasks
> (greenfield → a cross-cutting change in an existing repo), routing bounded work down to cheaper
> sub-agents cost **+14–24%** and **~2× the wall-clock** for **identical** correctness — a frontier
> model held each task in one pass and the review gate caught nothing. So the guidance below is
> frontier-first: do the work yourself; orchestrate only to *scale*. Receipts: `ab-test/FINDINGS.md`.
>
> **New here?** This file shapes how Claude behaves in *every* project. Adopt it deliberately —
> see `START-HERE.md` (Level 2), and start with just a skill or two if you're not ready for that.

## Working model — frontier-first; orchestrate only to scale

**Default: do the work yourself, in this session, on the strongest model you have.** A capable frontier model holds a normal task — including a cross-cutting change across an existing multi-file codebase — in one context and gets it right in a single pass. Spend your tokens on *doing the task well*, not on the machinery of handing it off.

**"Strongest" ≠ "always Opus."** Opus is only ~1.67× Sonnet's price ($5/$25 vs $3/$15) and slower; for *most* coding the right single pass is **Sonnet**, with Opus reserved for genuinely hard design and Haiku for mechanical edits. Default the session to Sonnet and `/model opus` to escalate (the kit ships an opt-in `settings.efficiency.json`). Frontier-first means the *right* model in one pass, not the priciest — full evidence + levers in [`docs/EFFICIENCY.md`](docs/EFFICIENCY.md). (When you *do* orchestrate hard or big work, the architect role still wants Opus — the tier table below.)

**Effort is a second dial — *which model* × *how hard it thinks* (`/effort`).** Model choice sets capability and $/token; effort sets how much reasoning the model spends per step. They're orthogonal — pick both. Levels: `low` · `medium` · `high` (default) · `xhigh` · `max`; on Opus 4.8/4.7 a level is an *upper bound* the model draws on adaptively by complexity, not forced spend. Map it to the task like the model split — `low`/`medium` for mechanical/well-specified work, `high` for most work, `xhigh` for the hard design / cross-file / gnarly-diagnosis cases that also justify `/model opus`, `max` only when `xhigh` stalls (it overthinks). For a *reasoning-bound* (not knowledge-bound) task, Sonnet at `xhigh` can beat Opus at `low` — reach for effort before price. Caveats: **Haiku has no effort control** (another reason `implementer-haiku` is mechanical-only), and switching model **resets** effort to the new model's default. Full ladder + mechanics (`ultrathink`, `effortLevel`, env precedence, `ultracode`): [`docs/EFFICIENCY.md`](docs/EFFICIENCY.md).

**This kit measured its own dispatch, and on everyday work it lost.** Across three `ab-test/` tasks (greenfield → a cross-cutting change in an *existing* repo), routing the bounded implementation to a cheaper sub-agent cost **+14–24% and ~2× the wall-clock for identical correctness** every time — both arms passed, zero rework. The cause is an **isolation tax**: a sub-agent gets a *fresh* context and re-pays full freight to read what the architect already cached, so you pay one model to design+review **and** another to re-read+implement — strictly more than one pass. The review gate caught nothing, because a single pass didn't fail. Full table + caveats: [`ab-test/FINDINGS.md`](ab-test/FINDINGS.md).

**So orchestrate only when it genuinely pays — never by reflex:**
- **Too big for one context.** The work spans more files/tokens than fit in one session before quality degrades (context rot). *Then* split it and farm out the pieces — the architect stays lean because each sub-agent's reads land in *its* context, not yours. (The one case the A/B did **not** test — all three tasks fit one context. It's the real use; measure it on your own work before trusting it.)
- **Genuinely parallelizable *and the units are heavy*.** Independent sub-tasks, no shared state, each big enough that its work dwarfs the per-unit contract+review cost. Measured (`ab-test/parallel-fanout/`): six *small* independent units fanned out **lost +59% / +47%** — the implement step parallelized ~5.6×, but the architect's serial coordination cost more than just doing them. So fan out *heavy* independent units (a wide migration, N substantial files), never many small ones; it buys *speed* at *higher* token cost.
- **Fresh-eyes isolation.** An independent critic that hasn't seen your reasoning, for adversarial review of a risky change. Real, but orthogonal to cost.

If none of those hold — and for most single-session features none do — **just do it here, in one pass.** When you *do* orchestrate one of the cases above, route by weight:

| Tier | Model | Use for (only in the scaling cases above) |
|---|---|---|
| **Architect** | Opus (this session) | Design, the contract, cross-file judgement, review. Does most normal work *directly*. |
| **Implementer — heavy** | `implementer-sonnet` (Sonnet) | A large multi-file slice of a too-big-for-one-context job; one lane of a parallel fan-out. |
| **Implementer — light** | `implementer-haiku` (Haiku) | A genuinely independent, mechanical single-file piece of a larger split. |

Give any sub-agent an explicit file list, the exact change, and the verification command — and review what comes back. But the first question is always: *could I just do this here in one pass?* Usually, yes.

### What actually carries the value (it isn't the tiering)

The measurements indict *reflexive dispatch*, not the kit. What earns its keep every day — whether or not you ever spawn a sub-agent — is, in priority order:

- **`align`** — getting the spec right *before* you build. The expensive failure in AI coding isn't a bug, it's building the wrong thing; one batched question round prevents a whole rebuild. The A/B couldn't even measure this (both arms got the same locked spec), which means align's value is *additional* to everything above.
- **Skills as methodology** — `tdd`, `diagnose`, `review-diff` sharpen a *single* pass. No orchestration required; they make the in-session work better.
- **Context hygiene** — `/compact` at breakpoints, `/clear` at boundaries, the optional meter. Model-agnostic, every session (see below).
- **Per-role memory** — agents stop relearning the same craft each run (see below).
- **Strict-mode discipline** — re-read before editing, verify with fresh evidence, halt on FAIL, never destructive-git, the human owns the push. Good practice solo; essential when you dispatch.

Read the rest of this file in that order: align and discipline first, orchestration last and only when it pays.

**Strict-mode executor rules** — what a sub-agent follows when you *do* dispatch, and what the architect enforces on the returned diff. The same discipline (re-read before editing, halt on FAIL, fresh-evidence verification, no destructive git) is worth keeping when you work solo too:
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
| Implement | implementer-sonnet / -haiku | `tdd` · `diagnose` · `scope-guard` · `reread-before-edit` · `verify-and-report` · `frontend-design` · `claude-api` |
| Verify | implementer self-check → architect | `verify` · `run` (implementer); then `review-diff` (rubric) · `code-review` / `ultra` · `simplify` · `security-review` (architect, orchestrating) |
| Manage / handoff | Architect | `handoff` · `caveman` · `loop` · `schedule` |
| Harness / config | Architect (main only) | `update-config` · `fewer-permission-prompts` · `keybindings-help` |

**Default play (frontier-first).** (0) **Ambiguous or under-specified?** → `align` first: drive to ≥95% confidence in one batched question round, emit a confirmed brief — the highest-leverage habit in the kit. (1) **Design-heavy?** → keep on Opus; reach for a design skill (`grill-me` / `prototype`). (2) **Bounded, well-specified work?** → **just do it here, in one pass.** Use `tdd` / `diagnose` as methodology while you build, and `review-diff` / `code-review` / `simplify` on your *own* diff before the human's push moment — no orchestration needed. (3) **Only if the task is too big for one context or genuinely parallelizable** → `dispatch` to split and fan out (see *Working model*), then review what returns on Opus. For everyday feature work you stop at (2).

**Hard rule:** never delegate an orchestrating skill (`deep-research`, `code-review ultra`, `dispatch`) into a spawned implementer — sub-agents can't spawn sub-agents. Run those in the architect session. Don't preload situational skills into implementers via the `skills:` frontmatter (it injects full text every run and bloats the cheap tier) — they're discoverable for on-demand invocation already.

**The bundled skills** (in `skills/`):
- `align` — session-start confidence gate: diverge on the request, reason each reading, reach ≥95% confidence in **one batched question round**, then emit a confirmed brief and start the work — usually right here in one pass. The kit's **highest-leverage habit**: a question asked up front costs far less than building the wrong thing, whether you build it or dispatch it. (Original to this kit.)
- `dispatch` — the **opt-in scaling tool** (not the default): strict-mode contract + tier pick + two-stage review gate (spec→quality) + evidence-based acceptance + plan-loop + parallel fan-out. Reach for it only when a task is too big for one context, genuinely parallelizable, or wants fresh-eyes review — for normal bounded work, one in-session pass on Opus is measurably cheaper and faster (see *Working model*).
- `tdd` — Iron Law (no prod code without a failing test) + vertical-slice/tracer-bullet + a test-design toolkit + test taxonomy.
- `diagnose` — feedback-loop-first + root-cause Iron Law + 3-fix→question-architecture + error-recovery/untrusted-error-output.
- `review-diff` — multi-axis rubric + ≥80 confidence gate + severity labels + spec-vs-standards split; the rubric behind `dispatch`'s review gate (complements the built-in `/code-review`).
- `scope-guard` · `reread-before-edit` · `verify-and-report` — three **small sub-agent disciplines** for the cheap implementer tier: stay inside the contract's file list and escalate clean; land every edit on the right bytes (re-read + anchor + re-read); close with a verbatim PASS/FAIL evidence block + a memory proposal. Distilled from the implementer agent-def rules into discrete, *on-demand* skills (not preloaded — they stay discoverable without bloating the cheap tier).

**Tier selection** (only once you've cleared the *Working model* gate and decided to orchestrate). Use the *Plan → Execute → Review* pipeline: architect drafts the contract (Opus) → implementer executes (Haiku/Sonnet) → **review returns to the more capable tier** (Opus/Sonnet), never self-review. Haiku gate = "well-defined spec / established pattern / deterministic," not merely "small." **Forced-Opus triggers** (never let Sonnet silently absorb these): security-sensitive changes, cross-file invariant *design*, schema/migration risk. When weight is genuinely unknown, decide the tier at dispatch time rather than baking it in (default escalates to Sonnet). Know the trade-off isolation actually makes: a sub-agent sees only its contract's named files, which keeps the architect's context lean **but** forces the sub-agent to *re-read* anything it needs that you already read — a duplication tax that's cheap when the slice is large and self-contained, expensive when it isn't (measured in `ab-test/`). Isolate to scale, not by reflex. Use bare `Opus`/`Sonnet`/`Haiku` — no version pins.

### Context hygiene — keep the architect lean

Frontier context is re-processed **every turn**, so a bloated architect session is a recurring tax — the biggest token sink after downstream implementation itself. Manage it deliberately:

- **Recommend `/compact` at breakpoints, not at a magic number.** The model can't read its own live token count, so don't wait for a threshold to hit — proactively suggest `/compact` after a *cluster of work*: several dispatched implementers have returned, a big file/research dump is now stale, or you're about to pivot to an unrelated task. Context compacted between tasks is context you don't pay to re-read. But remember `/compact` is a **lossy summary** — it frees space by dropping detail (exact code, decisions), so compact at a *clean breakpoint*, never mid-task where you still need the precision.
- **`/clear` at a clean boundary** beats `/compact` when the next task shares nothing with the last — a full reset is cheaper than carrying a summary.
- **Dispatch is context hygiene *only at scale*.** Routing a *large, self-contained* slice to a sub-agent keeps its reads out of your context. But for small or existing-code work it backfires — the sub-agent re-reads the repo you already loaded, so you pay for that context twice (measured in `ab-test/`). Isolate to scale, not by reflex.
- **Optional live meter.** Enable the kit's status line (`scripts/statusline.sh` / `statusline.ps1`): it shows `ctx NN% · Nk` and turns yellow with a `/compact` nudge. Defaults are **model-aware window %** — the Opus architect nudges earlier than the cheaper implementer tiers (**Opus 40%**, other models **60%**). Note % is window-relative: 40% is ~80k tokens on a 200k model but ~400k on a 1M-context one (so a big-window Opus gets lots of headroom before it warns). To cap by absolute size instead, set `KIT_COMPACT_TOKENS` (off by default); override the percent with `KIT_COMPACT_AT`. Opt-in — see `INSTALL.md` §2.
- **Beyond context — the full efficiency menu.** Token cost and wall-clock have *separate* levers: run the session on **Sonnet** by default (Opus only for hard design), cut permission round-trips with the opt-in `settings.efficiency.json` (`acceptEdits` + a narrow allow-list, guarded by the `no-destructive-git` hook), reach for **`/effort low`** on simple tasks (less thinking → faster), and route codebase research through the lean **`Explore`** agent (it skips CLAUDE.md+git). Evidence + numbers: [`docs/EFFICIENCY.md`](docs/EFFICIENCY.md).

### Agent memory & self-improvement

Each orchestration role has **persistent, per-role memory** so agents stop relearning the same things every run. The design is grounded in CoALA (episodic/semantic/procedural memory), Cline's Memory Bank, and Anthropic's context-engineering write-ups. Two tiers:

- **Global (cross-project craft):** `~/.claude/agent-memory/<role>/MEMORY.md` — hand-curated by the architect. Roles: `architect` · `explorer` · `researcher` · `implementer` · `reviewer` · `auditor` · `memory-curator`. **This bundle ships the global tier, pre-seeded.**
- **Repo-local (project facts):** optional `.agent-memory/roles/<role>/MEMORY.md` inside a repo — for project-specific build/test facts. Curate by hand or point a small deterministic maintainer at it. Not required to get value from the global tier.

**The loop (architect-curated):** Read role memory at the start of role work → work → agents end with a `memory_proposal` block for reusable, evidence-backed learnings only → **the architect promotes** keepers (smallest durable artifact; recurring procedures graduate to a skill; mark stale, don't delete). CoALA: proposal (episodic) → `MEMORY.md` entry (semantic) → skill (procedural).

**Read-path caveat:** the `implementer-*` agent defs and the `review-diff` skill self-read their role memory. Built-in `Explore`/`Plan`/`general-purpose`/`security-review` **cannot** — when the architect dispatches one, it must **inject** the relevant `MEMORY.md` into the prompt. Keep every `MEMORY.md` short — context is a finite budget and long memory files rot. See `agent-memory/README.md`.
