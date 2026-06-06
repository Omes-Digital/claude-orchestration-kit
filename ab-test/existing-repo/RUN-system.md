# A/B run — SYSTEM arm (with the orchestration kit) · EXISTING-REPO task

**How to use:** open a *fresh* `claude` session (your normal, kitted one) and say:
`Execute the instructions in <the path to this file>`.
The session makes the change below using the kit's full workflow, then writes its scorecard.

> Run the VANILLA arm (`RUN-vanilla.md`, this folder) in a separate fresh chat, then `COMPARE.md`.
> Identical task in both arms; only the workflow differs. Don't coach the model beyond what's written here.

---

## How to run THIS arm (System / orchestration)

You are running **with** the orchestration kit. Solve the task the way the kit intends — actually exercise it:

1. If anything is ambiguous, run `/align` (one batched question round); otherwise proceed.
2. **Understand the existing code first** (it's a real cross-cutting change, not greenfield). Then plan, and
   **dispatch the bounded implementation to an implementer sub-agent** (Sonnet — multi-file, cross-file
   invariants) with an explicit strict contract: the files, the exact change per layer, and the verification
   matrix (`pytest -q` + the acceptance commands below).
3. Reach for skills that fit (`tdd`, `review-diff` / `/code-review`).
4. **Review the returned work yourself** before declaring done — re-run the full acceptance independently,
   and specifically check for **regressions** (did any existing test break?) and **dropped layers** (does the
   due date actually survive a save→load round-trip and a legacy-file load?). Never take the sub-agent's word.

---

## The task (IDENTICAL in both arms — do not modify)

You are extending an **existing** small app, not building from scratch. Copy the seed project to a fresh
working directory and make your change THERE (the `seed/` folder is next to this instruction file):

```
SEED="<the seed/ folder next to this instruction file>"
DIR="$(mktemp -d)"; cp "$SEED"/*.py "$SEED"/legacy_tasks.json "$DIR"/; cd "$DIR"
```

The app (`models.py` · `storage.py` · `service.py` · `cli.py` · `todo.py` · `test_todo.py`) is a layered todo
CLI whose existing tests pass. **Add due-dates to tasks, end to end:**

- **Model:** a Task gains an optional due date (ISO `YYYY-MM-DD`, or none).
- **Storage:** the due date must survive a save→load round-trip. Loading an OLD file whose tasks have no due
  field must still work (treat as no due) — see `legacy_tasks.json`. **Don't break back-compat.**
- **Service:** `add` accepts an optional due date; reject an invalid date format with `ValidationError`. Add a
  way to get tasks that are overdue relative to a given "today" (due strictly before today, and not done).
- **CLI:** `add` takes optional `--due YYYY-MM-DD`; `list` shows the due date when present; add an
  `overdue --today YYYY-MM-DD` command that prints overdue tasks. Invalid `--due` → stderr + non-zero exit.
- **Tests:** extend `test_todo.py` for: add-with-due, add-with-invalid-due, due survives a round-trip, loading
  the legacy (no-due) file, and overdue filtering. **Keep ALL existing tests green.**

### Acceptance (run in the working dir; all must hold)
1. `pytest -q` → all green (existing + new).
2. `python todo.py --file a.json add "buy milk"` then `python todo.py --file a.json list` → still works.
3. Due end-to-end (spans two processes → exercises persistence):
   ```
   python todo.py --file b.json add "pay rent" --due 2026-07-01
   python todo.py --file b.json add "no-due task"
   python todo.py --file b.json list      # 'pay rent' shows due 2026-07-01; 'no-due task' shows none
   ```
4. Overdue:
   ```
   python todo.py --file b.json add "old bill" --due 2020-01-01
   python todo.py --file b.json overdue --today 2026-07-02   # lists 'pay rent' + 'old bill', not 'no-due task'
   ```
5. Back-compat: `python todo.py --file legacy_tasks.json list` → no crash; tasks shown with no due.
6. Invalid date: `python todo.py --file b.json add "bad" --due 13/2020` → non-zero exit + clear stderr message.

---

## Scorecard

When done, fill this in, **print it in the chat**, AND write it to `result-system.md` in the **same directory
as this instruction file** (you were given that path — use its directory).

```
ARM:            System
TASK:           C — add due-dates to an EXISTING todo app (cross-cutting)
ACCEPTANCE:     <PASS | FAIL>   (paste `pytest -q` + the outputs of acceptance steps 3–6)
EXISTING TESTS: <stayed green the whole time | broke N times during the change>
APPROACH:       <skills invoked, # of sub-agent dispatches, which tiers; did review catch anything?>
FILES TOUCHED:  <which of the 6 files you changed, + any added>
TOOL CALLS:     <your best count of tool calls you made this run>
REWORK ROUNDS:  <how many times pytest/acceptance failed before going green>
DROPPED-LAYER?: <did any layer get missed on the first attempt — e.g. storage round-trip, back-compat,
                 list display, validation — and how was it caught (a test? the review?)>
SELF QUALITY:   <1–5> — <one line why>
--- fill in by hand after the run ---
COST_USD:       <run /usage and paste the session cost>
WALL_CLOCK:     <minutes from your first message to done>
```

After writing the file, remind the user to run `/usage` and paste `COST_USD` + note `WALL_CLOCK`.
