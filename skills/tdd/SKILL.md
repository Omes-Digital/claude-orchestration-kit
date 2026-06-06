---
name: tdd
description: Test-driven development — red-green-refactor with vertical slices and behavior-focused tests. Use when implementing any feature or fixing any bug, before writing implementation code; when a bug report arrives; before modifying existing behavior; when you want integration tests; or when the user mentions "red-green-refactor" or "test-first". Merged best-of-each from Matt Pocock, superpowers (Jesse Vincent), and Addy Osmani.
---

# Test-Driven Development

**Core:** If you didn't watch the test fail, you don't know if it tests the right thing. Tests are proof — "seems right" is not done. A codebase with good tests is an AI agent's superpower; one without is a liability.

## The Iron Law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

Wrote code before the test? **Delete it. Start over.** Don't keep it as "reference," don't "adapt" it while writing the test, don't look at it. Delete means delete. Violating the letter of this rule is violating its spirit.

## When to use / when not

Use for all features, bug fixes, and behavior changes. Skip for config, docs, pure formatting, and static assets (no behavior to verify).

## Plan before the loop

Confirm the public interface you'll test through. Prioritise behaviours — you can't test everything; confirm with the user which paths matter most (critical paths and complex logic, not every edge case). Match test names to the domain glossary / ADRs so they read as specification. Get user approval on the plan.

## The loop: Red → Verify Red → Green → Verify Green → Refactor

1. **RED** — write one failing test for the next small behaviour.
2. **Verify RED** — run it; watch it fail. *Test passes already?* → you're testing existing behaviour; fix the test. *Test errors (not asserts)?* → fix the error, re-run until it fails for the right reason.
3. **GREEN** — write the minimum code to pass. No more.
4. **Verify GREEN** — run it; watch it pass. (Don't re-run a clean command on unchanged code — that adds no confidence.)
5. **REFACTOR** — improve structure while green. **Never refactor while RED — get to green first.** Run tests after each refactor step.
6. **Repeat.**

## Sequence with vertical slices, not horizontal

**DO NOT** write all tests first, then all implementation — that's horizontal slicing and it produces crap tests: you outrun your headlights, committing to test structure before you understand the implementation.

```
WRONG (horizontal):  all tests ──► all code
RIGHT (vertical):    test ─► code ─► test ─► code ...
```

Use a **tracer bullet**: the first test proves the path end-to-end, then each later test responds to what you learned from the previous cycle.

## Bug fixes — the Prove-It pattern

Write a failing test that **reproduces the bug** first (it must fail without the fix and pass with it), then fix the root cause. Optionally spawn a sub-agent to write the repro test *without knowledge of the fix* — makes it more robust. Never fix a bug without a regression test.

## Writing good tests

- **Test behaviour through the public interface, not implementation details.** Code can change entirely; tests shouldn't. Warning sign: a test breaks when you rename an internal function though behaviour is unchanged — that test was testing implementation.
- **Assert on state/outcome, not which methods were called.**
- **DAMP over DRY** — a test should read like a specification ("user can checkout with valid cart").
- **Arrange–Act–Assert**, one assertion per concept, descriptive names.
- **Prefer real implementations.** Test-double ladder: Real > Fake > Stub > Mock. Use mocks only for slow / non-deterministic / uncontrollable side effects. Over-mocking creates tests that pass while production breaks.

## Test taxonomy (integration vs unit)

Think in test *sizes* by resource cost: **Small** (no I/O, in-process) / **Medium** (local I/O, DB) / **Large** (network, full stack). Aim ~80 / 15 / 5%. Most logic → small unit tests; cross-component contracts → medium; critical user journeys → a few large/integration tests.

## When stuck, the test is telling you something

Hard to test = hard to use — listen to it. Can't test without touching internals → the API you wish existed is the real design. Must mock everything → too coupled, use dependency injection. Setup is huge → extract helpers / simplify the seam.

## Refactor targets

Extract duplication, deepen modules (small interface / deep implementation), apply SOLID, act on what new code reveals about existing code.

## Anti-patterns to avoid

Testing implementation details · flaky/time-dependent tests · testing the framework · snapshot abuse · no test isolation · mocking everything.

## Common rationalizations (all wrong)

"Too simple to test" · "I'll test after" · "I manually tested it" · "It's just a prototype" (prototypes become production) · "Existing code has no tests" · "Run it again to be sure" (no code changed → no new info) · "TDD is dogmatic just this once" (that's the rationalization).

## Red flags — STOP and start over

Tests pass on the first run · writing code before the test · refactoring while red · a bug fix with no repro test · editing a test just to make it pass.

## Verification checklist

Watched each test fail first · failed for the expected reason · output is pristine · uses real code where practical · critical paths and edge cases covered · bug fixes have a repro test · coverage not decreased.

**Final rule:** Production code → a test exists and failed first. Otherwise → it isn't TDD.
