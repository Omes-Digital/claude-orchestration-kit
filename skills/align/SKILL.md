---
name: align
description: Session-start alignment gate — diverge on the request, reason every interpretation, and drive to ≥95% confidence in ONE batched question round before any work begins, then emit a confirmed brief and start the work (usually right here in a single in-session pass; dispatch downstream only if the task is too big for one context or genuinely parallel). The kit's highest-leverage habit — getting the spec right prevents the most expensive failure in AI coding, building the wrong thing, whether you build it yourself or hand it off. Runs the whole session in caveman mode for token economy. Use at the start of a session, when a request is ambiguous or under-specified, when you say "align", "/align", "make sure you understand", "what do you think I mean", "diverge first", or before any non-trivial build.
---

# Align — confidence gate before work

Diverge on the request, reason each interpretation, **reach ≥95% confidence in one batched question round**, then emit a confirmed brief and start the work — usually right here in one pass on the strong model. Front-load understanding so the build (yours, or a sub-agent's if you later dispatch) never targets the wrong thing. This is the kit's **highest-leverage habit**: the most expensive failure in AI coding isn't a bug, it's building the wrong thing, and one question round prevents a whole rebuild. Pairs with `~/.claude/CLAUDE.md` §Working model: it runs *before* anything else, dispatch or not.

**Core principle.** A wrong build costs far more than a question asked up front — whether you build it yourself or dispatch it. Spend a few frontier tokens here to save a whole mis-built sprint. Do NOT touch code, files, or sub-agents until the brief is locked.

## Token economy — levers in priority order

Align is the cheap part; the real token sink is downstream (file reads, implementation, re-built contracts when the brief was wrong). Optimise in this order — **do not cheap out on align's own reasoning** (a cheaper model under-diverges → wrong brief → the expensive waste you meant to avoid):

1. **Fewer round-trips.** Dominant cost is input/context re-processed every turn, not output. One batched question round (§4) ≫ ten one-offs. Each avoided round-trip saves more than caveman does. Target 1 round, cap 2.
2. **Read before you ask.** Memory + repo first (§1). A question answerable from `MEMORY.md` that you ask anyway burns a whole round-trip.
3. **Caveman.** Cuts output ~75% (§0). Real but smaller — output is the minority of token cost.
4. **Right model, one pass.** The real token sink is downstream implementation. Getting the brief right is what makes that pass run *once* instead of twice — which matters far more than *which* model runs it. Do the work in-session on the strong model by default; tier down via `/dispatch` only when the task is too big for one context or genuinely parallel (§6). A wrong brief re-built is the expensive waste; align prevents it either way.

Don't invert this order. Shaving align's output (caveman) while allowing a second avoidable question round is a net loss.

## Run it on

**Opus (session model), moderate thinking, single session.** Align is judgement-dense but short — moderate thinking forces genuine divergence (§1) and honest confidence scoring (§3); max thinking over-deliberates the cheap gate and inverts the token economy above. **No ultracode, no sub-agents** — fan-out machinery is for the work align *authorizes* downstream, never for align itself. (Thinking level is set by the harness/user, not this skill — this is intended runtime, not enforcement.)

## 0. Enter caveman

First action: invoke `/caveman`. Whole session runs compressed (~75% fewer tokens) until the user says otherwise. All steps below are caveman-style: drop filler, keep technical precision.

## 1. Diverge — read the request N ways

Restate the request in one line. Then list **every plausible interpretation** — not just the obvious one. Force at least 2; stop padding past 4. For each:

- **Reading** — what the user might mean
- **Implies** — scope, files, end-state it points to
- **Prior** — rough likelihood given context (memory, repo, recent work)

Pull context cheaply first: recalled `MEMORY.md`, the live repo, what was done last session. Don't ask what you can read.

## 2. Reason each option

For every interpretation, one line: keep or kill, and why. Kill on contradiction with known facts/constraints; keep on live ambiguity. Surviving readings = the decision tree. Note which choices are **load-bearing** (change what gets built) vs **cosmetic** (safe default, just state it).

## 3. Score confidence

Estimate current confidence the *top* reading is correct (0–100%).

- **≥95%** → skip to §5. State the one reading and the confidence.
- **<95%** → §4. One batched round.

Cosmetic ambiguities never block — pick the obvious default and say so. Only load-bearing forks gate the score.

## 4. Batch ONE question round

Fire a single `AskUserQuestion` (1–4 questions) covering only the load-bearing forks. Each option must be a **reasoned** choice, not a bare label — its `description` states the implication/trade-off, recommended option first tagged `(Recommended)` with the reasoning. Order questions by how much they move confidence.

Re-score after answers. Re-batch **only** if a load-bearing fork is still open — never drift into open-ended Q&A. Target: lock in ≤2 rounds.

## 5. Confirmed brief

Once ≥95%, emit (caveman):

```
BRIEF
Goal      — one line, the locked reading
Scope     — in / out
Approach  — chosen path
Rejected  — killed readings + one-line why
Open      — [TBC] non-blocking items (defaults stated)
Confidence — NN%
```

## 6. Hand off

Offer the next step, don't auto-run:
- Bounded + specified → **just do it here, in one pass** on the strong model (the cheapest, fastest path for anything that fits one context). Reach for `/dispatch` only if it's a scaling case: too big for one context, genuinely parallelizable, or you want fresh-eyes isolation.
- Still design-heavy → keep on Opus; suggest a Plan agent or `grill-me`.
- Trivial → just do it.

State the recommendation; let the user trigger.

## Guardrails

- Caveman ≠ vague. Compress words, never precision.
- One batched round beats ten one-off questions — but a real fork unasked is worse than a round. Don't false-economy past 95%.
- Read before you ask. Memory + repo first.
- No work — no edits, no sub-agents, no contracts — until the brief is locked.
