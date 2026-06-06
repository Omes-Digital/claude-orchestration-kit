---
name: reread-before-edit
description: A small editing-safety discipline for a sub-agent making code edits — re-read the exact target region immediately before each edit, anchor the search/replace on unique surrounding context (never a bare common string), then re-read after to confirm the bytes landed before moving on. Use when applying any non-trivial edit, when a file may have changed since you last read it, or when an edit touches a string that appears more than once. Kills stale-context edits and silent wrong-location replacements.
---

# Reread-before-edit — land every edit on purpose

The cheap-tier failure mode is editing against a **remembered** version of a file that's now stale, or replacing the *first* match of a string that occurs many times. This three-beat loop prevents both.

## The loop — per edit

1. **Re-read right before.** Read the exact region you're about to change *now* — not your memory of it from ten steps ago. The file may have moved under you (an earlier edit, a formatter, a different tool). Match what's actually on disk.

2. **Anchor the change.** Make the search target **unique**:
   - Include enough surrounding lines that the match is unambiguous — a function signature line, a unique comment, the line above and below.
   - Never anchor on a bare common token (`}`, `return`, `import x`, `const i = 0`) — it'll hit the wrong occurrence.
   - If the string genuinely repeats and you mean *all* of them, say so explicitly (replace-all); otherwise widen the anchor until exactly one match remains.

3. **Re-read right after.** Confirm the new bytes are present and the surrounding code still parses/reads correctly. Only then move to the next edit. If the edit tool says it changed nothing, or changed the wrong place — STOP, re-read, fix; don't stack a second edit on an uncertain first.

## Why it's worth the tokens

A re-read is cheap; a wrong-location edit is expensive — it can silently corrupt unrelated code, pass a shallow check, and surface as a baffling bug later. Two small reads per edit beats one debugging session.

## Done

Every edit was re-read before and confirmed after. Pairs with `scope-guard` (edit only allowed files) and `verify-and-report` (run the contract's check before you report).
