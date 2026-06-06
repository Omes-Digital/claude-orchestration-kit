# A/B run — VANILLA arm (no customization) · COMPLEX task

**How to use:** open a *fresh* session — ideally `claude --bare` (skips CLAUDE.md, skills, agents, plugins,
memory) — and say: `Execute the instructions in <the path to this file>`.
The session does the task below as a plain assistant, then writes its scorecard.

> Run the SYSTEM arm (`RUN-system.md`, this folder) in a separate fresh chat, then `COMPARE.md`.
> Identical task in both arms; only the workflow differs. Don't coach the model beyond what's written here.

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

Build a command-line **expression calculator** named `calc` in Python (standard library only; `pytest` for
tests). It parses and evaluates arithmetic expressions with correct precedence and clear errors.

Language:
- Operators `+ - * / %` and `^` (exponent, **right-associative**), unary minus, and parentheses.
- Precedence (high→low): `^` , then unary `-`, then `* / %`, then `+ -`.
  So `2 + 3 * 4` = 14, `2 ^ 3 ^ 2` = 512, and `-2 ^ 2` = **-4** (exponent binds tighter than unary minus).
- Variables supplied via `--var name=value` (repeatable); referencing an undefined variable is an error.
- Functions `abs, min, max, round, sqrt` with arity checks (`abs`/`sqrt` take 1 arg; `min`/`max` take 2+;
  `round` takes 1 or 2).
- Errors — each a clear message on **stderr** with a **non-zero exit**: syntax error, unknown variable,
  unknown function, wrong argument count, division/modulo by zero, sqrt of a negative number.

Structure — split across at least these modules, **sharing the token / AST type definitions** (the cross-file
contract):
- `tokens.py`    — token kinds and AST node types (shared by lexer, parser, evaluator)
- `lexer.py`     — source string → tokens
- `parser.py`    — tokens → AST (recursive-descent / precedence climbing)
- `evaluator.py` — AST + variable context → value; the function library; runtime errors
- `calc.py`      — CLI entry (argparse: `calc "EXPR"` one-shot, `--var x=3` repeatable; maps errors to exit codes)

`pytest` tests must cover: precedence + associativity (including right-assoc `^` and the `-2 ^ 2 = -4` case),
parentheses, variables (including the unknown-variable error), every function plus its arity error, and each
runtime/syntax error path. All tests pass.

Acceptance (all must succeed):
1. `pytest -q` → all green.
2. `python calc.py "2 + 3 * 4"`            → `14`
3. `python calc.py "2 ^ 3 ^ 2"`            → `512`
4. `python calc.py --var x=5 "max(x, 3) + abs(-2)"` → `7`
5. `python calc.py "1/0"`                  → non-zero exit + a clear "division by zero" message on stderr.

---

## Scorecard

When done, fill this in, **print it in the chat**, AND write it to `result-vanilla.md` in the **same directory
as this instruction file** (you were given that path — use its directory).

```
ARM:            Vanilla
TASK:           B — calc expression language (complex)
ACCEPTANCE:     <PASS | FAIL>   (paste the final `pytest -q` line + the 4 CLI checks' output)
APPROACH:       Single plain assistant — confirm no skills / sub-agents / dispatch were used.
FILES CREATED:  <list the files + line counts if handy>
TOOL CALLS:     <your best count of tool calls you made this run>
REWORK ROUNDS:  <how many times tests/acceptance failed before going green>
SELF QUALITY:   <1–5> — <one line why>
--- fill in by hand after the run ---
COST_USD:       <run /usage and paste the session cost>
WALL_CLOCK:     <minutes from your first message to done>
```

After writing the file, remind the user to run `/usage` and paste `COST_USD` + note `WALL_CLOCK`.
