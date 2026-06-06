# Compare the two A/B runs (existing-repo task)

**How to use:** open a *fresh* chat and say `Execute the instructions in <the path to this file>`.

Read `result-system.md` and `result-vanilla.md` from the **same directory as this file** (both must already
exist — run `RUN-system.md` and `RUN-vanilla.md` first). If either is missing, say so and stop.

Then produce:

1. **A side-by-side table:** `COST_USD` · `WALL_CLOCK` · `ACCEPTANCE` · `EXISTING TESTS` (regressions) ·
   `REWORK ROUNDS` · `DROPPED-LAYER?` · `TOOL CALLS` · `SELF QUALITY` · `APPROACH`.
2. **The deltas, stated plainly:** which arm cost less, which was faster — and the signals that matter MOST
   for *this* task: did either arm **break an existing test** (regression) or **drop a layer** (e.g. the
   storage round-trip or legacy back-compat) on the first attempt, and how many **rework rounds** each needed.
3. **An honest 3–4 line verdict.** This is the task type the kit is *supposed* to be good at — a cross-cutting
   change in existing code where a single pass can lose track. Report what the numbers say, do **not** flatter
   the kit. The key question: did the kit's review gate / dispatch discipline produce **fewer regressions /
   dropped layers / rework rounds** than the plain pass — enough to justify any extra cost and time? If the
   vanilla arm also did it cleanly, then even here the overhead didn't pay. Notes:
   - *n=1 is an anecdote, not proof.*
   - `SELF QUALITY` is self-rated and not comparable across arms — lean on regressions, dropped-layers,
     rework rounds, acceptance, cost, and time.

If a manual field (`COST_USD` / `WALL_CLOCK`) is blank in either result, flag it as "not recorded" rather than
guessing.
