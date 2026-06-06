---
name: verify-and-report
description: The closing procedure a sub-agent runs before handing work back — execute exactly the verification command(s) the contract specified, capture the output verbatim, emit a tight PASS/FAIL evidence block (files changed · command · verbatim result · verdict), and add a memory_proposal stub ONLY if the task taught a reusable, evidence-backed lesson. Use as the last step of any dispatched implementation, before reporting to the architect. Stops "looks done" hand-offs with no proof and "I'll just tweak the test so it passes" cheating.
---

# Verify-and-report — prove it, then hand back

A sub-agent's job isn't done when the edit lands — it's done when there's **evidence** it works, packaged so the architect can grade it without re-running everything. This is that closing step.

## 1. Verify — run what the contract named

- Run **exactly** the verification command(s) the contract gave you (typecheck / test / build / lint). Don't substitute your own weaker check.
- If the contract named no check, that's a gap — say so in the report and run the most relevant existing one (note which).
- **Capture output verbatim.** Don't paraphrase "tests pass" — paste the real lines (or the tail, for huge logs).
- **Never make a check pass by weakening it** — disabling a test, loosening an assertion, adding a blanket `skip`, catching-and-swallowing. That's a FAIL you're hiding. Report the real failure instead.

## 2. Report — the evidence block

```
RESULT
Files     — <path: one-line per file changed>
Command   — <the exact verify command(s) run>
Output    — <verbatim result — the pass/fail lines, not a summary>
Verdict   — PASS  |  FAIL (halted at <where>)  |  BLOCKED (need <decision>)
Left      — <anything deliberately out of scope / open, per the contract>
```

On **FAIL or unexpected state**: halt, report verbatim, do **not** improvise a recovery or amend the contract — that's the architect's call.

## 3. Propose memory — only if it's durable

If (and only if) the task taught a **reusable, evidence-backed** lesson — a project build quirk, a recurring trap, a non-obvious command — append:

```
memory_proposal
role     — implementer
learning — <one line, the durable fact>
evidence — <what proved it this run>
```

You **propose**; the architect/curator promotes. Most mechanical tasks teach nothing reusable — **skip the block** rather than pad it. Never edit a `MEMORY.md` yourself.

## Done

Verdict stated with verbatim evidence. Pairs with `scope-guard` and `reread-before-edit` — the three together are the implementer's run-every-time loop.
