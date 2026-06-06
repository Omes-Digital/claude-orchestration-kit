# Claude Code — Agent Orchestration Kit

A drop-in personalization layer for [Claude Code](https://claude.com/claude-code) that turns a single Opus session into a **tiered architect → implementer orchestration system**, with reusable skills and persistent per-role agent memory.

The idea: keep a frontier model (Opus) as the **architect** doing design, contracts, and triage, and route bounded, well-specified work **down** to cheaper implementer tiers (Sonnet / Haiku). Frontier tokens stay on judgement; mechanical edits run cheap. Skills standardize the recurring workflows, and per-role memory stops agents from relearning the same craft every run.

## What's in the box

| Path | What it is |
|---|---|
| `CLAUDE.md` | The orchestration framework — tiering rules, skill routing, memory loop. Goes at `~/.claude/CLAUDE.md`. |
| `agents/implementer-sonnet.md` | Heavy-tier strict-mode implementer (multi-file / cross-file invariants / schema risk). |
| `agents/implementer-haiku.md` | Light-tier strict-mode implementer (single-file mechanical edits). |
| `skills/dispatch/` | Architect→implementer orchestration: strict contract + tier pick + two-stage review gate. |
| `skills/tdd/` | Test-driven development (red-green-refactor, vertical slices). |
| `skills/diagnose/` | Disciplined root-cause diagnosis loop for hard bugs. |
| `skills/review-diff/` | Multi-axis code-review rubric with a confidence gate. |
| `agent-memory/` | Pre-seeded per-role global memory (`architect`, `explorer`, `researcher`, `implementer`, `reviewer`, `auditor`, `memory-curator`) + the framework README. |

## The core idea in one diagram

```
        ┌─────────────────────────────────────────────┐
        │  ARCHITECT  (Opus, this session)            │
        │  design · contract · triage · review        │
        └───────────────┬─────────────────────────────┘
            dispatch contract (file list + exact change + verify cmd)
        ┌───────────────┴───────────────┐
        ▼                               ▼
  implementer-haiku              implementer-sonnet
  single-file / mechanical       multi-file / cross-file / schema
        │                               │
        └──────────── returns diff ─────┘
                        ▼
        review returns to the MORE capable tier
        (never self-review) → code-review / review-diff
```

## Install

See [`INSTALL.md`](INSTALL.md). Short version: copy `CLAUDE.md`, `agents/`, `skills/`, and `agent-memory/` into your `~/.claude/` directory.

## Design notes / credits

- Tiering + strict-mode executor rules follow the *Plan → Execute → Review* pipeline (review always returns to a more-capable tier; never self-review).
- The bundled skills are best-of-each merges of community skill packs (Matt Pocock, superpowers / Jesse Vincent, Addy Osmani) and Anthropic's `pr-review-toolkit`.
- The memory layer is grounded in CoALA (episodic/semantic/procedural), Cline's Memory Bank, and Anthropic's context-engineering guidance.

This is a personalization layer, not a product — read it, take what fits your workflow, and adapt the rest.
