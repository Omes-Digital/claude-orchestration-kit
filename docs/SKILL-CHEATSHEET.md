# Skill cheat-sheet — "I want to… → use this"

23 + 8 skills is a lot. Here's how to pick one. **Bundled** skills are in `skills/` (installed by default).
**Vendored** skills are in `vendor/` (install with `--with-vendor` / `-WithVendor`, or copy individually —
see [INSTALL.md](../INSTALL.md)). Trigger any skill by typing `/its-name`, or just describe your goal and
Claude usually picks the right one.

## The five you'll reach for most (all bundled)

| I want to… | Skill | What it does |
|---|---|---|
| Make sure Claude understood me before it starts | **`/align`** | Asks the few clarifying questions that matter, in one round, then states a confirmed brief. The highest-leverage habit here. |
| Figure out why something's broken | **`/diagnose`** | Reproduce → hypothesise → instrument → fix the *root* cause → regression-test. |
| Build a feature test-first | **`/tdd`** | Red-green-refactor: failing test first, then the code to pass it. |
| Review changes before I commit | **`/review-diff`** | Multi-axis rubric (bugs, security, tests, …) with a confidence gate. |
| **Scale** a task too big for one session, or fan out parallel work | **`/dispatch`** | Writes the precise hand-off (files · change · verify) and picks the tier. *Not for everyday work* — a strong model does that in one pass ([why](../ab-test/FINDINGS.md)). |

> **The default isn't a hand-off.** For anything that fits one context, do it in-session on your strongest
> model — measurably cheaper and faster than dispatching ([findings](../ab-test/FINDINGS.md)). `dispatch` is
> the *scaling* exception (too big for one context · genuinely parallel · fresh-eyes review), not step two of
> every task.

## By phase

### 🔍 Understand the request / explore
| Goal | Skill | Source |
|---|---|---|
| Clarify a fuzzy request | `align` | bundled |
| Research a topic across the web, with citations | `deep-research` | built-in |

### 🧭 Plan / design
| Goal | Skill | Source |
|---|---|---|
| Have Claude interrogate my plan for holes | `grill-me` | vendor (mattpocock) |
| Stress-test a plan against my project's docs/domain | `grill-with-docs` | vendor (mattpocock) |
| Try a throwaway prototype before committing | `prototype` | vendor (mattpocock) |
| Step back and reconsider the approach | `zoom-out` | vendor (mattpocock) |
| Turn a discussion into a written plan | `writing-plans` | vendor (superpowers) |
| Brainstorm options | `brainstorming` | vendor (superpowers) |
| Break a plan into trackable issues | `to-issues` | vendor (mattpocock) |
| Turn context into a PRD | `to-prd` | vendor (mattpocock) |
| Triage incoming bugs/requests | `triage` | vendor (mattpocock) |

### 🔨 Build
| Goal | Skill | Source |
|---|---|---|
| Scale work too big for one session / fan out independent pieces | `dispatch` | bundled |
| Build/fix test-first | `tdd` or `test-driven-development` | bundled / vendor |
| Debug methodically | `diagnose` or `systematic-debugging` | bundled / vendor |
| Run independent work in parallel safely | `dispatching-parallel-agents`, `using-git-worktrees` | vendor (superpowers) |
| Execute an agreed plan step by step | `executing-plans`, `subagent-driven-development` | vendor (superpowers) |
| Improve a codebase's architecture | `improve-codebase-architecture` | vendor (mattpocock) |

> **Sub-agent disciplines** — these three are for the *implementer tier* (Claude reaches for them while
> executing a dispatched task; you rarely type them yourself). All bundled.

| Goal | Skill | Source |
|---|---|---|
| Stay inside the contract's files / escalate cleanly when blocked | `scope-guard` | bundled |
| Make every edit land on the right bytes (re-read + anchor) | `reread-before-edit` | bundled |
| Close a task with verbatim PASS/FAIL evidence + a memory proposal | `verify-and-report` | bundled |

### ✅ Verify / review
| Goal | Skill | Source |
|---|---|---|
| Review a diff against a rubric | `review-diff` | bundled |
| Confirm a change actually works (run it) | `verify`, `verification-before-completion` | built-in / vendor |
| Ask for / respond to a code review | `requesting-code-review`, `receiving-code-review` | vendor (superpowers) |
| Wrap up a branch cleanly | `finishing-a-development-branch` | vendor (superpowers) |

### 🧰 Manage the session
| Goal | Skill | Source |
|---|---|---|
| Keep the session lean / watch context % | `/compact` at breakpoints + the opt-in `scripts/statusline.sh` meter | built-in / bundled |
| Cut token use ~75% (terse mode) | `caveman` | vendor (mattpocock) |
| Compress the session into a hand-off doc | `handoff` | vendor (mattpocock) |
| Write a brand-new skill | `write-a-skill` / `writing-skills` | vendor (mattpocock / superpowers) |
| Learn what skills are available | `using-superpowers` | vendor (superpowers) |

## Notes
- **Built-in** = ships with Claude Code itself, no install needed.
- **Bundled** = in this kit's `skills/`, installed by the default `install.sh`.
- **Vendored** = in `vendor/`, install with `--with-vendor` (see [INSTALL.md](../INSTALL.md)).
- `align`'s flow uses `dispatch`, `caveman`, and `grill-me` — install those for the full chain (the
  default `--all` install covers them).
- Some bundled skills overlap a vendored one on purpose (e.g. `tdd` vs `test-driven-development`); the
  bundled ones are merged supersets — prefer them.
