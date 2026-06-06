# Hooks — deterministic guarantees, fewer round-trips

Hooks are shell commands Claude Code runs at lifecycle points (before/after a tool, etc.). Because
they run **without a model turn**, they're a cheap way to *enforce* a rule or *save a round-trip* that
otherwise relies on the model choosing to act. This kit ships two:

| Hook | Event | What it does | Why it helps |
|---|---|---|---|
| `no-destructive-git.sh` | `PreToolUse` (Bash) | **Blocks** force-push, `git reset --hard`, `git clean -fd`, and catastrophic `rm -rf /`~`$HOME` (exit 2) | Turns CLAUDE.md's *advisory* "no destructive git" rule into a **hard guarantee** — independent of the model. Essential safety net under the `acceptEdits` efficiency profile. |
| `auto-format.sh` | `PostToolUse` (Edit\|Write) | Best-effort runs your formatter (prettier/black/gofmt/rustfmt) on the edited file | Saves Claude a round-trip re-reading the file to check formatting. **Optional** — it mutates files after each edit. |

Both require [`jq`](https://jqlang.github.io/jq/) (already a kit dependency for the status line).

## Wiring (verified against the Claude Code hooks schema)

Add a `hooks` block to `~/.claude/settings.json`. The `matcher` is the tool name (a regex);
`type: "command"` runs a shell command that receives the event as JSON on stdin.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/no-destructive-git.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/auto-format.sh" }]
      }
    ]
  }
}
```

The bundled [`settings.efficiency.json`](../settings.efficiency.json) already wires the git guardrail
(the safety half of "go faster"). Add the `auto-format` block only if you want it.

> **Paths:** the examples assume the hooks live at `~/.claude/hooks/` (where the installer puts them).
> If `~` isn't expanded in your environment, use an absolute path. Make sure the scripts are executable
> (`chmod +x ~/.claude/hooks/*.sh`) — the installer does this for you.

## The contract (so you can write your own)

- **stdin:** the event as JSON. A `PreToolUse` Bash event has `.tool_input.command`; an `Edit`/`Write`
  event has `.tool_input.file_path`.
- **exit 0:** no objection (for `PreToolUse`, the normal permission flow still runs — exit 0 does *not*
  auto-approve). Cheap and silent.
- **exit 2:** **block** the action; whatever you write to stderr is handed back to Claude as feedback so
  it can adjust. This is how `no-destructive-git.sh` denies a command.
- **any other exit:** the action proceeds; the transcript shows a hook-error notice.

## What hooks are *not* for (an honest note)

A `PreToolUse` hook fires **before** the tool, so it can't filter a command's *output* (that doesn't
exist yet). To keep noisy output out of context, make it a **habit in CLAUDE.md** instead — run
`pytest -q` not `-v`, pipe big logs through `tail`/`grep`, ask for failures only. Hooks enforce *rules*
and run *deterministic side-effects*; they don't post-process tool results. See
[`docs/EFFICIENCY.md`](../docs/EFFICIENCY.md) for the full lever menu.
