# Worked example — the loop, start to finish

A short, **illustrative** walkthrough of how the kit's pieces fit together on a real task. This is a
narrated sketch, not a transcript to copy verbatim — your wording and Claude's exact replies will differ.
The point is the *shape* of the loop: **align → dispatch → implement → review**.

> Setup: you've done a Level 3 install (`install.sh --all`) and you're in a project, talking to an
> Opus session (the "architect").

---

## The task

> **You:** Add a `--json` flag to our `report` CLI command so it can output machine-readable results.

A reasonable request — but notice what's unspecified: *which* command file? JSON shape? What about the
existing human-readable output? Jumping straight to code risks building the wrong thing.

## Step 1 — `/align` (clarify before any work)

> **You:** /align

Claude diverges on the request, reads what it can from the repo and memory, finds the genuinely ambiguous
forks, and asks them **in one batched round** (not ten one-off questions):

> **Claude:**
> 1. Should `--json` *replace* the human output or be an alternative mode? → *(Recommended: alternative; human stays default)*
> 2. JSON shape — flat object, or `{data, meta}` envelope?
> 3. Pretty-printed or compact?

You answer. Claude restates a **confirmed brief**:

> **Brief**
> Goal — add `--json` to `report`, alternative output mode, default stays human
> Scope — in: `src/cli/report.ts`; out: other commands, the formatter lib
> Approach — add flag, branch on it, emit compact `{data, meta}` JSON
> Confidence — 96%

**Why this step matters:** a wrong assumption here would cost a whole build-and-throw-away cycle. A few
clarifying tokens on Opus is far cheaper. → [`align`](../skills/align/SKILL.md)

## Step 2 — `/dispatch` (write the contract, pick the tier)

> **You:** dispatch this

This is a single-file, well-specified change → the light tier (`implementer-haiku`). `dispatch` writes a
**strict-mode contract**:

```
Tier:        implementer-haiku
May touch:   src/cli/report.ts
Change:      add `--json` boolean flag; when set, print JSON.stringify({data, meta})
             instead of the table; default path unchanged.
Deny-list:   do NOT modify the formatter lib, other commands, or tests outside report.
Verify:      npm test -- report   &&   npm run report -- --json | jq .
```

**Why this step matters:** the implementer gets exact scope and a way to check itself. The deny-list stops
the change from sprawling. → [`dispatch`](../skills/dispatch/SKILL.md)

## Step 3 — the implementer executes

The Haiku implementer makes the edit, re-reads it, runs the verify commands, and reports back:

> **implementer-haiku:** Changed `src/cli/report.ts` (+12 lines). `npm test -- report` → 14 passing.
> `npm run report -- --json | jq .` → valid JSON. Done.

It does **not** commit or push — that's your call. It would **halt and report** if, say, the change needed a
second file (a sign the contract was wrong).

## Step 4 — review comes back *up* a tier

The architect (Opus) — never the implementer itself — reviews the diff:

> **You:** /review-diff   *(or the built-in `/code-review`)*

Claude checks correctness, the JSON shape against the brief, error handling, and whether tests cover the new
flag. Say it flags one thing:

> **review-diff:** [required] `--json` doesn't suppress a stray `console.log` progress line, so output isn't
> pure JSON. Everything else conforms to the brief.

Quick fix (another tiny dispatch, or just do it inline), re-verify, and now **you** commit and push.

**Why this step matters:** the model that wrote the code is the worst judge of it. Review returns to a more
capable tier. → [`review-diff`](../skills/review-diff/SKILL.md)

---

## What just happened

```
/align        you + Opus     →  agreed brief (no wrong-thing risk)
/dispatch     Opus           →  precise contract, cheap tier chosen
implement     Haiku          →  edit + self-verify, halts if surprised
/review-diff  Opus           →  catch the one real issue
you           human          →  commit + push
```

Opus tokens were spent only on **judgement** (clarify, design the contract, review). The mechanical typing
ran on cheap Haiku. Nothing was committed without your say-so.

## Don't over-orchestrate

For a true one-liner, skip all of this and just ask Claude to make the change — `dispatch` itself says
"trivial → just do it." The loop earns its keep on tasks big or ambiguous enough that a wrong turn is
expensive. See the [cheat-sheet](SKILL-CHEATSHEET.md) for picking the right tool per situation.
