# Changelog

All notable changes to this kit are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this is a personalization kit, not a versioned product, so
dates matter more than version numbers.

## [Unreleased]

### Added — orchestrator features
- Three small **sub-agent skills** for the cheap implementer tier (own skills now total **eight**):
  `scope-guard` (stay inside the contract's file list, escalate clean), `reread-before-edit` (re-read +
  anchor so edits land on the right bytes), `verify-and-report` (run the contract's check, emit a verbatim
  PASS/FAIL evidence block + a memory proposal). Distilled from the implementer agent-def rules into
  discrete, on-demand skills.
- `scripts/statusline.sh` and `scripts/statusline.ps1` — an **opt-in** Claude Code status line showing the
  live context-window % with a `/compact` nudge past a threshold (`KIT_COMPACT_AT`, default 75%). Installed
  to `~/.claude/scripts/`; enable it in `settings.json` (see `INSTALL.md` §2). Not turned on automatically.
- `CLAUDE.md` — a "Context hygiene" section: recommend `/compact` at work-cluster breakpoints (not at a
  magic token number the model can't read) to keep the architect session lean.
- `install.sh --uninstall` / `install.ps1 -Uninstall` — a clean removal path. Dry-run by default (previews
  the kit-owned files it would delete); `--yes` / `-Yes` actually removes. Keeps a customized/merged
  `CLAUDE.md`, never touches skills/agents you added yourself, and leaves backups in place.

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
