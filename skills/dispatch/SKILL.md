---
name: dispatch
description: Architect→implementer orchestration — the kit's opt-in SCALING tool, not a default. Use it ONLY when work is too big for one context, genuinely parallelizable (independent sub-tasks, real wall-clock win), or needs fresh-eyes isolation — for normal bounded work that fits one session, a single in-session pass on the strong model is measurably cheaper and faster (see ab-test/FINDINGS.md), so do NOT dispatch by reflex. When one of those scaling reasons holds and you delegate / hand off to implementer-sonnet or implementer-haiku, decide which tier (Haiku vs Sonnet vs keep-on-Opus) a task belongs to, execute a multi-task plan with sub-agents, fan out independent work, or say "dispatch this", "delegate this", "hand this off", "execute the plan", "write the contract": this produces a strict-mode contract (tier · file inventory · exact per-file change · deny-list · verification matrix), runs the implementer loop with a two-stage review gate and evidence-based acceptance, and supports parallel fan-out.
---

# Dispatch — architect→implementer orchestration

Turn bounded, specified work into a **strict-mode contract**, route it to the right implementer tier, and drive it through review + verification to acceptance. The architect (Opus) writes the contract and judges; cheap implementers execute it verbatim. This operationalises `~/.claude/CLAUDE.md` §Working model — and runs only *after* you've cleared its gate (too big for one context · genuinely parallel · fresh-eyes); for work that fits one in-session pass, don't come here.

**Core principle.** Dispatch is a **scaling tool, not a default.** Measured on this kit's own `ab-test/` harness, routing everyday bounded work to a sub-agent cost **+14–24% and ~2× the wall-clock for identical correctness** — you pay the architect to design+review *and* a sub-agent to re-read+implement, which beats one in-session pass only when that pass can't hold the task. So before writing a contract, clear the gate.

**The gate — dispatch only if at least one holds:**
- **Too big for one context** — the work won't fit in one session before quality degrades; splitting it keeps each piece (and the architect) lean.
- **Genuinely parallelizable** — independent sub-tasks, no shared state, run concurrently for a real wall-clock win.
- **Fresh-eyes isolation** — you want a critic that hasn't seen your reasoning.

If none hold, **keep it on Opus and do it in one pass** — that's cheaper and faster. And as before: if it's still a design question, cross-file judgement call, or triage, it isn't dispatchable anyway. Dispatch is "I know exactly what to change *and* there's a scaling reason to hand it off" — not "figure out what to do," and not "a cheaper model should do the typing."

When you do dispatch: **implementers never inherit your session history — you construct exactly the context they need.** Evidence before completion, always.

## 1. Route — pick the shape first

| Shape | When | Go to |
|---|---|---|
| **Single contract** | One bounded change | §2 → §3 → §5 → §6 → §7 |
| **Plan loop** | N dependent tasks, sequential | §8 |
| **Parallel fan-out** | N *independent* tasks, no shared state | §9 |
| **Keep on Opus (default)** | Design, cross-file judgement, triage — **or any task a single in-session pass can hold** (most work) | don't dispatch |

## 2. Pick the tier

| Pick | When |
|---|---|
| **implementer-haiku** | Single file, mechanical, NO cross-file invariants — code from a well-defined spec, an established pattern, a rename/constant/config tweak, a test in one file, docstrings, format a region. |
| **implementer-sonnet** | Multiple files, cross-file invariants (types ↔ signatures ↔ schema ↔ migration), schema/migration risk, API/service-contract change, service split, orchestrating multi-step reasoning. **Escalated default when weight is unclear.** |
| **keep on Opus** | Design, cross-file judgement, triage — and the **forced-Opus triggers**: security-sensitive changes, cross-file invariant design, schema/migration risk. Don't let Sonnet silently absorb these. |

The Haiku gate is "well-defined spec / established pattern / deterministic," not just "small."

## 3. Write the contract (the five blocks)

Emit all five. Be explicit enough that the implementer never guesses or designs.

