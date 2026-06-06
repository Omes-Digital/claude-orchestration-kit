# COMPARE — parallel fan-out

Read **`result-system.md`** and **`result-vanilla.md`** in this directory. If either is missing, say so and stop.

This task exists to test the claim the kit's other A/B tasks **could not**: that orchestration wins when work
is **genuinely parallelizable**. Six independent units → the System arm runs them concurrently; Vanilla does
them in sequence. So the headline metric here is **wall-clock**, not cost.

Produce a short, honest verdict — you are **not** here to flatter the kit:

1. **Wall-clock (headline).** System vs Vanilla. Did parallel fan-out actually win, and by how much? (Expect
   System faster — its wall-clock ≈ the slowest single unit + dispatch overhead; Vanilla ≈ the sum of six.)
   If System was *not* faster, say so plainly and reason about why (overhead swamped the win? agents queued
   rather than truly overlapped?).
2. **Cost.** Token $ each. Expect System to cost **more** — six cold sub-agents each re-read the seed (the
   isolation tax doesn't disappear in parallel; you trade tokens for wall-clock). Quantify the premium.
3. **Correctness.** Both `pytest` green? Any unit fail a golden case? Did the System arm's conflict-check or
   review catch anything?
4. **Verdict.** For *this kind of work* (many independent units), did the wall-clock win justify the token
   premium? This is the case the kit claims orchestration is **for** — does the evidence back it, or not?

**Caveats to state:** n=1, one machine; "wall-clock" includes human-in-loop and any tool queuing; the
per-agent re-read tax means parallel buys **speed, not token savings**. Cross-reference
[`../FINDINGS.md`](../FINDINGS.md): the earlier tasks showed dispatch losing on *one-context* work — this task
probes the opposite end. Together they bound when orchestration pays.
