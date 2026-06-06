# Install

This kit lives in your **user-level** Claude Code config at `~/.claude/`, so it applies in every project.

## 1. Back up your existing config (if any)

```bash
cp -r ~/.claude ~/.claude.backup-$(date +%Y%m%d)
```

## 2. Copy the pieces in

From the root of this repo:

```bash
# the orchestration framework
#  - if you have NO existing ~/.claude/CLAUDE.md, just copy it:
cp CLAUDE.md ~/.claude/CLAUDE.md
#  - if you DO, open both and paste the "## Agent Orchestration" section
#    into your existing file instead of overwriting it.

# the implementer sub-agents
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/

# the four bundled skills
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/

# pre-seeded per-role agent memory
mkdir -p ~/.claude/agent-memory
cp -r agent-memory/* ~/.claude/agent-memory/
```

## 3. Enable Workflows (optional but recommended)

The `dispatch` skill and parallel fan-out lean on the Workflow tool. In `~/.claude/settings.json`:

```json
{
  "enableWorkflows": true
}
```

A minimal, shareable `settings.json` baseline (merge into yours — don't blindly overwrite, and never commit secrets / personal paths):

```json
{
  "permissions": {
    "allow": ["WebSearch", "WebFetch"],
    "defaultMode": "auto"
  },
  "enableWorkflows": true
}
```

## 4. Verify

Start Claude Code in any project and check:

```
/agents     →  implementer-sonnet and implementer-haiku should be listed
/skills     →  dispatch, tdd, diagnose, review-diff should be listed
```

Then try the loop: ask Opus to design something small, then say **"dispatch this"** — it should write a strict-mode contract and hand the bounded work to an implementer tier.

## How it's meant to be used

1. **Design on Opus.** Keep the architect (this session) for design, contracts, cross-file judgement, and triage.
2. **Dispatch bounded work down.** `dispatch` writes the contract (file list · exact change · deny-list · verification command) and picks the tier — `implementer-haiku` for single-file mechanical edits, `implementer-sonnet` for multi-file / cross-file / schema-risk work.
3. **Review comes back up.** Never let a tier review its own work — `code-review` / `review-diff` run in the architect session before the human's push moment.
4. **Memory accrues.** Agents propose durable learnings; the architect promotes keepers into `agent-memory/<role>/MEMORY.md`. Keep each file short.

## Notes

- **No secrets or personal data** are included in this kit. The agent-memory seeds are generic craft.
- The bundled skills are *additive* — they don't replace Claude Code's built-in `/code-review`, `/security-review`, etc.; they complement them.
- If you use community skill plugins (Matt Pocock, pr-review-toolkit, etc.), the bundled `tdd` / `diagnose` are merged supersets — prefer them and disable the redundant plugin duplicates if the descriptions add noise.
