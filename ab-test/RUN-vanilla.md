# A/B run — VANILLA arm (no customization)

**How to use:** open a *fresh* session — ideally `claude --bare` (skips CLAUDE.md, skills, agents, plugins,
memory) — and say: `Execute the instructions in <the path to this file>`.
The session will do the task below as a plain assistant, then write its scorecard.

> Run the SYSTEM arm (`RUN-system.md`) in a separate fresh chat, then `COMPARE.md` in a third.
> Keep both arms identical except for the workflow. Don't coach the model beyond what's written here.

---

## How to run THIS arm (Vanilla / baseline)

This is the **no-customization baseline**. For the truest result, this session should have been launched with
`claude --bare`. Regardless of how it launched:

- Do **NOT** use any skills, sub-agents, `dispatch`, tiering, planning rituals, or orchestration.
- **Ignore** any orchestration / tiering guidance that may be present in a loaded `CLAUDE.md`.
- Work as a single, plain assistant: read the task, write the code and tests directly, run `pytest`, fix
  until green. Nothing fancier. (If no Write tool is available in `--bare`, create files via Bash.)

Work in a fresh empty directory (e.g. `mktemp -d`) — do not create the project next to this file.

---

## The task (IDENTICAL in both arms — do not modify)

Build a small command-line **expense tracker** in Python (standard library only; `pytest` for tests).

Commands:
- `python tracker.py add <amount> <category> [--note TEXT]`   (amount must be > 0; category non-empty)
- `python tracker.py list [--category NAME]`
- `python tracker.py summary [--currency EUR|USD|GBP]`         (per-category totals + grand total; default EUR)

Requirements:
- Persist to `expenses.json` in the working dir; create it if missing; tolerate an empty/missing file.
- Validate inputs and exit non-zero with a clear message on: non-numeric / zero / negative amount,
  empty category, unknown currency.
- Split the code across at least three modules: storage (load/save), core logic (add/list/summarize),
  and CLI (argument parsing).
- `pytest` tests covering: add happy path, each validation error, summary across 2+ categories, and
  currency formatting. All tests must pass.

Acceptance (both must succeed):
1. `pytest -q` → all green.
2. `python tracker.py add 12.50 food && python tracker.py add 8 transport && python tracker.py summary --currency USD`
   → prints per-category totals and a grand total formatted with `$`.

---

## Scorecard

When done, fill this in, **print it in the chat**, AND write it to a file named `result-vanilla.md` in the
**same directory as this instruction file** (you were given that path — use its directory).

```
ARM:            Vanilla
TASK:           A — expense tracker
ACCEPTANCE:     <PASS | FAIL>   (paste the final `pytest -q` summary line + the CLI smoke output)
APPROACH:       Single plain assistant — confirm no skills / sub-agents / dispatch were used.
FILES CREATED:  <list the files>
TOOL CALLS:     <your best count of tool calls you made this run>
REWORK ROUNDS:  <how many times tests failed before going green>
SELF QUALITY:   <1–5> — <one line why>
--- fill in by hand after the run ---
COST_USD:       <run /usage and paste the session cost>
WALL_CLOCK:     <minutes from your first message to done>
```

After writing the file, remind the user to run `/usage` and paste `COST_USD` + note `WALL_CLOCK`.
