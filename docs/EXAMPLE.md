# Worked example — the loop, start to finish

A short, **illustrative** walkthrough of how the kit's pieces fit together on a real task. This is a
narrated sketch, not a transcript to copy verbatim — your wording and Claude's exact replies will differ.
The point is the *shape* of the default loop — **align → build it in one pass → review** — and, separately,
*when* you'd escalate to dispatch.

> Setup: you've installed at least Level 2 (`CLAUDE.md`) and you're in a project, talking to an Opus session.

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
clarifying tokens up front is far cheaper — and this is true whether you build it yourself or hand it off.
`align` is the kit's highest-leverage habit. → [`align`](../skills/align/SKILL.md)

## Step 2 — build it, in one pass, right here

This is a single-file, well-specified change that fits comfortably in one context — so the cheapest, fastest
thing is to **just do it on the Opus session you're already in.** No contract, no hand-off, no sub-agent.

> **You:** go

Claude edits `src/cli/report.ts`, adds the flag, branches on it, and runs the checks inline (lean on `tdd`
for the test and `diagnose` if something breaks — they sharpen a *single* pass, no orchestration needed):

> **Claude:** Added `--json` to `report` (+12 lines), with a test. `npm test -- report` → 14 passing.
> `npm run report -- --json | jq .` → valid JSON. Default human output unchanged.

**Why not dispatch this?** Because we measured it: handing a one-context task to a cheaper sub-agent cost
**+14–24% and ~2× the wall-clock for identical results** ([`../ab-test/FINDINGS.md`](../ab-test/FINDINGS.md)).
The sub-agent would re-read files this session already has loaded, and you'd still pay Opus to design and
review. For anything a single pass can hold, **in-session is the optimization.**

## Step 3 — review your own diff before the push moment

The work isn't done until it's checked. Run the rubric on the diff you just produced:

> **You:** /review-diff   *(or the built-in `/code-review`)*

Claude checks correctness, the JSON shape against the brief, error handling, and whether tests cover the new
flag. Say it flags one thing:

> **review-diff:** [required] `--json` doesn't suppress a stray `console.log` progress line, so output isn't
> pure JSON. Everything else conforms to the brief.

Fix it inline, re-verify, and now **you** commit and push. (Want a genuinely independent critic — eyes that
*didn't* write the code? That's a real reason to spin up a separate review agent; see "When you'd dispatch"
below. For most changes, the rubric on your own diff is enough.)

**Why this step matters:** code is easiest to get wrong where you were most confident. A rubric pass before
the push moment catches it. → [`review-diff`](../skills/review-diff/SKILL.md)

---

## What just happened

```
/align        you + Opus     →  agreed brief (no wrong-thing risk)
build         Opus, 1 pass   →  edit + test + self-verify, in-session (cheapest for one-context work)
/review-diff  Opus           →  catch the one real issue
you           human          →  commit + push
```

No sub-agent was spawned, and that's the point: a strong model held the whole task in one context, so adding
a hand-off would only have added cost. Nothing was committed without your say-so.

## When you *would* dispatch

The loop above stays in-session because the task fit one context. Escalate to `/dispatch` only when one of
these holds — the cases where orchestration actually earns its overhead:

- **Too big for one context.** The same `--json` treatment across **40 command files**, or a migration that
  won't fit in one session before quality degrades. Split it; farm the pieces out so each sub-agent (and your
  architect session) stays lean.
- **Genuinely parallelizable.** A dozen *independent* files with no shared state — fan them out concurrently
  for a real wall-clock win (you pay more tokens for the speed).
- **Fresh-eyes isolation.** You want a critic that hasn't seen your reasoning to adversarially review a risky
  change.

Then — and only then — `dispatch` writes the **strict-mode contract** and picks the tier:

```
Tier:        implementer-sonnet        (multi-file slice of a too-big job)
May touch:   src/cli/{report,export,audit,...}.ts   (the lane assigned to this agent)
Change:      add `--json` per the brief; default path unchanged.
Deny-list:   formatter lib, other lanes' files, tests outside this lane.
Verify:      npm test -- <lane>   &&   npm run <cmd> -- --json | jq .
```

Review still comes back **up** a tier (never let the implementer review itself), and **you** own the push
moment. → [`dispatch`](../skills/dispatch/SKILL.md)

## Don't over-orchestrate

The default is *not* to dispatch. For anything a single pass can hold — which is most work — just `align`,
build, and review in-session. The hand-off machinery earns its keep only when a task outgrows one context or
fans out cleanly. See the [cheat-sheet](SKILL-CHEATSHEET.md) for picking the right tool per situation, and
[`../ab-test/FINDINGS.md`](../ab-test/FINDINGS.md) for why.