1. **Tier** — `implementer-haiku` or `implementer-sonnet`, one line why.
2. **Inventory** — every file they MAY touch. If a needed file is unknown, find it first; don't make the implementer discover scope.
3. **Exact change per file** — precise edit per file (anchor strings, signatures, before→after). Name any new file explicitly (Write is allowed only for inventory-listed new files).
4. **Out-of-scope deny-list** — files/areas they must NOT touch. Hard deny. For parallel work, deny-lists must be **disjoint**.
5. **Verification matrix** — exact commands (typecheck / tests / build / migration) and what PASS looks like.

**Curate the task text.** Paste what the implementer needs into the contract; don't make it read the plan/source-of-truth doc (prevents scope drift and context bloat).

## 4. Pre-dispatch self-critique

Before spawning, review the contract critically — gaps, ambiguity, missing files, wrong approach. If a design question surfaces, it's not dispatchable → back to Opus. Cheap insurance against a bad contract.

## 5. Hand off + status protocol

Spawn `implementer-sonnet` / `implementer-haiku` with the contract as the prompt. **Never delegate an orchestrating skill** (`deep-research`, `code-review ultra`, this skill) into the implementer — sub-agents can't spawn sub-agents. Handle the return by status:

- **DONE** → go to review (§6).
- **DONE_WITH_CONCERNS** → read concerns; address correctness/scope first, then review.
- **NEEDS_CONTEXT** → add the missing context to the contract, re-dispatch.
- **BLOCKED** → escalation ladder: context problem → re-dispatch same tier with more context; needs deeper reasoning → bump tier; too large → split the contract; plan/approach wrong → back to Opus to re-design.

**Never retry the same tier unchanged.** If the implementer is stuck, something must change.

## 6. Two-stage review gate

After each DONE, in this (architect) session — never skip, never reorder:

- **Stage A — spec compliance:** does the diff match the contract *exactly* — nothing missing, nothing extra (scope creep), nothing implemented-but-wrong? Re-loop until ✅.
- **Stage B — code quality:** *only after A is ✅.* Run the `review-diff` skill (rubric) and/or `simplify` on the diff. Re-loop until clean.

Don't start B before A is ✅. Don't advance with open issues. Don't let the implementer's self-review replace this.

## 7. Verification before completion (hard gate)

**Do not trust the implementer's "verification passed" report.** Accept only on fresh evidence *you* confirm:

1. Read the **VCS diff** — confirm the changes are real and match the contract (not the agent's success claim).
2. Re-run the verification-matrix commands **fresh, this turn**; read exit code + failure count.
3. For bug-fix/regression contracts, demand **red-green** evidence: test fails without the fix, passes with it (revert → must fail → restore → pass).

If you didn't run it this turn, you can't claim it passes. "Agent reported success" ≠ verified.

## 8. Plan-execution loop

For N dependent tasks: extract all tasks + their full context into TodoWrite up front. Per task run §3 → §5 → §6 → §7. **Execute continuously — no "should I continue?" pauses between tasks.** After all tasks, do one final whole-implementation review. Then stop at the **push moment** for the human — continuous through implement+review+verify, never through commit/push.

## 9. Parallel fan-out

Only when domains are genuinely independent — no shared state, fixing one can't fix another. Then: one full five-block contract per domain (disjoint deny-lists); dispatch concurrently; on return **conflict-check** (did two agents touch the same file?), run the full verification matrix across the merged set, and spot-check for systematic errors. **Anti-conditions:** related failures, need-full-context, exploratory debugging, shared state → do NOT parallelize; do it sequentially.

## Strict-mode rules (yours + grafted)

- Touch only inventory-listed files; out-of-scope is a hard deny.
- Halt on the first FAIL or unexpected state; report verbatim — no improvised recovery.
- Never amend the contract mid-execution; record the bug for the architect.
- Re-read after every edit; anchor search/replace patterns.
- Fresh sub-agent per task; no context inheritance; provide full task text.
- Never start implementation on main/master without explicit consent.
- Dispatch a fix sub-agent rather than hand-fixing (avoid context pollution).
- No destructive git (`reset --hard`, `push --force`, `clean -fd`) and no migration downgrades.
- **The human owns the push moment** — never push, never self-merge, don't commit unless asked.

## Red flags — STOP

Skipping either review stage · starting quality review before spec is ✅ · advancing with open issues · trusting an agent's success report without reading the diff · claiming done without fresh verification · parallel-dispatching on shared state · letting self-review replace review · starting on main.
