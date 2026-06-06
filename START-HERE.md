# Start here 👋

**New to Claude Code, or just want the short path in?** This page is for you. Read it first;
everything else is reference.

## What is this, in one paragraph

[Claude Code](https://claude.com/claude-code) is Anthropic's AI coding assistant that runs in your
terminal. It can be *personalized* with files in a folder called `~/.claude` (on Windows that's
`%USERPROFILE%\.claude`). This kit is a bundle of those personalization files — **skills** (reusable
mini-workflows you trigger with `/name`), **agent definitions** (helpers Claude can hand work to), a
**playbook** (`CLAUDE.md`, habits Claude follows in every project), and **memory seeds**. Together they
turn Claude Code into a more disciplined, cost-aware coding partner. The everyday value is the discipline —
good questions before building, methodology, context hygiene, memory; the multi-agent *orchestration* is an
opt-in tool for big or parallel jobs, **not a destination you have to reach**. You do **not** have to install
all of it — start small.

## Pick your level

You can stop at any level. Each one stands on its own.

### 🟢 Level 1 — Try one skill (5 minutes)

The lowest-commitment taste. Install a single skill, restart, use it. No playbook, no agents, no
behavior changes anywhere else.

```bash
# macOS / Linux — from the repo root
mkdir -p ~/.claude/skills
cp -r skills/diagnose ~/.claude/skills/
```
```powershell
# Windows PowerShell — from the repo root
New-Item -ItemType Directory -Force ~\.claude\skills | Out-Null
Copy-Item -Recurse -Force skills\diagnose ~\.claude\skills\
```

Restart Claude Code, then in any project type `/diagnose` when something is broken. That's it — you've
used a skill. Try `align` next (it asks smart clarifying questions before any work). See the
[**skill cheat-sheet**](docs/SKILL-CHEATSHEET.md) for what each one is good for.

### 🟡 Level 2 — Add the playbook + memory

Now you want Claude to *consistently* plan before coding, keep notes between sessions, and route work
sensibly. Add `CLAUDE.md` (the playbook) and the memory seeds.

```bash
# macOS / Linux
bash install.sh
```
```powershell
# Windows PowerShell
pwsh -File install.ps1
```

The installer backs up anything it touches and **won't overwrite** an existing `CLAUDE.md`. See
[`INSTALL.md`](INSTALL.md) for what it does and the manual steps if you prefer.

> ⚠️ **Heads up:** `CLAUDE.md` shapes how Claude behaves in **every** project on your machine. That's
> the point — but adopt it only when you want that. You can always delete `~/.claude/CLAUDE.md` to undo it.

### 🔵 Level 3 — Orchestration, for when a task outgrows one session

The scaling tier: the `implementer-*` agents and the **align → dispatch → implement → review** pipeline.
**Most work never needs this** — a strong model handles a normal task in one pass, and we measured tiered
dispatch costing *more* for identical results on everyday work ([findings](ab-test/FINDINGS.md)). Reach for
Level 3 only when a task is **too big for one context**, **genuinely parallelizable**, or you want
**fresh-eyes** review. Best when you have access to multiple Claude models (see the "Do I need Opus?" note
below).

```bash
# macOS / Linux — installs everything, including vendored skills
bash install.sh --all
```
```powershell
# Windows PowerShell
pwsh -File install.ps1 -All
```

Read [`CLAUDE.md`](CLAUDE.md) §Working model to understand *when* to reach for it, and walk through the
[**worked example**](docs/EXAMPLE.md) to see it in action.

## Do I need Opus? Will this cost a lot?

**No, and not necessarily.** The "tiering" (Opus designs, cheaper models do the grunt work) is an
*optimization* to save tokens — it is **not required**. Every skill works on whatever model you have. If
you don't have Opus access, just use Sonnet as your main model; the skills and playbook still help. More
in the [**FAQ**](docs/FAQ.md).

## Map of the kit

```
claude-orchestration-kit/
├── START-HERE.md ........ you are here
├── README.md ............ overview + the design rationale
├── INSTALL.md ........... full install (scripts + manual, all platforms)
├── install.sh / .ps1 .... one-command installers (mac/linux · windows)
├── CLAUDE.md ............ the playbook Claude follows (Level 2+)
├── skills/ ............. 8 skills you trigger with /name  (align, dispatch, tdd, diagnose, review-diff + 3 implementer helpers)
├── agents/ ............. 2 helper agents Claude hands work to (Level 3)
├── agent-memory/ ....... per-role notes that persist between sessions
├── scripts/ ........... opt-in status line: live context % + a /compact nudge
├── hooks/ ............. opt-in guardrails: block destructive git + auto-format (wire per hooks/README)
├── vendor/ ............. 15 more skills from the community (MIT, optional)
└── docs/ ............... GLOSSARY · SKILL-CHEATSHEET · EXAMPLE · FAQ · EFFICIENCY
```

## Where to go next

| If you want to… | Read |
|---|---|
| Understand the jargon | [docs/GLOSSARY.md](docs/GLOSSARY.md) |
| Know which skill to use when | [docs/SKILL-CHEATSHEET.md](docs/SKILL-CHEATSHEET.md) |
| See a real session end-to-end | [docs/EXAMPLE.md](docs/EXAMPLE.md) |
| Fix a setup problem | [docs/FAQ.md](docs/FAQ.md) |
| Make it cheaper / faster | [docs/EFFICIENCY.md](docs/EFFICIENCY.md) |
| Do the full install | [INSTALL.md](INSTALL.md) |
| Understand the design | [README.md](README.md) |
