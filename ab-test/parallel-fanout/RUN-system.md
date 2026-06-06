# RUN — System arm (parallel fan-out)

You are running the **System** arm of an A/B test, **with** the orchestration kit. Do the TASK below by
**orchestrating**, then write a scorecard. This task is the regime orchestration is *for*: many genuinely
independent units that can run concurrently.

---

## TASK  (identical in both arms — do not edit this block)

Implement **six INDEPENDENT formatters** that render a `list[Record]` to text. Each lives in its own module
+ its own test file; **no formatter imports another**. They share only the read-only `record.Record` type
and `sample_records.SAMPLES`.

**Setup:** copy this task's `seed/` to a fresh temp dir (`cp -R seed "$(mktemp -d)/work"`) and work there.
`seed/record.py` and `seed/sample_records.py` are read-only — do not modify them.

**Create (6 independent units + a test each):**
`formatters/fmt_csv.py`, `fmt_markdown.py`, `fmt_json.py`, `fmt_tsv.py`, `fmt_ledger.py`, `fmt_html.py`,
and `tests/test_csv.py … test_html.py`. Column order everywhere: **name, amount, date, category, tags**.

1. **CSV** `to_csv(records)->str` — RFC-4180. Header `name,amount,date,category,tags`. amount `%.2f`. tags
   joined with `;`. Fields containing `,` `"` or newline are double-quoted; internal `"` doubled. Lines end `\r\n`.
   *golden:* `Record("Coffee, large",4.5,"2026-01-02","food",("morning","cash"))` →
   `"Coffee, large",4.50,2026-01-02,food,morning;cash` ; name `Quote "special"` → `"Quote ""special"""`.
2. **Markdown** `to_markdown(records)->str` — GFM table: header row + `---` separator + rows. Escape `|` as `\|`.
   amount `%.2f`. tags joined `, `.  *golden:* `Pipe | char` → cell `Pipe \| char`.
3. **JSON** `to_json(records)->str` — `json.dumps(rows, indent=2)`, each row a dict with keys in the column
   order; amount stays a number, tags stays a list.  *golden:* `json.loads(out)[0]["amount"] == 4.5` and
   `json.loads(out)[2]["tags"] == ["a|b"]`.
4. **TSV** `to_tsv(records)->str` — tab-separated, header included; replace any `\t`/`\n` inside a field with a
   single space; amount `%.2f`; tags joined `;`.  *golden:* name `Tab\tinside` → `Tab inside`.
5. **Ledger** `to_ledger(records)->str` — fixed-width, no header: name left-justified to the widest name, two
   spaces, amount **right**-justified to the widest `%.2f` amount, two spaces, date.  *golden:* with amounts
   `4.50` and `999999.99` present, the amount column width is 9, so `4.50` renders as `     4.50`.
6. **HTML** `to_html(records)->str` — `<table>` with `<thead>`/`<tbody>`; escape `&`<`>`"` in every cell;
   amount `%.2f`; tags joined `, `.  *golden:* `HTML <b>&</b>` → `HTML &lt;b&gt;&amp;&lt;/b&gt;`.

**Verify (identical both arms):** from the work dir, `pytest -q` → all green; then a smoke that imports all
six and renders `SAMPLES` without error.

---

## METHOD (System arm)

You are the **architect** (Opus). The six units are genuinely independent (disjoint files, shared deps are
read-only) — so **fan out**, don't do them yourself:

1. Write **one strict-mode contract per formatter**: each sub-agent owns exactly `formatters/fmt_X.py` +
   `tests/test_X.py`; its deny-list = every other formatter's files **and** `record.py` / `sample_records.py`.
2. **Dispatch all six in parallel** — one message, six `implementer-haiku` (or `-sonnet`) sub-agents.
3. On return: **conflict-check** (no two touched the same file), run the **full** `pytest -q` across the merged
   set **yourself**, and review each diff against its spec + golden case.
4. Time it: **wall-clock from your first action to all-green**.

Then write the scorecard to **`result-system.md`** in the **same directory as this instruction file**:

```
ARM:        System (parallel fan-out)
ACCEPTANCE: <pytest -q output; PASS/FAIL>
METHOD:     <# sub-agents dispatched, tier, in parallel? conflict-check result>
FILES:      <the 12 files created>
WALL_CLOCK: <minutes from your first message to all-green>   <-- headline metric here
API_TIME:   <if shown>
COST_USD:   <from /usage after the run; note architect vs sub-agent split>
REWORK:     <rounds; any agent re-dispatched>
NOTES:      <did parallelism actually overlap? per-agent re-read overhead?>
```

After finishing, run **`/usage`** and fill in `COST_USD`. Then stop.
