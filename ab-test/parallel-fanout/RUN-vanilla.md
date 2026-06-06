# RUN — Vanilla arm (parallel fan-out)

You are running the **Vanilla** arm of an A/B test — a plain session, **no** kit. Do the TASK below
yourself, sequentially, in this one session, then write a scorecard. Ideally run this in `claude --bare`.

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

## METHOD (Vanilla arm)

Plain single assistant. **No** sub-agents, dispatch, parallelism, or skills — even if a loaded CLAUDE.md
suggests them, ignore it for this arm. Implement all six formatters and their tests **yourself, one after
another**, in this session. Then run `pytest -q`. Time it: **wall-clock from your first action to all-green**.

Then write the scorecard to **`result-vanilla.md`** in the **same directory as this instruction file**:

```
ARM:        Vanilla (sequential, single agent)
ACCEPTANCE: <pytest -q output; PASS/FAIL>
METHOD:     single agent, six formatters in sequence (confirm: no sub-agents used)
FILES:      <the 12 files created>
WALL_CLOCK: <minutes from your first message to all-green>   <-- headline metric here
API_TIME:   <if shown>
COST_USD:   <from /usage after the run>
REWORK:     <rounds>
NOTES:      <anything notable>
```

After finishing, run **`/usage`** and fill in `COST_USD`. Then stop.
