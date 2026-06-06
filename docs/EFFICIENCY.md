# Efficiency — token cost & wall-clock, measured

Most "make Claude cheaper/faster" advice fails because it conflates three different goals that have
three different levers. Separate them first:

| Goal | What actually drives it | What does **not** help much |
|---|---|---|
| **Real $** | The *model* you run, and *new/uncached* tokens (fresh reads, generated output) | Trimming cached context — it's already billed at 0.1× |
| **Wall-clock** | *Round-trips* (permission stops), output *speed*, parallelism | Context size (it's cached; reprocessing is cheap and fast) |
| **Quality** | Keeping context *lean* — models degrade as input grows ([context rot](https://www.trychroma.com/research/context-rot)) | Adding more "just-in-case" instructions |

The kit used to blur these (e.g. "trim CLAUDE.md to save money" — mostly false). This page is the honest version.

## 1. The kit's measured footprint

Always-in-context, before any work (measured on this repo):

| Always-on | Tokens |
|---|---|
| `CLAUDE.md` | ~4,300 |
| 8 own skill *descriptions* | ~1,300 |
| 15 vendored skill *descriptions* (only if you `--all`-installed them) | ~700 |
| **Total** | **~6,300** |

**The caching nuance.** That prefix is cached, so after turn 1 it's billed at **0.1×** (cache-read). Cache
math: read = 0.1× · write = 1.25× (5-min TTL) / 2× (1-hr) · uncached = 1× ([caching docs](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)).
So **trimming the always-on context saves very little $** — but it *does* free context-window headroom and
reduce rot, which is a **quality** win. Trim for correctness, not for the invoice.

## 2. Levers, ranked

| # | Lever (as a kit change) | Real $ | Wall-clock | Quality | Effort |
|---|---|---|---|---|---|
| L1 | **Session-model routing** — Sonnet for most work, Opus for hard design | **−40%** | faster | = | S |
| L2 | **`acceptEdits` + `permissions.allow`** (opt-in profile) | ~0 | **−50–80% stops** | = | S |
| L3 | **Guardrail / format hooks** + verbose-output *habits* | small | cuts loops | + | S |
| L4 | **Forked sub-agents** when you do dispatch | removes re-read tax | = | = | S |
| L5 | **`Explore` for code research** (it skips CLAUDE.md+git) | −~30% on research | faster | + | S |
| L6 | **Keep CLAUDE.md lean** (< 200 lines / 25 KB) | small | = | + | — |
| L7 | **Curate vendored skills** (don't `--all` by reflex) | small | = | + | S |
| L8 | **`/effort` ladder** — match reasoning depth to the task | ± | ± | ± | — |
| L9 | **`/compact` & `/clear` discipline** + earlier auto-compact | small | + | + | — |

## 3. Session-model routing (L1) — the biggest real-$ lever

Frontier-first **≠ always-Opus.** Current rates ([pricing](https://www.finout.io/blog/anthropic-api-pricing)):
**Opus 4.8 $5/$25 · Sonnet 4.6 $3/$15 · Haiku 4.5 ~$1/$5** per Mtok (in/out). Opus is only **1.67× Sonnet**,
and Sonnet is *faster*. Anthropic's own guidance: Sonnet for most coding, Opus for complex architecture,
Haiku for mechanical work.

- **Default the session to Sonnet** (`"model": "sonnet"`, in [`settings.efficiency.json`](../settings.efficiency.json)); `/model opus` to escalate for a hard design stretch, `/model sonnet` back. ~**40% cheaper** than an all-Opus baseline, and faster.
- Don't *thrash* models mid-session — switching flushes the prompt cache and forces one full cache-write.
- **Honest caveat:** the kit's [A/B](../ab-test/FINDINGS.md) compared Opus-solo vs Opus-architect+Sonnet-implementer; it never tested **Sonnet-solo**, which may be the real cost+speed winner for everyday work. Measure it on your tasks.

## 4. Fewer round-trips (L2) — the biggest wall-clock lever

Every permission prompt is a human stop — seconds to minutes of wall-clock. [`settings.efficiency.json`](../settings.efficiency.json)
ships an **opt-in** profile:

| Mode | Effect | Use when |
|---|---|---|
| `default` (kit default) | Asks before each new tool | Unfamiliar code; cautious |
| `acceptEdits` | Auto-approves file edits + safe FS ops; still asks for Bash | **Trusted project — the efficiency sweet spot** |
| `plan` | Read-only until you approve a plan | High-risk changes |
| `bypassPermissions` | Zero prompts | **Only** in a container/VM |

`acceptEdits` + a narrow `permissions.allow` (e.g. `Bash(npm test*)`, `Bash(git diff*)`) cuts ~50–80% of
stops. **Pair it with the `no-destructive-git` + `no-secrets` hooks** (the profile wires both) so "faster" still has a
safety net. Widen the allow-list per project; never allow `git push`.

## 5. Reasoning effort (L8) — the `/effort` ladder

Effort is the **second dial** next to model choice: *which model* sets capability and $/token, `/effort` sets how much reasoning the model spends per step. They're orthogonal — pick both. Five levels:

| Level | Use for | Cost |
|---|---|---|
| `low` | Mechanical / latency-sensitive — renames, config, boilerplate, quick back-and-forth | least |
| `medium` | Cost-sensitive work that can trade a little intelligence | reduced |
| `high` *(default on Opus 4.8 / Sonnet 4.6)* | Most coding and normal multi-file changes | moderate |
| `xhigh` | Genuinely hard design, cross-file invariant reasoning, gnarly diagnosis — the same triggers that justify `/model opus` | higher |
| `max` | Last resort when `xhigh` stalls; **unbounded and prone to overthinking** — verify it actually helped | highest |

**It's adaptive, not fixed.** On Opus 4.8/4.7 a level is an *upper bound* the model draws on by complexity — `high` already throttles itself down on easy steps, so you don't pay `xhigh` prices on trivial turns. (Older models like Sonnet 4.6 instead pair effort with a fixed thinking budget via `MAX_THINKING_TOKENS`.)

**Pair it with model choice, don't substitute.** For a **reasoning-bound** (not knowledge-bound) task, a cheaper model at higher effort can beat a pricier model at low effort — so try **`/effort xhigh` on Sonnet before jumping to Opus**. Lowering effort is also the free, built-in speed/cost lever for simple work (there's no "fast mode" worth recommending — the paid Fast-Mode tier is niche and out of scope here).

**Caveats.** **Haiku has no effort control** — the `implementer-haiku` tier can't be tuned this way, which is another reason it's for mechanical slices only. Switching model **resets** effort to the new model's default, so re-set after `/model`. If you set a level the active model doesn't support, Claude Code silently falls back to the highest supported level at or below it.

**Mechanics.** `/effort <level>` switches mid-session (no arg → interactive slider). `ultrathink` anywhere in a prompt buys one deeper turn without changing the session level. Persist a default with `effortLevel` in `settings.json` (`low`/`medium`/`high`/`xhigh` only — `max` is session-only) or `CLAUDE_CODE_EFFORT_LEVEL` env (env wins over both, plus `auto` to reset to model default). `ultracode` = `xhigh` + Workflow orchestration, the explicit opt-in for multi-agent runs (session-only).

## 6. Hooks + output habits (L3)

The kit ships three hooks in [`hooks/`](../hooks/): `no-destructive-git.sh` (PreToolUse — **enforces** the
"no destructive git" rule deterministically), `no-secrets.sh` (PreToolUse — **blocks** a `git commit` that
would add keys / tokens / `.env`), and `auto-format.sh` (PostToolUse — saves a format-check round-trip;
optional). See [`hooks/README.md`](../hooks/README.md).

**Honest limit:** a `PreToolUse` hook can't filter a command's *output* (it runs before the tool). Keep
noisy output out of context as a **habit**: `pytest -q` not `-v`, pipe big logs through `tail`/`grep`, ask
for failures only.

## 7. Context hygiene (L6 / L7 / L9)

- **Keep CLAUDE.md lean.** Claude Code reads only the first ~200 lines / 25 KB of a CLAUDE.md. This kit's is
  ~118 lines — under the cutoff; keep it there. Push detail to skills/docs (load on demand) rather than the
  always-on file.
- **Curate vendored skills.** `--all` installs 15 skills whose *descriptions* (~700 tokens) load **every
  turn** even if unused. Install only the handful you actually reach for (e.g. `grill-me`, `caveman`,
  `handoff`, `brainstorming`, `writing-plans`) — `--with-vendor` then prune, or copy individually.
- **`/compact` at clean breakpoints, `/clear` between unrelated tasks.** Set `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`
  to compact before the ~95% auto-trigger. Enable the kit's [status-line meter](../scripts/) to see context fill — it also surfaces live session `$cost` and plan rate-limit %.

## 8. Sub-agent economics

A spawned sub-agent gets a **fresh** context and **does not share the parent's prompt cache** — it re-pays
(cache-write 1.25×) to read what the parent already loaded. That's the **isolation tax** behind the kit's
[frontier-first finding](../ab-test/FINDINGS.md). Two ways it still pays:

- **Forked sub-agents** (`CLAUDE_CODE_FORK_SUBAGENT`) inherit the parent session and *share* its cache on the
  first call — removing the re-read tax (at the cost of less isolation). The kit's A/B used fresh-context
  dispatch, so its penalty is specific to that style.
- Built-in **`Explore`/`Plan`** agents skip CLAUDE.md + git status, so they're lean for codebase research
  that returns a condensed summary — Anthropic's endorsed pattern (explore → compress → return ~1–2k tokens).

**Rule of thumb:** dispatch when the sub-agent will *return far less than it reads* (research/audit), not
when it re-reads code to emit a diff (the losing case).

---

*Sources: [Claude Code costs guide](https://code.claude.com/docs/en/costs.md) · [model-config](https://code.claude.com/docs/en/model-config.md) · [sub-agents](https://code.claude.com/docs/en/sub-agents.md) · [hooks](https://code.claude.com/docs/en/hooks-guide.md) · [prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) · [pricing](https://www.finout.io/blog/anthropic-api-pricing) · [context rot (Chroma)](https://www.trychroma.com/research/context-rot) · [Anthropic: effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents). Rates/flags as of 2026-06; verify against current docs.*
