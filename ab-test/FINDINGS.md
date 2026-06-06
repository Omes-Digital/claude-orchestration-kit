# Findings — what happened when we A/B-tested this kit

> **TL;DR.** We ran the harness in this folder on three escalating tasks. On every one, the kit's
> tiered **architect → implementer dispatch cost +14–24% more and ~2× the wall-clock for *identical*
> correctness** versus a single vanilla Opus pass. That result reframed the whole kit: it now leads
> **frontier-first** (do the work yourself on the strong model) and treats orchestration as an opt-in
> tool for *scale*, not the everyday default. This page is the evidence — including, honestly, what it
> does **not** prove.
>
> **Update (2026-06-06):** the one case these three couldn't test — genuine *parallel* fan-out — was then
> built (`parallel-fanout/`) and run. Orchestration **lost there too**: +59% cost, +47% wall-clock on six
> independent units. See *The fair-shake test* below.

This is the kit measuring itself and publishing the result that went against its own original thesis. If
you take one thing from this repo, take the habit of measuring instead of assuming.

## What we ran

Three tasks from this harness, fresh chat per arm (System = full kit; Vanilla = `claude --bare`, no
CLAUDE.md / skills / agents). Same task text in both arms. Cost from `/usage`; API time is the model's
own reported time (the speed signal — wall-clock includes human-in-loop and environment friction, so we
quote API time for the comparison).

- **A — expense tracker** (`expense-tracker/`): a small multi-file CLI + tests. Greenfield, warm-up.
- **B — calc language** (`calculator/`): a lexer → parser → evaluator with real cross-file invariants
  (operator precedence, right-associative `^`, `-2^2 = -4`, function arity, error paths). Greenfield, complex.
- **C — due-dates in an existing repo** (`existing-repo/`): add a due-date feature **end-to-end** to a
  **pre-seeded existing** layered todo app — model field, storage round-trip, legacy back-compat, service
  validation, overdue query, CLI. Cross-cutting change across code you didn't write. **This is the regime
  the kit was actually built for** — and the one most likely to expose a single pass dropping a layer.

## The numbers

| Task | Arm | Cost | API time | Correctness | Rework | Regressions |
|---|---|---|---|---|---|---|
| **A** expense (greenfield) | Vanilla | **$0.87** | **2m06s** | PASS | 0 | 0 |
| | System | $0.99 (Opus $0.63 + Sonnet $0.36) | 3m58s | PASS | 0 | 0 |
| | **Δ** | **+14%** | **~1.9×** | identical | — | — |
| **B** calc (complex) | Vanilla | **$1.09** | **2m41s** | PASS | 0 | 0 |
| | System | $1.25 (Opus $0.86 + Sonnet $0.40) | 4m53s | PASS | 0 | 0 |
| | **Δ** | **+15%** | **~1.8×** | identical | — | — |
| **C** existing repo (cross-cutting) | Vanilla | **$2.19** | **5m09s** | PASS | 0 | 0 |
| | System | $2.71 (Opus $1.85 + Sonnet $0.86) | 10m07s | PASS | 0 | 0 |
| | **Δ** | **+24%** | **~2.0×** | identical | — | — |

The pattern is consistent and the penalty **grows** as the task moves toward existing code: +14% → +15% →
+24%. Both arms passed every acceptance check, with zero rework rounds and zero dropped layers, every time —
including on Task C, the cross-cutting change built specifically to make a single pass slip.

## Why dispatch lost

Three compounding mechanisms, all visible in the raw `/usage` numbers:

1. **You pay twice.** The architect (Opus) still designs *and* reviews; the sub-agent *also* has to read
   context *and* implement. For a task one Opus context already holds, that's strictly more work than Opus
   just doing it once. On Task B the kit's Opus spend ($0.86) was actually *below* vanilla's all-Opus
   ($1.09) — tiering really did offload ~$0.23 off Opus — but the Sonnet implementer added +$0.40, more
   than eating the saving.

