# A/B test — does the orchestration kit actually help *you*?

Generic studies won't tell you whether this kit improves *your* workflow. This runs the **same task twice** —
once with the kit, once vanilla — so you can compare cost, speed, and quality on your own setup.

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
| `expense-tracker/` | A small multi-file CLI expense tracker + tests | warm-up | sanity-check the harness; small enough that the kit may *not* pay off |
| `calculator/` | A `calc` expression language (lexer → parser → evaluator) + tests | complex | real cross-file invariants + tricky correctness (precedence, right-assoc, error paths) — where the kit's edge, if any, should show |

**Verify the flag first:** `claude --bare` is the cleanest vanilla baseline — confirm it exists with
`claude --help`. If it doesn't, temporarily move your kit files aside instead
(`mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.off`, plus `skills/` and `agents/`, then move them back).

## Fairness rules
- Identical task in both arms (baked into each RUN file — don't edit the task block).
- Fresh session per arm; separate scratch dirs (`mktemp -d`); don't coach either arm.
- Let each arm behave per its file — System uses the full workflow, Vanilla stays plain.

## Reading it honestly
One run is an **anecdote, not proof**. Expect the System arm to often cost **more in $ and wall-clock** on
small tasks (more thoroughness, more round-trips) — that's the overhead. The kit's edge, if it exists, should
surface on the **complex** task as *fewer rework rounds / first-pass correctness* where a single vanilla pass
trips on something (precedence, associativity, an error path). `SELF QUALITY` is self-rated and not
comparable across arms — lean on acceptance, rework rounds, cost, and time. And remember the perception trap:
*feeling* faster is not *being* faster. For a real signal, repeat across several varied tasks.

`result-*.md` files are git-ignored — they're your local measurements, not part of the kit.
