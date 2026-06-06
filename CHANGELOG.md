# Changelog

All notable changes to this kit are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this is a personalization kit, not a versioned product, so
dates matter more than version numbers.

## [Unreleased]

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
- `CLAUDE.md` — added a one-line "adopt incrementally" pointer to `START-HERE.md` (framework text unchanged).

## 2026-06-06 — initial public release
- Tiered architect→implementer orchestration framework (`CLAUDE.md`).
- Two strict-mode implementer agents (`implementer-sonnet`, `implementer-haiku`).
- Five own skills: `align`, `dispatch`, `tdd`, `diagnose`, `review-diff`.
- Pre-seeded per-role agent memory for seven roles.
- 23 vendored community skills (9 from `mattpocock/skills`, 14 from `obra/superpowers`), redistributed
  unmodified under their MIT licenses with attribution in `THIRD_PARTY_LICENSES.md`.
