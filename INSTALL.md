# Install

This kit lives in your **user-level** Claude Code config folder, so it applies in every project:
- **macOS / Linux:** `~/.claude/`
- **Windows:** `%USERPROFILE%\.claude\` (e.g. `C:\Users\You\.claude`) — in PowerShell, `~\.claude`

> New to all this? Read [`START-HERE.md`](START-HERE.md) first — it has a 5-minute path.

## 0. Prerequisites

- **[Claude Code](https://claude.com/claude-code) installed** (the CLI). Follow the official install docs
  for your platform; this kit only adds config files, it doesn't install Claude Code itself.
- An **Anthropic account / plan.** The architect→implementer *tiering* assumes you can use more than one
  model (Opus to design, Sonnet/Haiku to execute) — but that's an **optimization, not a requirement.**
  Every skill and the playbook work on a single model. No Opus? Use **Sonnet** and ignore the tier advice.
- **You'll restart Claude Code** after installing, so it picks up the new skills and agents.

## 1. Install

### Option A — the installer (recommended)

From the repo root:

```bash
# macOS / Linux
bash install.sh                # core: CLAUDE.md + agents + 8 own skills + memory seeds + scripts
bash install.sh --all          # also install the 23 vendored community skills
```
```powershell
# Windows PowerShell
pwsh -File install.ps1          # core
pwsh -File install.ps1 -All     # also the vendored community skills
```

The installer:
- **backs up** anything it overwrites into `~/.claude/.kit-backup-<timestamp>/`,
- **never clobbers your own `CLAUDE.md`** — if you already have one, it writes the kit's playbook to
  `CLAUDE.orchestration.md` instead and tells you to merge,
- is **idempotent** (safe to re-run),
- supports `--check` / `-Check` to verify without changing anything (see [§3](#3-verify)).

> Want only the community skills, not the core? Use `--with-vendor` / `-WithVendor`.

### Option B — manual copy

If you'd rather copy by hand, pick your platform.

<details>
<summary><b>macOS / Linux</b></summary>

```bash
# (optional) back up first
cp -r ~/.claude "$HOME/.claude.backup-$(date +%Y%m%d)" 2>/dev/null || true

# the playbook — if you have NO existing ~/.claude/CLAUDE.md:
cp CLAUDE.md ~/.claude/CLAUDE.md
#  - if you DO have one, copy to CLAUDE.orchestration.md and merge the
#    "## Agent Orchestration" section into your existing file instead.

mkdir -p ~/.claude/agents       && cp agents/*.md ~/.claude/agents/
mkdir -p ~/.claude/skills       && cp -r skills/* ~/.claude/skills/
mkdir -p ~/.claude/agent-memory && cp -r agent-memory/* ~/.claude/agent-memory/

# optional: the vendored community skills (the */ glob skips the LICENSE files)
cp -r vendor/mattpocock/*/  ~/.claude/skills/ 2>/dev/null
cp -r vendor/superpowers/*/ ~/.claude/skills/ 2>/dev/null
```
</details>

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
$claude = Join-Path $HOME '.claude'

# the playbook — if you have NO existing CLAUDE.md:
Copy-Item -Force CLAUDE.md (Join-Path $claude 'CLAUDE.md')
#  - if you DO have one, copy it to CLAUDE.orchestration.md and merge the
#    "## Agent Orchestration" section into your existing file instead.

New-Item -ItemType Directory -Force (Join-Path $claude 'agents')       | Out-Null
Copy-Item -Force agents\*.md (Join-Path $claude 'agents')
New-Item -ItemType Directory -Force (Join-Path $claude 'skills')       | Out-Null
Copy-Item -Recurse -Force skills\* (Join-Path $claude 'skills')
New-Item -ItemType Directory -Force (Join-Path $claude 'agent-memory') | Out-Null
Copy-Item -Recurse -Force agent-memory\* (Join-Path $claude 'agent-memory')

# optional: the vendored community skills
Get-ChildItem -Directory vendor\mattpocock, vendor\superpowers |
  Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
  ForEach-Object { Copy-Item -Recurse -Force $_.FullName (Join-Path $claude 'skills') }
```
</details>

### A note on `align`'s companions

The `align` skill hands off to `dispatch` (ships in `skills/`) and invokes `caveman` and `grill-me`
(in `vendor/mattpocock/`). For the full chain, install the vendored skills too (`--all` / `-All` covers
them). Without them, `align` still runs — those steps just no-op.

## 2. Settings

