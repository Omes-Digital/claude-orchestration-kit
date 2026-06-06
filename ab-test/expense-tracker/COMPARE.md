# Compare the two A/B runs

**How to use:** open a *fresh* chat and say `Execute the instructions in <the path to this file>`.

Read `result-system.md` and `result-vanilla.md` from the **same directory as this file** (both must already
exist — run `RUN-system.md` and `RUN-vanilla.md` first). If either is missing, say so and stop.

Then produce:

1. **A side-by-side table** with one column per arm and these rows:
   `COST_USD` · `WALL_CLOCK` · `ACCEPTANCE` · `REWORK ROUNDS` · `TOOL CALLS` · `SELF QUALITY` · `APPROACH`.
2. **The deltas, stated plainly:** which arm cost less (and by how much), which was faster, and whether the
   output quality actually differed.
3. **An honest 3–4 line verdict.** Report what the numbers say — do **not** flatter the kit. Include this
   caveat verbatim in spirit: *n=1 is an anecdote, not proof.* Note the likely shape of the result — the
   System arm often shows **lower $** (work offloaded to cheaper tiers) yet **higher wall-clock** (more
   round-trips) and possibly **more total tokens**; on a task this small the two arms may simply converge,
   which is itself a valid finding (the kit isn't adding overhead). To actually trust a conclusion, repeat
   across ~8–10 varied and **larger** tasks.

If a manual field (`COST_USD` / `WALL_CLOCK`) is blank in either result, flag it as "not recorded" rather than
guessing — those come from `/usage` and a stopwatch, not from the transcript.
