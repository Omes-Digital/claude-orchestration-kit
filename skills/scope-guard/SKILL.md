---
name: scope-guard
description: A small discipline a sub-agent (implementer) invokes to stay inside its contract — confirm the allowed file list, treat the out-of-scope list as a deny-list, and when the work genuinely needs something outside scope, halt and surface ONE crisp question UP to the architect instead of guessing or wandering. Use when executing a dispatched contract, when a step seems to need an unlisted file, or when the contract looks wrong mid-task. For implementer sub-agents (you cannot spawn your own sub-agents, so escalation = a clear report, not improvisation).
---

# Scope-guard — stay in the contract, escalate clean

You're a sub-agent running a dispatched contract. Your single biggest failure mode is **scope drift**: touching a file you weren't given, or "fixing while you're here." This skill is the guardrail.

## At the start — pin the boundary

1. **Restate the allow-list** — the exact files/paths you may edit, verbatim from the contract.
2. **Restate the deny-list** — the out-of-scope items. Treat anything not on the allow-list as denied, not just the named ones.
3. If the contract names **no** explicit file list → that's a broken contract. Halt now, ask for one.

## During — the drift check (run before every edit)

Before each edit, one question: **"Is this file on the allow-list?"**
- **Yes** → proceed.
- **No** → STOP. Do not edit it, do not work around it. Go to *Escalate*.

Tempting drifts that are all out of scope: a "tiny" fix in a neighbouring file, a refactor that makes your change cleaner, updating a caller you noticed is wrong, adding a test in a file you weren't given. Note them for the architect — don't do them.

## Escalate — one crisp question UP

You cannot spawn a sub-agent, so escalation is a **report**, not an action. When blocked or the contract looks wrong:

```
HALT — out of scope / contract issue
Where   — <step / file>
Why     — <what the contract needs that it doesn't allow, or what's wrong>
Options — <the 1–2 ways the architect could resolve it>
Need    — <the one decision you need to proceed>
```

Then stop and wait. A precise halt costs the architect one cheap decision; a wrong guess costs a whole re-built contract. **Halting is success, not failure.**

## Done

End by confirming you touched **only** allow-list files, and list any drifts you deliberately left for the architect. Pairs with `reread-before-edit` (land each edit safely) and `verify-and-report` (prove it works).