Copy [`settings.example.json`](settings.example.json) to `~/.claude/settings.json` (merge it into yours if
you already have one — **don't blindly overwrite**, and never commit secrets / personal paths):

```json
{
  "permissions": {
    "allow": ["WebSearch", "WebFetch"],
    "defaultMode": "default"
  },
  "enableWorkflows": true
}
```

What each key does:
- **`permissions.allow`** — tools Claude may use without asking each time (`WebSearch`/`WebFetch` are safe).
- **`defaultMode`** — how cautious Claude is. `"default"` asks before edits/commands (**recommended while
  you learn**); switch to `"auto"` once you trust the setup.
- **`enableWorkflows`** — turns on the Workflow tool that `dispatch` and parallel fan-out use.

The example deliberately omits personal plugin/marketplace config — add your own if you use plugins.

### Optional: the context meter (status line)

The installer drops `statusline.sh` / `statusline.ps1` into `~/.claude/scripts/` but does **not** turn them
on. They render a one-line status bar — `model · dir (branch) · ctx NN% · Nk` — and the `ctx` figure turns
yellow with a `⚠ /compact` nudge. Defaults are **model-aware** — the Opus architect is kept leaner than the
cheaper tiers: **Opus** nudges at ~80k tokens / 40%, **other models** at ~120k tokens / 60%. It fires on
whichever comes first, **absolute tokens** or **window %**, and is token-first because the % is relative to
your model's window (40% of a 200k window is 80k tokens, but 40% of a 1M-context model is ~400k — so on
big-window models the token trigger keeps you lean). Override for all models with the env vars
`KIT_COMPACT_TOKENS` and `KIT_COMPACT_AT`. This is the "real number" companion to the
`/compact`-at-breakpoints habit in `CLAUDE.md` → *Context hygiene*.

To enable it, add a `statusLine` key to `~/.claude/settings.json` and **restart Claude Code**:

```jsonc
// macOS / Linux  (needs `jq` on your PATH)
"statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh", "padding": 1 }
```
```jsonc
// Windows (PowerShell)
"statusLine": { "type": "command", "command": "pwsh -File ~/.claude/scripts/statusline.ps1", "padding": 1 }
```

It only reads the status JSON Claude Code already provides (`context_window.used_percentage`) — it spends no
tokens and changes no behavior. To disable, remove the `statusLine` key and restart.

## 3. Verify

**Doctor (files on disk):**
```bash
bash install.sh --check          # macOS / Linux
```
```powershell
pwsh -File install.ps1 -Check    # Windows
```
It prints ✓/✗ for each expected file. Add `--all` / `-All` to also check the vendored skills.

**In Claude Code (after restarting):**
```
/agents     →  implementer-sonnet and implementer-haiku listed
/skills     →  align, dispatch, tdd, diagnose, review-diff, scope-guard, reread-before-edit, verify-and-report listed
```

Then try the loop: ask Claude to design something small, then say **"dispatch this"** — it should write a
strict-mode contract and hand the bounded work to an implementer tier. See the
[worked example](docs/EXAMPLE.md).

## How it's meant to be used

1. **Align first.** For anything ambiguous, `/align` nails down the brief before any work.
2. **Design on your strongest model.** Keep the architect session for design, contracts, and triage.
3. **Dispatch bounded work down.** `dispatch` writes the contract (files · change · deny-list · verify) and
   picks the tier — `implementer-haiku` for single-file mechanical edits, `implementer-sonnet` for
   multi-file / cross-file / schema-risk work.
4. **Review comes back up.** Never let a tier review its own work — `review-diff` / `/code-review` run in
   the architect session before the human's push moment.
5. **Memory accrues.** Agents propose durable learnings; you promote keepers into
   `agent-memory/<role>/MEMORY.md`. Keep each file short.

## Uninstall

Changed your mind? The installer can remove exactly what it added — **it previews first and only deletes
with `--yes`**:

```bash
bash install.sh --uninstall          # macOS / Linux — dry run: lists what would be removed
bash install.sh --uninstall --yes    # actually remove
```
```powershell
pwsh -File install.ps1 -Uninstall        # Windows — dry run
pwsh -File install.ps1 -Uninstall -Yes   # actually remove
```

It removes only **kit-owned** files: the 8 own skills + the vendored skills it ships, `agents/implementer-*.md`,
`scripts/`, `agent-memory/`, and `CLAUDE.md`. Safety rails:
- A `CLAUDE.md` that **differs** from the kit's (i.e. you customized or merged it) is **kept**, with a notice —
  it won't silently delete your work.
- Skills or agents **you** added are never touched (it only removes names the kit ships).
- Your `.kit-backup-<timestamp>/` folders are left in place so you can still restore.

Then **restart Claude Code**. Prefer to do it by hand? Delete the same paths under `~/.claude/` yourself and
restore anything you want from the backup folder.

## Notes

- **No secrets or personal data** are included in this kit. The agent-memory seeds are generic craft.
- The bundled skills are *additive* — they complement Claude Code's built-in `/code-review`,
  `/security-review`, etc., they don't replace them.
- If you use community skill plugins (Matt Pocock, pr-review-toolkit, etc.), the bundled `tdd` / `diagnose`
  are merged supersets — prefer them and disable redundant plugin duplicates if the descriptions add noise.
