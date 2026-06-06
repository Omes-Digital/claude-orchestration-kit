# Changelog

All notable changes to this kit are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this is a personalization kit, not a versioned product, so
dates matter more than version numbers.

## [Unreleased]

### Changed — reframed to frontier-first (measured)
- **The kit's core stance flipped, on its own evidence.** We ran the `ab-test/` harness (three tasks,
  greenfield → cross-cutting change in an existing repo); tiered architect→implementer dispatch cost
  **+14–24% and ~2× the wall-clock for identical correctness** every time, and the two-stage review gate
  caught nothing. So `CLAUDE.md` now leads **frontier-first** — do the work yourself, in one pass, on the
  strongest model — and reserves orchestration for tasks that are **too big for one context**, **genuinely
  parallelizable**, or want **fresh-eyes** review. Full write-up + honest caveats in
  [`ab-test/FINDINGS.md`](ab-test/FINDINGS.md) (new).
- `CLAUDE.md` — replaced "Agent Orchestration — tier by task weight" with "**Working model — frontier-first;
  orchestrate only to scale**": a measured cost table, the three scaling gates, and a new "what actually
  carries the value" section elevating `align`, methodology skills, context hygiene, and memory. Reframed the
  default play, tier-selection, and the old "dispatch *is* context hygiene" claim (it's a duplication **tax**
  on existing code, not a free win).
- `skills/dispatch/` — now **self-gating**: its description and core principle tell the model not to dispatch
  by reflex — clear the too-big / parallel / fresh-eyes gate first, else keep it in-session on Opus.
- `skills/align/` — reframed so its value reads as independent of dispatch (a right spec helps a solo pass
  just as much); flagged as the kit's highest-leverage habit.
- `README.md` · `START-HERE.md` — headline, core diagram, and Level 3 reframed so orchestration reads as a
  gated scaling tier, not the destination everyone should reach.

### Added — orchestrator features
- Three small **sub-agent skills** for the cheap implementer tier (own skills now total **eight**):
  `scope-guard` (stay inside the contract's file list, escalate clean), `reread-before-edit` (re-read +
  anchor so edits land on the right bytes), `verify-and-report` (run the contract's check, emit a verbatim
  PASS/FAIL evidence block + a memory proposal). Distilled from the implementer agent-def rules into
  discrete, on-demand skills.
- `scripts/statusline.sh` and `scripts/statusline.ps1` — an **opt-in** Claude Code status line showing live
  context use (`ctx NN% · Nk`) with a **model-aware** `/compact` nudge by window %: the Opus architect nudges
  earlier (40%) than the cheaper tiers (60%). Because % is window-relative, 40% is ~80k tokens on a 200k model
  but ~400k on a 1M-context one. Optional absolute-token cap via `KIT_COMPACT_TOKENS` (off by default); percent
  override via `KIT_COMPACT_AT`. Installed to `~/.claude/scripts/`; enable it in `settings.json` (see
  `INSTALL.md` §2). Not turned on automatically.
- `CLAUDE.md` — a "Context hygiene" section: recommend `/compact` at work-cluster breakpoints (not at a
  magic token number the model can't read) to keep the architect session lean.
- `install.sh --uninstall` / `install.ps1 -Uninstall` — a clean removal path. Dry-run by default (previews
  the kit-owned files it would delete); `--yes` / `-Yes` actually removes. Keeps a customized/merged
  `CLAUDE.md`, never touches skills/agents you added yourself, and leaves backups in place.

### Added — measure it yourself
- `ab-test/` — a self-run A/B harness to test the kit against a vanilla session on the *same* task and
  compare cost / wall-clock / quality on your own setup. Each task is a folder with self-contained
  `RUN-system.md`, `RUN-vanilla.md` (paste one file's path into a fresh chat; it does the task under that
  condition and writes its scorecard) and `COMPARE.md` (reads both, gives an honest verdict — explicitly told
  not to flatter the kit). Ships two tasks: `expense-tracker/` (warm-up) and `calculator/` (a lexer→parser→
  evaluator expression language — complex, real cross-file invariants, where the kit's edge should show if it
  exists) and `existing-repo/` (a cross-cutting change — add due-dates end-to-end — to a **pre-seeded existing**
  layered todo app; the regime the kit is actually built for, where a single pass can drop a layer or cause a
  regression). `result-*.md` outputs are git-ignored. Built deliberately honest — one run is an anecdote, not proof.

### Added — beginner on-ramp
- `START-HERE.md` — single entry point with a 3-level progressive adoption path (try one skill → add the
  playbook + memory → full orchestration).
- `install.sh` and `install.ps1` — one-command cross-platform installers with safe backups, never-clobber
  handling for an existing `CLAUDE.md`, `--with-vendor`/`--all` options, and a `--check` doctor mode.
- `settings.example.json` — beginner-safe settings baseline (`defaultMode: "default"`, Workflows enabled,
  no personal plugins).
- `docs/GLOSSARY.md` — plain-language definitions of the kit's jargon.
- `docs/SKILL-CHEATSHEET.md` — "I want to… → use this skill" table, grouped by phase.
- `docs/EXAMPLE.md` — a narrated worked example of the align → dispatch → implement → review loop.
- `docs/FAQ.md` — setup troubleshooting and cost/model/permission questions.
- `docs/assets/README.md` — convention for adding real screenshots to replace the doc placeholders.

### Changed
- `README.md` — added a "new here?" banner, prerequisites, and beginner-doc navigation.
- `INSTALL.md` — added a Prerequisites section, reworked around the install scripts, and added
  cross-platform (macOS/Linux **and** Windows) manual fallbacks and a doctor verify step.
- `CLAUDE.md` — added a one-line "adopt incrementally" pointer to `START-HERE.md`, the "Context hygiene"
  section, and registered the three new sub-agent skills in the routing table and bundled-skills list.
- `install.sh` / `install.ps1` — now also install `scripts/` and verify it in `--check`; own-skill count 5 → 8.

## 2026-06-06 — initial public release
- Tiered architect→implementer orchestration framework (`CLAUDE.md`).
- Two strict-mode implementer agents (`implementer-sonnet`, `implementer-haiku`).
- Five own skills: `align`, `dispatch`, `tdd`, `diagnose`, `review-diff`.
- Pre-seeded per-role agent memory for seven roles.
- 23 vendored community skills (9 from `mattpocock/skills`, 14 from `obra/superpowers`), redistributed
  unmodified under their MIT licenses with attribution in `THIRD_PARTY_LICENSES.md`.
