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

### How do I undo the install?
The installer backs up anything it overwrote into `~/.claude/.kit-backup-<timestamp>/`. To remove the kit:
delete the skill folders you added under `~/.claude/skills/`, the `~/.claude/agents/implementer-*.md` files,
`~/.claude/agent-memory/`, and `~/.claude/CLAUDE.md` (or `CLAUDE.orchestration.md`). Restore anything you
want back from the backup folder.

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

## Skills

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
