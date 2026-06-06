# Glossary

Plain-language definitions of the terms this kit uses. New to all of this? Read top to bottom once; after
that, use it as a lookup. See also [START-HERE.md](../START-HERE.md) and the
[skill cheat-sheet](SKILL-CHEATSHEET.md).

## The big picture

**Claude Code** — Anthropic's AI coding assistant that runs in your terminal (also in IDEs and the web).
It reads/writes files, runs commands, and can be personalized via the `~/.claude` folder.

**`~/.claude`** — your personal Claude Code config folder. On Windows it's `%USERPROFILE%\.claude`
(e.g. `C:\Users\You\.claude`). Anything here applies to **every** project. Projects can also have their own
`.claude/` folder for project-specific settings.

**Skill** — a reusable mini-workflow saved as a `SKILL.md` file. You trigger one by typing `/its-name`, or
Claude picks it automatically when your request matches its description. Think "a saved recipe for a
recurring task." This kit ships 5 of its own + 23 from the community.

**Playbook (`CLAUDE.md`)** — a file of standing instructions Claude reads at the start of every session.
This kit's `CLAUDE.md` teaches Claude the orchestration habits below. Putting it in `~/.claude/` makes it
global; putting it in a project makes it project-only.

## The orchestration idea

**Tier / tiering** — the practice of matching task difficulty to model power. Hard thinking goes to a
powerful (expensive) model; simple mechanical edits go to a cheaper, faster one. Saves money and time.
Tiering is an *optimization*, not a requirement — see the [FAQ](FAQ.md).

**Frontier model** — the most capable (and most expensive) model available, e.g. **Opus**. You want its
tokens spent on judgement, not boilerplate.

**Opus / Sonnet / Haiku** — Claude's model family from most to least powerful: **Opus** (deep reasoning),
**Sonnet** (strong all-rounder), **Haiku** (fast and cheap). The kit uses Opus to plan and Sonnet/Haiku to
execute — but you can run everything on one model if that's what you have.

**Architect** — the role your main Claude session plays in this kit: it designs, decides, writes the
hand-off instructions, and reviews the result. Ideally an Opus session. It does *not* do the mechanical
typing if that can be delegated.

**Implementer** — a helper that does the bounded, well-specified work the architect hands it. Two tiers
ship here: `implementer-haiku` (single-file mechanical edits) and `implementer-sonnet` (multi-file or
trickier changes).

**Sub-agent** — a separate Claude instance the main session spawns to do a focused job (an implementer is
one kind). It has its own fresh context and reports back. Important rule: **a sub-agent cannot spawn another
sub-agent.**

**Dispatch** — handing a task from the architect to an implementer. The `dispatch` skill writes the formal
hand-off (see *strict-mode contract*) and picks the tier.

**Strict-mode contract** — the precise instructions an implementer must follow: which files it may touch,
the exact change, what's off-limits, and how to verify. "Strict mode" = the implementer sticks to the
contract and stops if reality doesn't match, rather than improvising.

**Deny-list** — the "do NOT touch these" part of a contract. Listing what's off-limits is how the kit keeps
a delegated task from sprawling.

**Fan-out / parallel agents** — running several sub-agents at once on independent pieces of work, then
merging the results. Faster than doing them one after another.

**Plan → Execute → Review** — the kit's core loop: the architect plans, an implementer executes, and review
returns to a *more capable* tier (never let a model grade its own homework).

## Memory

**Agent memory** — short notes that persist between sessions so agents stop relearning the same lessons.
Two kinds:
- **Global memory** — cross-project craft, in `~/.claude/agent-memory/<role>/MEMORY.md`. Shipped pre-seeded.
- **Repo-local memory** — facts about one project, in that repo's `.agent-memory/` folder. Optional.

**CoALA** — the academic framing the memory design borrows from: a one-off observation (*episodic*) gets
promoted into a durable note (*semantic*), and a recurring procedure eventually becomes a skill
(*procedural*). You don't need to know this to use the kit; it just explains the "why."

## Harness / settings

**Workflow** — a Claude Code feature for deterministic multi-agent orchestration (loops, fan-out). The
`dispatch` skill can use it. Enable with `"enableWorkflows": true` in settings.

**Permission mode** — how cautious Claude is about taking actions. `default` asks before edits/commands
(safest for beginners); `auto` acts more freely. Set via `defaultMode` in
`~/.claude/settings.json`. See [`settings.example.json`](../settings.example.json).

**`settings.json`** — your Claude Code preferences file in `~/.claude/`. Controls permissions, workflows,
theme, etc. This kit ships a beginner-safe example.
