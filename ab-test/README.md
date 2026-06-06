# A/B test — does the orchestration kit actually help *you*?

Generic studies won't tell you whether this kit improves *your* workflow. This runs the **same task twice** —
once with the kit, once vanilla — so you can compare cost, speed, and quality on your own setup.

It's three fresh chats (the two arms **must** be separate sessions — you can't fairly run both conditions in
one context):

| Step | Fresh chat | Say |
|---|---|---|
| 1 | your normal `claude` | `Execute the instructions in <path>/RUN-system.md` |
| 2 | ideally `claude --bare` | `Execute the instructions in <path>/RUN-vanilla.md` |
| 3 | any | `Execute the instructions in <path>/COMPARE.md` |

Each RUN does the task and writes `result-system.md` / `result-vanilla.md` **next to itself**; COMPARE reads
both and prints the verdict. After each RUN, run **`/usage`** and paste the session cost into that result
file's `COST_USD` line, and note the wall-clock.

**Verify the flag first:** `claude --bare` is the cleanest vanilla baseline — confirm it exists with
`claude --help`. If it doesn't, temporarily move your kit files aside instead
(`mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.off`, plus `skills/` and `agents/`, then move them back).

## Fairness rules
- Identical task in both arms (already baked into the two RUN files — don't edit the task block).
- Fresh session per arm; separate scratch dirs (`mktemp -d`); don't coach either arm.
- Let each arm behave per its file — System uses the full workflow, Vanilla stays plain.

## Reading it honestly
One run is an **anecdote, not proof**. Expect the System arm to often cost **less in $** (it offloads to
cheaper tiers) but take **longer in wall-clock** (more round-trips) — that trade is the whole point. On a
small task the arms may converge; the kit's edge, if any, shows on **bigger, multi-file** work. And remember
the perception trap: *feeling* faster is not the same as *being* faster. For a real signal, repeat across
~8–10 varied tasks (swap the task block in both RUN files, keeping them identical to each other).

`result-*.md` files are git-ignored — they're your local measurements, not part of the kit.
