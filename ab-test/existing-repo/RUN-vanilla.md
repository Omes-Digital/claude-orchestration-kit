# A/B run — VANILLA arm (no customization) · EXISTING-REPO task

**How to use:** open a *fresh* session — ideally `claude --bare` (skips CLAUDE.md, skills, agents, plugins,
memory) — and say: `Execute the instructions in <the path to this file>`.
The session makes the change below as a plain assistant, then writes its scorecard.

> Run the SYSTEM arm (`RUN-system.md`, this folder) in a separate fresh chat, then `COMPARE.md`.
> Identical task in both arms; only the workflow differs. Don't coach the model beyond what's written here.

---

## How to run THIS arm (Vanilla / baseline)

This is the **no-customization baseline**. For the truest result, launch with `claude --bare`. Regardless:

- Do **NOT** use any skills, sub-agents, `dispatch`, tiering, planning rituals, or orchestration.
- **Ignore** any orchestration / tiering guidance that may be present in a loaded `CLAUDE.md`.
- Work as a single, plain assistant: read the existing code, make the change directly across the files, run
  `pytest` + the acceptance commands, fix until green. Nothing fancier. (If no Write tool is available in
  `--bare`, edit/create files via Bash.)

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

When done, fill this in, **print it in the chat**, AND write it to `result-vanilla.md` in the **same directory
as this instruction file** (you were given that path — use its directory).

```
ARM:            Vanilla
TASK:           C — add due-dates to an EXISTING todo app (cross-cutting)
ACCEPTANCE:     <PASS | FAIL>   (paste `pytest -q` + the outputs of acceptance steps 3–6)
EXISTING TESTS: <stayed green the whole time | broke N times during the change>
APPROACH:       Single plain assistant — confirm no skills / sub-agents / dispatch were used.
FILES TOUCHED:  <which of the 6 files you changed, + any added>
TOOL CALLS:     <your best count of tool calls you made this run>
REWORK ROUNDS:  <how many times pytest/acceptance failed before going green>
DROPPED-LAYER?: <did any layer get missed on the first attempt — e.g. storage round-trip, back-compat,
                 list display, validation — and how was it caught>
SELF QUALITY:   <1–5> — <one line why>
--- fill in by hand after the run ---
COST_USD:       <run /usage and paste the session cost>
WALL_CLOCK:     <minutes from your first message to done>
```

After writing the file, remind the user to run `/usage` and paste `COST_USD` + note `WALL_CLOCK`.
