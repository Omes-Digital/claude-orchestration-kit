# A/B test — does the orchestration kit actually help *you*?

Generic studies won't tell you whether this kit improves *your* workflow. This runs the **same task twice** —
once with the kit, once vanilla — so you can compare cost, speed, and quality on your own setup.

> **We already ran it — and the results reframed this kit.** See [`FINDINGS.md`](FINDINGS.md): on three
> tasks, the kit's tiered dispatch cost **+14–24% and ~2× the wall-clock for identical correctness**, which
> is why the kit is now *frontier-first* and treats orchestration as opt-in. The harness below lets you
> reproduce that — or challenge it on the cases it couldn't test (work too big for one context, or genuine
> fan-out).

Each task lives in its own folder, with three self-contained files. The two arms **must** be separate fresh
chats (you can't fairly run both conditions in one context):

| Step | Fresh chat | Say |
|---|---|---|
| 1 | your normal `claude` | `Execute the instructions in <task>/RUN-system.md` |
| 2 | ideally `claude --bare` | `Execute the instructions in <task>/RUN-vanilla.md` |
| 3 | any | `Execute the instructions in <task>/COMPARE.md` |

Each RUN does the task and writes `result-system.md` / `result-vanilla.md` **next to itself**; COMPARE reads
both and prints the verdict. After each RUN, run **`/usage`** and paste the session cost into that result
file's `COST_USD` line, and note the wall-clock.

## Tasks

| Folder | Task | Size | Point |
|---|---|---|---|
| `expense-tracker/` | A small multi-file CLI expense tracker + tests | greenfield · warm-up | sanity-check the harness; small enough that the kit may *not* pay off |
| `calculator/` | A `calc` expression language (lexer → parser → evaluator) + tests | greenfield · complex | real cross-file invariants + tricky correctness (precedence, right-assoc, error paths) |
| `existing-repo/` | Add due-dates **end-to-end** to a pre-seeded existing layered todo app | **cross-cutting · existing code** | the regime the kit is *actually built for* — a change spread across an existing multi-file codebase where a single pass can drop a layer (storage round-trip, legacy back-compat) or cause a regression. The greenfield tasks above are the regime *least* favorable to orchestration; this is the fair test of its real claim. |
| `parallel-fanout/` | Six **independent** output formatters, built concurrently | **parallel · fan-out** | the case the other three *couldn't* test — genuinely independent units with no shared state, where the System arm fans out 6 agents in parallel and Vanilla does them in sequence. Here orchestration *should* win **wall-clock**. The fair test of orchestration's **upside** (the others probe its downside). |

**Verify the flag first:** `claude --bare` is the cleanest vanilla baseline — confirm it exists with
`claude --help`. If it doesn't, temporarily move your kit files aside instead
(`mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.off`, plus `skills/` and `agents/`, then move them back).

## Fairness rules
- Identical task in both arms (baked into each RUN file — don't edit the task block).
- Fresh session per arm; separate scratch dirs (`mktemp -d`); don't coach either arm.
- Let each arm behave per its file — System uses the full workflow, Vanilla stays plain.

## Reading it honestly
One run is an **anecdote, not proof** — but when we ran these three, the System arm cost **more in $ and
wall-clock every time, for identical correctness** ([`FINDINGS.md`](FINDINGS.md)). On a single-context task
that's the expected result: dispatch adds round-trips and an isolation tax, with no first-pass failure for its
review gate to catch. The kit's edge, *if it exists for you*, is most likely to surface where these three
tasks **couldn't** test it — a task **too big for one context**, or one that **fans out into genuinely
independent pieces**. `SELF QUALITY` is self-rated and not comparable across arms — lean on acceptance, rework
rounds, cost, and time. And remember the perception trap: *feeling* faster is not *being* faster. For a real
signal, repeat across several varied tasks — especially the big or parallel ones.

`result-*.md` files are git-ignored — they're your local measurements, not part of the kit.
