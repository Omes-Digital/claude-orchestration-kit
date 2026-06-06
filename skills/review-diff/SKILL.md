---
name: review-diff
description: Multi-axis code-review methodology/rubric for a diff — spec conformance, correctness, silent failures, readability, architecture, security, performance, tests, types, comments, and standards — with a confidence gate and severity labels. Use when reviewing changes, reviewing a diff/PR before merge, auditing what changed since a point, or grading an implementer's returned work. Complements (does not replace) the built-in /code-review command: this is the rubric you reason with; /code-review ultra runs the cloud multi-agent pass. Merged best-of-each from Anthropic's pr-review-toolkit, Addy Osmani, superpowers, and Matt Pocock.
---

# Review-diff — multi-axis review rubric

Runs in the **architect (main) session** on a returned diff (it's an orchestrating skill — don't delegate it into a sub-agent). It's the rubric behind the `dispatch` two-stage review gate.

## Approval standard

Approve when the change **definitely improves overall code health, even if not perfect**. Don't block because it isn't how you'd have written it. But **don't rubber-stamp** — "LGTM" without evidence of review helps no one; sycophancy is a failure mode. Quantify problems ("this N+1 adds ~50ms/item" beats "could be slow"). AI-generated code needs *more* scrutiny, not less — it's confident and plausible even when wrong.

## Scope & diff pinning

Default to the unstaged `git diff`. Against a fixed point, use three-dot: `git diff <fp>...HEAD` + `git log <fp>..HEAD`. **Review changed code, not the whole codebase.** Review the **tests first**.

## Confidence + severity model

- **Confidence 0–100; only report ≥80.** Bands: 91–100 = Critical, 80–89 = Important. Filter aggressively — quality over quantity.
- **Severity labels for output:** `Critical:` blocks merge · *(no prefix)* required · `Nit:` optional polish · `Optional:`/`Consider:` suggestion · `FYI` informational. (Stops authors treating every comment as mandatory.)
- Each finding = axis · confidence · `file:line` · explanation (cite the rule or spec line) · concrete fix.

## Role memory (read first, propose at end)

Before reviewing, read the reviewer role memory: `~/.claude/agent-memory/reviewer/MEMORY.md` (global review craft) and, if the repo has one, `.agent-memory/roles/reviewer/MEMORY.md` (project review rules). After the review, if it surfaced a *reusable* review lesson (a recurring trap class, a project-specific rule worth codifying), emit a `memory_proposal` block (role: reviewer, with evidence) for the architect/`memory-curator` to promote. Don't edit `MEMORY.md` directly.

## Pre-review context (do first)

Understand intent (what + why). Locate the **spec source** (commit issue refs → user-passed path → PRD under `docs/specs/.scratch` → ask). Locate **standards sources** (CLAUDE.md, AGENTS.md, CONTRIBUTING.md, CONTEXT.md, ADRs) — and **skip anything tooling already enforces** (eslint/biome/prettier/tsc); note machine-enforced rules, don't re-check them.

## The axes — check each that the diff touches

1. **Spec conformance** — does it implement what was asked? Three failure modes, each quoting the spec line: (a) requirements missing/partial; (b) behaviour not asked for (scope creep); (c) looks implemented but the implementation is wrong.
2. **Correctness** — logic errors, null/undefined, off-by-one, race conditions, memory leaks, state inconsistency, edge & error paths.
3. **Silent failures & error handling** *(zero tolerance)* — empty catch blocks (forbidden); catch-log-and-continue; returning null/default on error without logging; `?.` used to skip a failing op; unexplained fallback chains; retry exhaustion that never tells the user; **production fallback to mock/stub/fake**. Per handler ask: logging quality ("would this help someone debug 6 months from now?"), user feedback, catch specificity — *list every error this catch could hide* — and whether each fallback is explicit and justified.
4. **Readability & simplicity** — clear names, flat control flow, no clever tricks. But **clarity over brevity**: no nested ternaries (prefer switch/if-else), no dense one-liners, don't remove helpful abstractions or optimise for line count.
5. **Architecture & abstraction** — fits existing patterns, clean boundaries, no circular deps; abstractions earn their complexity (don't generalise before the third use case); duplication is shared.
6. **Security** — input validation at boundaries, secrets hygiene, auth checks, parameterized SQL, output encoding/XSS, external data (APIs, logs, user content, config) treated as untrusted, dependency vulnerabilities.
7. **Performance** — N+1 queries, unbounded loops/fetches, missing pagination, sync-that-should-be-async, hot-path allocations, needless re-renders. Quantify impact.
8. **Test quality** — behavioural (not line) coverage, edge/error cases, regression-catching, descriptive names. Rate gaps 1–10 (10 = critical, must add).
9. **Type design** (when types are touched) — rate 1–10 each: encapsulation, invariant expression, usefulness, invariant enforcement.
10. **Comment & doc quality** — accurate vs the code, **why over what**, no rot, no restating obvious code, no stale TODO/FIXME.
11. **Standards compliance** — adherence to the project's documented standards; cite the rule; distinguish hard violations from judgement calls.

## Cross-cutting passes

- **Dead-code hygiene** — identify orphaned/unreachable code after the change; list it; **ask before deleting**.
- **Dependency discipline** — before any new dep: existing-stack-first, bundle size, maintenance, vulnerabilities, license.
- **Change shape** — size (~100 lines good / ~300 acceptable / ~1000 split); a PR that refactors *and* adds a feature is two PRs — split them.

## Honesty & disagreement

Resolution hierarchy: **facts > style guides > design principles > consistency**. Don't accept "I'll clean it up later" (deferred cleanup rarely happens). Comment on the code, not the person.

## Output — hand back to the architect

- Findings grouped by severity; each with axis · confidence · `file:line` · explanation (cite rule/spec) · concrete fix — and a **corrected-code snippet** for error-handling findings.
- Optionally split **Standards** vs **Spec** sections so one axis can't mask the other.
- A verdict line: **Approve** / **Request changes**, with per-axis finding counts and the single worst issue.
- **Action triage:** Critical → must fix before push; Important → before proceeding; Nit/Optional → defer. Feeds the architect's pre-push review.

## How the author/implementer should receive findings (companion behavior)

Verify before implementing: READ → UNDERSTAND → VERIFY → EVALUATE → RESPOND → IMPLEMENT, testing each fix individually. Clarify *all* unclear items before implementing *any* (partial understanding → wrong implementation). **YAGNI grep**: before "implementing properly," grep for real usage; if unused, propose removal. No performative agreement ("you're absolutely right!") — actions over words. External feedback = suggestions to evaluate, not orders; push back with reasoning when the reviewer lacks context or is wrong. Implement in order: blocking/security → simple fixes → complex fixes.

## Red flags

Reporting low-confidence noise · rubber-stamping · fixing a test by disabling it · accepting "tests pass so it's fine" · treating a Nit as a blocker · reviewing the whole codebase instead of the diff.
