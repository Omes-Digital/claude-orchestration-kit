# Compare the two A/B runs (calc task)

**How to use:** open a *fresh* chat and say `Execute the instructions in <the path to this file>`.

Read `result-system.md` and `result-vanilla.md` from the **same directory as this file** (both must already
exist — run `RUN-system.md` and `RUN-vanilla.md` first). If either is missing, say so and stop.

Then produce:

1. **A side-by-side table** with one column per arm and these rows:
   `COST_USD` · `WALL_CLOCK` · `ACCEPTANCE` · `REWORK ROUNDS` · `TOOL CALLS` · `SELF QUALITY` · `APPROACH`.
2. **The deltas, stated plainly:** which arm cost less (and by how much %), which was faster, and whether the
   output actually differed in correctness or coverage.
3. **An honest 3–4 line verdict.** Report what the numbers say — do **not** flatter the kit. Notes to fold in:
   - *n=1 is an anecdote, not proof.*
   - `SELF QUALITY` is **self-rated by each arm and not independently comparable** — treat it as a weak signal;
     the System arm tends to rate itself higher partly because it does more work. Lean on `ACCEPTANCE`,
     `REWORK ROUNDS`, cost, and time as the hard signals.
   - On a complex task the expected story differs from the simple one: if the kit ever earns its overhead, it
     shows up as **fewer rework rounds / acceptance passing first time** on work where the vanilla arm makes a
     mistake a single pass misses (e.g. operator precedence, right-associativity, error paths). If both arms
     pass cleanly, the kit's extra cost + wall-clock bought little here too.

If a manual field (`COST_USD` / `WALL_CLOCK`) is blank in either result, flag it as "not recorded" rather than
guessing — those come from `/usage` and a stopwatch, not from the transcript.
