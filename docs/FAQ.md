# FAQ & troubleshooting

Common questions and setup snags. New here? Start with [START-HERE.md](../START-HERE.md).

## Setup

### I ran the install but `/skills` (or `/agents`) shows nothing
1. **Restart Claude Code.** It reads `~/.claude/` at startup; new skills/agents won't appear mid-session.
2. **Check the files landed.** Run the doctor:
   ```bash
   bash install.sh --check          # macOS / Linux
   ```
   ```powershell
   pwsh -File install.ps1 -Check    # Windows
   ```
   It prints ✓/✗ for each expected file. Anything ✗ means it wasn't copied — re-run the installer.
3. **Confirm the location.** Files must be under `~/.claude/skills/<name>/SKILL.md`
   (Windows: `%USERPROFILE%\.claude\skills\<name>\SKILL.md`).

### Windows: where is `~/.claude`?
It's in your user home: `%USERPROFILE%\.claude`, e.g. `C:\Users\You\.claude`. In PowerShell you can `cd
~\.claude`. (Note: this is the Claude Code **CLI** folder — not `%APPDATA%\Claude`, which belongs to the
desktop app.)

### How do I install the vendored (community) skills?
They're optional. Install them all with the `--all` flag, or just the vendored ones with `--with-vendor`:
```bash
bash install.sh --with-vendor        # macOS / Linux
```
```powershell
pwsh -File install.ps1 -WithVendor   # Windows
```
Prefer to track upstream for updates? Install them as plugins from their source repos instead — see
[INSTALL.md](../INSTALL.md) and [THIRD_PARTY_LICENSES.md](../THIRD_PARTY_LICENSES.md).

### How do I undo the install? / remove the kit completely?
Run the uninstaller — it **previews first** and only deletes with `--yes`:
```bash
bash install.sh --uninstall          # dry run (lists what would go)
bash install.sh --uninstall --yes    # remove it
```
```powershell
pwsh -File install.ps1 -Uninstall        # dry run
pwsh -File install.ps1 -Uninstall -Yes   # remove it
```
It removes only kit-owned files (own + vendored skills, `implementer-*` agents, `scripts/`, `agent-memory/`,
and an **unchanged** `CLAUDE.md` — a customized/merged one is kept and flagged). Skills/agents you added
yourself are never touched, and your `~/.claude/.kit-backup-<timestamp>/` folders stay put for restores.
Then restart Claude Code. (Prefer manual? Delete those same paths by hand.)

## Cost & models

### Do I need Opus? Will this cost a lot?
**No.** The architect→implementer *tiering* is an optimization to save money on big tasks — it is not
required. Every skill and the playbook work on a single model. If you don't have Opus, run everything on
**Sonnet** (a strong all-rounder) and ignore the tier-routing advice. The kit doesn't spend tokens on its
own; it only shapes how your normal sessions work.

### When does the tiering actually save money?
On larger, well-specified tasks where a powerful model designs the change and a cheap model (Haiku) does the
mechanical typing. For a quick one-file fix, just do it directly — `dispatch` even says so. Don't over-orchestrate.

### What models are these names?
**Opus** = most capable/expensive, **Sonnet** = strong middle, **Haiku** = fast/cheap. Availability depends
on your Anthropic plan. See [GLOSSARY.md](GLOSSARY.md).

## Behavior & permissions

### Claude asks permission for everything — or doesn't ask enough
That's the **permission mode**, set by `defaultMode` in `~/.claude/settings.json`:
- `default` — asks before edits and commands (**safest, recommended for beginners**).
- `auto` — acts more freely without prompting.

The shipped [`settings.example.json`](../settings.example.json) uses `default`. Change it once you trust the
setup.

### What's the difference between this `CLAUDE.md` and a project's `CLAUDE.md`?
- `~/.claude/CLAUDE.md` (this kit) = **global**: applies in every project.
- `<project>/CLAUDE.md` = **project-only**: codebase-specific notes.

Both are loaded; project instructions take precedence for that repo. The kit's global file sets your
*working style*; a project file sets *that project's facts*.

### The playbook changed how Claude behaves and I don't like it
Delete `~/.claude/CLAUDE.md` (or the `CLAUDE.orchestration.md` the installer wrote) and restart. You can
adopt the kit at [Level 1](../START-HERE.md) (just a skill or two) instead — no global behavior change.

## Context & tokens

### How do I see how full the context window is? / enable the `/compact` nudge?
The installer ships an **opt-in status line** (`~/.claude/scripts/statusline.sh` or `.ps1`) that shows
`model · dir (branch) · ctx NN% · Nk` and flags `⚠ /compact` once the context gets heavy. It's off until you
add a `statusLine` key to `~/.claude/settings.json` — the exact per-OS block is in
[INSTALL.md §2](../INSTALL.md). Defaults are **model-aware window %**: Opus nudges at 40%, other models at
60%. (% is window-relative — 40% is ~80k tokens on a 200k model but ~400k on a 1M-context one.) To cap by
absolute size instead, set `KIT_COMPACT_TOKENS` (off by default); override the percent with `KIT_COMPACT_AT`.
The bash version needs `jq`; it spends no tokens.

### My sessions keep getting slow / "running out of context" — what do I do?
Long architect sessions get re-processed every turn, which is slow and pricey. Two habits (both in
`CLAUDE.md` → *Context hygiene*): run **`/compact`** at a natural breakpoint (after a batch of work, before
an unrelated task) to summarize and free space, and **`/clear`** when the next task shares nothing with the
last (a full reset beats carrying a summary). Routing bounded work to an implementer via `/dispatch` also
keeps that work *out* of your main session's context.

## Skills

### What are `scope-guard`, `reread-before-edit`, and `verify-and-report`?
Three small disciplines the **implementer sub-agents** reach for mid-task (you rarely invoke them by hand):
stay inside the assigned files and escalate cleanly, re-read before each edit so it lands on the right bytes,
and finish with verbatim PASS/FAIL evidence. They're on-demand, so they don't bloat the cheap tier.

### A skill didn't trigger when I expected
Type it explicitly: `/align`, `/diagnose`, etc. Auto-selection depends on your wording matching the skill's
description. The [cheat-sheet](SKILL-CHEATSHEET.md) lists what each one is for.

### `align` mentions `caveman` / `grill-me` but they don't work
Those are **vendored** skills. Install them (`--all` or `--with-vendor`). Without them `align` still runs —
those steps just no-op.

### Two skills seem to do the same thing (e.g. `tdd` and `test-driven-development`)
Intentional. The bundled one is a merged superset of the community versions. Prefer the bundled skill.

## Still stuck?
Open an issue on the repo, or read the source — every skill is a plain-English `SKILL.md` you can inspect.