2. **The isolation tax, and it's worse on existing code.** A sub-agent starts blind: it re-reads files the
   architect already loaded. On Task C the Sonnet implementer burned **1.1M cache-read tokens re-reading the
   repo, on top of** the architect's 1.3M — which is exactly why the existing-code task had the biggest
   penalty (+24%). Greenfield has less to re-read (Task B's Sonnet was only $0.40); an existing repo has the
   whole codebase. The "context isolation" the kit sold as a *benefit* is a **duplication cost** whenever the
   architect had already paid to load that context.

3. **Serial latency, and the gate caught nothing.** A single dispatch runs *after* the architect's design —
   architect-then-sub-agent in series — so the wall-clock roughly doubles. And the two-stage review gate, the
   kit's headline safety mechanism, **recovered nothing on all three tasks**: a single frontier pass didn't
   produce a defect for it to catch. A mechanism that only pays when the first attempt is wrong earns nothing
   when the first attempt is right — which, for a strong model on a one-context task, it was.

## The fair-shake test — parallel fan-out (run 2026-06-06)

The three tasks above all fit one context — the regime *least* favorable to orchestration. So we built a
fourth task ([`parallel-fanout/`](parallel-fanout/)) to give orchestration its best shot: **six genuinely
independent formatters**, no shared mutable state. The System arm fans out six agents *in parallel*; Vanilla
writes all six in one sequential Opus pass. If fan-out ever wins wall-clock, it should win here.

It lost — on every axis:

| Metric | Vanilla (one Opus pass) | System (6 agents, fan-out) | Δ |
|---|---|---|---|
| Cost | $1.22 | $1.94 (Opus $1.42 + Haiku $0.51) | **+59%** |
| **Wall-clock** | **3m56s** | 5m48s | **+47% — slower** |
| API compute | 2m44s | 8m22s | **3.1×** |
| Code produced | 292 lines | 823 lines | **2.8×** |

The parallelism actually **worked**: the six implementers ran concurrently and the *implement step*
compressed **~5.6×** (a ~417 s serial sum → a ~75 s slowest-lane). Parallelism wasn't the problem —
everything *around* it was:

1. **Coordination is serial *and* per-unit.** The architect writes six contracts up front and reviews six
   diffs after, one at a time on Opus. That coordination cost **$1.42 in Opus alone — more than Vanilla's
   *entire* build ($1.22)** — and its serial wall-clock outran the ~75 s the parallelism saved. The cheap
   Haiku tier ($0.51) was pure addition on top.
2. **The units were too small to amortize it.** Coordination is ~fixed *per unit* (one contract + one review
   each), so it grows with N right alongside the work. Fan-out only wins when each unit's work **far exceeds**
   its per-unit coordination cost — six ~40-line formatters aren't close.
3. **Isolation duplicated effort.** Six blind agents each re-read the seed and produced **2.8× the code**
   (823 vs 292 lines; 35 vs 19 tests) — verbose, un-shared, inconsistent. More code for the same six
   formatters is bloat, not value.

**Refined rule:** parallel fan-out pays only when **each unit's work dwarfs its per-unit coordination
(contract + review) cost** — independence is necessary but *not sufficient*. The parallelism here was
flawless and it *still* lost (+59% $, +47% wall-clock), because coordinating six small units cost more than
just doing them. Untested: a few genuinely *heavy* independent units (each, say, a multi-hour migration),
where the parallel saving might finally clear the coordination overhead. n=1, as always.

## What this does **not** prove

This is the honest part, and it cuts both ways. The result above is real, but it is **narrow**. Do not
read it as "multi-agent orchestration is useless."

- **n = 1 per task.** Three tasks, one run each. An anecdote with a clear direction, not a study. Repeat it
  on *your* work before trusting the magnitude.
- **Every task fit in one context.** All three sat comfortably inside a single Opus session. The headline
  case *for* orchestration — work **too big for one context** — was therefore **never tested**. That's the
  regime where splitting genuinely keeps each piece (and the architect) lean; we simply didn't measure it.
- **Parallel fan-out *was* then tested — and also lost** (see *The fair-shake test* above: +59% cost, +47%
  wall-clock on six small independent units, because the serial design+review bookends and per-agent re-read
  swamp the parallel middle). The narrower case still open: a few *heavy* independent units, where the
  parallel saving might finally exceed the coordination overhead.
- **We dispatched *fresh-context* sub-agents.** A **forked** sub-agent (`CLAUDE_CODE_FORK_SUBAGENT`) inherits
  the parent session and *shares its prompt cache* on the first call — removing most of the re-read tax. So
  the penalty measured here is specific to *fresh-context* dispatch; forked dispatch may cost far less, and
  is **untested**. (See [`../docs/EFFICIENCY.md`](../docs/EFFICIENCY.md) §8.)
- **We never tested Sonnet-solo.** The arms differed in *implementation* model (Opus-solo vs Opus-architect +
  Sonnet-implementer), but neither was a **single Sonnet pass** — which, at ~0.6× Opus's price and faster,
  may beat *both* on everyday work. The biggest efficiency lever (which single model) sits outside what this
  A/B measured.
- **No first-pass failure occurred, so the review gate was never exercised.** On a genuinely hard or
  error-prone task where a single pass *does* slip, fresh-eyes review and an independent verifier could pay
  for themselves. We didn't generate that failure, so we can't claim the gate is worthless — only that it
  was dead weight *here*.
- **align, methodology, context hygiene, and memory were not what we measured.** Both arms were handed the
  *same* locked spec, so the value of getting the spec right (`align`) was held constant and invisible to the
  test. Those parts of the kit are untouched by this finding — and `align`'s value is *additional* to
  everything above.

In short: we measured the regime **least** favorable to orchestration (small, single-context, single-dispatch,
no first-pass failure) and orchestration lost there, decisively. That is exactly enough to justify making it
**opt-in** — and not enough to throw it away.

## What we changed

The kit was reframed **frontier-first** (see `CLAUDE.md` §Working model):

- **Default: do the work yourself, in one pass, on the strongest model.** For anything that fits one
  context, that's measurably cheaper and faster.
- **Orchestrate only to scale** — when the work is too big for one context, genuinely parallelizable, or
  wants fresh-eyes isolation. The tier table and strict-mode contract are retained for exactly those cases.
- **Elevated the parts that actually pay every day** and are independent of tiering: `align` (right spec
  before building), skills as methodology (`tdd` / `diagnose` / `review-diff` sharpen a *single* pass),
  context hygiene, and per-role memory.
- **`dispatch` now self-gates.** Its own description and body tell the model not to dispatch by reflex —
  clear the scaling gate first.

## Run it yourself

Don't take our three runs as gospel — the harness is right here. Follow [`README.md`](README.md): run
`RUN-system.md` and `RUN-vanilla.md` for a task in two fresh chats, paste `/usage` into each scorecard, then
`COMPARE.md`. We've now covered both ends — one-context work (dispatch lost) and small-unit parallel fan-out
(lost too). The cases still open: a task genuinely *too big for one context*, or a fan-out of *heavy*
independent units. If orchestration wins on your work, that's a finding worth more than this page.
