# Claude Code — Agent Orchestration Kit

> 👋 **New to Claude Code, or want the quick path in? Read [`START-HERE.md`](START-HERE.md) first.**
> It has a 5-minute "try one skill" path and a one-command installer. The rest of this README is the
> design rationale.

A drop-in personalization layer for [Claude Code](https://claude.com/claude-code): a **disciplined frontier-first workflow** — a confidence gate before you build, reusable skills, context hygiene, and persistent per-role memory — with multi-agent **orchestration as an opt-in scaling tool**, not the default.

The honest idea (we measured it): for any task a strong model holds in one context, **do it yourself in one pass** — that's cheaper and faster than handing it off. We ran this kit's own [`ab-test/`](ab-test/README.md) harness and tiered dispatch cost **+14–24% and ~2× the wall-clock for identical correctness** ([findings](ab-test/FINDINGS.md)). So the kit leads with what actually pays every day — `align` (get the spec right before building), skills as methodology, context hygiene, and memory — and reserves architect→implementer tiering for the cases that genuinely earn it: work **too big for one context**, a **genuinely parallel** fan-out, or **fresh-eyes** review.

## What's in the box

| Path | What it is |
|---|---|
| `CLAUDE.md` | The playbook — frontier-first working model, skill routing, context hygiene, memory loop (tiering is the gated scaling tool, not the default). Goes at `~/.claude/CLAUDE.md`. |
| `agents/implementer-sonnet.md` | Heavy-tier strict-mode implementer (multi-file / cross-file invariants / schema risk). |
| `agents/implementer-haiku.md` | Light-tier strict-mode implementer (single-file mechanical edits). |
| `skills/align/` | Session-start alignment gate: diverge → ≥95% confidence in one batched question round → confirmed brief, *before* any work or dispatch. |
| `skills/dispatch/` | Architect→implementer orchestration: strict contract + tier pick + two-stage review gate. |
| `skills/tdd/` | Test-driven development (red-green-refactor, vertical slices). |
| `skills/diagnose/` | Disciplined root-cause diagnosis loop for hard bugs. |
| `skills/review-diff/` | Multi-axis code-review rubric with a confidence gate. |
| `skills/scope-guard/` · `reread-before-edit/` · `verify-and-report/` | Three small sub-agent disciplines for the implementer tier: stay in-contract & escalate clean, land edits on the right bytes, close with verbatim evidence. |
| `scripts/statusline.sh` · `statusline.ps1` | Opt-in status line: live context-window % with a `/compact` nudge past a threshold. |
| `agent-memory/` | Pre-seeded per-role global memory (`architect`, `explorer`, `researcher`, `implementer`, `reviewer`, `auditor`, `memory-curator`) + the framework README. |
| `vendor/mattpocock/` | 9 skills vendored unmodified from [`mattpocock/skills`](https://github.com/mattpocock/skills) (MIT). |
| `vendor/superpowers/` | 14 skills vendored unmodified from [`obra/superpowers`](https://github.com/obra/superpowers) (MIT). |
| `install.sh` / `install.ps1` | One-command installers (macOS/Linux · Windows) with backup, doctor (`--check`), and `--all`. |
| `settings.example.json` | Beginner-safe `~/.claude/settings.json` baseline. |
| `START-HERE.md` · `docs/` | Beginner on-ramp: glossary, skill cheat-sheet, worked example, FAQ. |
| `ab-test/` | A self-run A/B harness to measure the kit vs a vanilla session on the same task (cost · speed · quality). We ran it — the results [reframed this kit](ab-test/FINDINGS.md). Honest by design — see [`ab-test/README.md`](ab-test/README.md). |

> The `vendor/` skills are third-party MIT-licensed work redistributed with their original
> license + attribution — see [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md). They are
> optional companions to the framework; install the ones you want (see `INSTALL.md`).

## The core idea in one diagram

```
        ┌──────────────────────────────────────────────────┐
        │  /align — confidence gate (≥95%) before you build │
        │  diverge · question once · confirmed brief        │
        └───────────────────────┬──────────────────────────┘
                                ▼
        ┌──────────────────────────────────────────────────┐
        │  DO IT IN ONE PASS  (Opus, this session)          │  ◀─ the default:
        │  design · build · tdd / diagnose · review my diff │     cheapest & fastest for
        └───────────────────────┬──────────────────────────┘     anything that fits one context
                                │
       too big for one context?  ·  genuinely parallel?  ·  want fresh eyes?
                       │ no ──▶ you're done            │ yes
                                                        ▼
        ┌──────────────────────────────────────────────────┐
        │  ORCHESTRATE — dispatch a strict contract         │  ◀─ the exception:
        │  architect → implementer-haiku / -sonnet → review │     earns its overhead only at scale
        └──────────────────────────────────────────────────┘
```

> Why this shape and not "architect dispatches everything"? Because we measured the everyday case
> and dispatch lost — see [`ab-test/FINDINGS.md`](ab-test/FINDINGS.md).

<!-- SCREENSHOT (optional): a real diagram or a terminal capture of the flow in action.
     Save as docs/assets/flow-diagram.png and embed here. See docs/assets/README.md. -->

## Prerequisites

- **[Claude Code](https://claude.com/claude-code) installed** (the CLI). Follow the official install docs.
- An **Anthropic account / plan**. The architect→implementer *tiering* assumes access to multiple models
  (Opus + Sonnet/Haiku), but it's an **optimization, not a requirement** — every skill works on a single
  model. No Opus? Use Sonnet and ignore the tier-routing. ([FAQ](docs/FAQ.md))
- After installing the kit, **restart Claude Code** so it picks up the new skills/agents.

## Install

**Fastest:** run the installer from the repo root.

```bash
bash install.sh            # macOS / Linux  (add --all for the vendored skills)
```
```powershell
pwsh -File install.ps1     # Windows        (add -All for the vendored skills)
```

It backs up anything it touches, won't overwrite your own `CLAUDE.md`, and `--check` verifies the install.
Full details, manual steps, and Windows notes are in [`INSTALL.md`](INSTALL.md).

## Beginner docs

| Doc | What it's for |
|---|---|
| [START-HERE.md](START-HERE.md) | The on-ramp — pick a level and go |
| [docs/GLOSSARY.md](docs/GLOSSARY.md) | Plain-language definitions of the jargon |
| [docs/SKILL-CHEATSHEET.md](docs/SKILL-CHEATSHEET.md) | "I want to… → use this skill" |
| [docs/EXAMPLE.md](docs/EXAMPLE.md) | A real session, narrated end-to-end |
| [docs/FAQ.md](docs/FAQ.md) | Setup snags, cost/model/permission questions |

## Design notes / credits

- **Frontier-first by measurement.** We A/B-tested the kit against a vanilla session ([`ab-test/FINDINGS.md`](ab-test/FINDINGS.md)); tiered dispatch cost more for identical results on everyday work, so it's reserved for scale. The tiering that remains follows the *Plan → Execute → Review* pipeline (review always returns to a more-capable tier; never self-review).
- Four of the original five top-level skills (`dispatch`, `tdd`, `diagnose`, `review-diff`) are best-of-each merges of community skill packs (Matt Pocock, superpowers / Jesse Vincent, Addy Osmani) and Anthropic's `pr-review-toolkit`. The other four are **original to this kit**: `align` (the confidence gate that runs *before* dispatch) and the three small sub-agent disciplines `scope-guard`, `reread-before-edit`, and `verify-and-report`.
- The `vendor/` skills are redistributed **unmodified** from [`mattpocock/skills`](https://github.com/mattpocock/skills) and [`obra/superpowers`](https://github.com/obra/superpowers), both MIT — full attribution in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md). All credit for those goes to their respective authors.
- The memory layer is grounded in CoALA (episodic/semantic/procedural), Cline's Memory Bank, and Anthropic's context-engineering guidance.

This is a personalization layer, not a product — read it, take what fits your workflow, and adapt the rest.
