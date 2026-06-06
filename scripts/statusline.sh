#!/usr/bin/env bash
#
# statusline.sh — opt-in Claude Code status line for the Agent Orchestration Kit.
#
# Shows:  <model> · <dir> (<git-branch>) · ctx NN%   — and nudges /compact past a threshold,
# so the architect keeps its own context lean (frontier context re-processes every turn).
#
# Enable it (it is NOT turned on automatically): add to ~/.claude/settings.json —
#   "statusLine": { "type": "command", "command": "~/.claude/scripts/statusline.sh", "padding": 1 }
# then restart Claude Code. See INSTALL.md §2 and docs/FAQ.md.
#
# Needs `jq` (for parsing the status JSON). Without it, prints a hint instead of failing.
#
# The /compact nudge fires by WINDOW PERCENT, with MODEL-AWARE defaults — the Opus architect nudges
# earlier than the cheaper implementer tiers:
#   Opus           40% of window
#   other models  60% of window
# Note % is window-relative: on a 1M-context model, 40% ≈ 400k tokens (lots of headroom). If you'd rather
# cap by absolute size, set KIT_COMPACT_TOKENS (off by default) — it then ALSO nudges at that token count.
# Override the percent for all models with KIT_COMPACT_AT.
#
set -u

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  printf 'kit statusline: install jq to show the context meter'
  exit 0
fi

model=$(printf '%s' "$input"  | jq -r '.model.display_name // .model.id // "?"')
dir=$(printf '%s' "$input"    | jq -r '.workspace.current_dir // .cwd // ""')
pct=$(printf '%s' "$input"    | jq -r '.context_window.used_percentage // empty')
toks=$(printf '%s' "$input"   | jq -r '.context_window.total_input_tokens // empty')
dir_base=${dir##*/}
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

# model-aware nudge — the Opus architect nudges earlier (40% of window) than the cheaper tiers (60%).
# Percent governs by default; KIT_COMPACT_TOKENS adds an optional absolute-token nudge on top.
case "$model" in
  *[Oo]pus*) def_pct=40 ;;
  *)         def_pct=60 ;;
esac
PCT_AT="${KIT_COMPACT_AT:-$def_pct}"
TOK_AT="${KIT_COMPACT_TOKENS:-}"   # absolute-token nudge is opt-in; empty = percent governs alone

line="$model"
[ -n "$dir_base" ] && line="$line · $dir_base"
[ -n "$branch" ]   && line="$line ($branch)"

# build the context segment ("ctx 8% · 84k") from whichever fields are present
pct_int=""
ctx=""
[ -n "$pct" ]  && { pct_int=${pct%.*}; ctx="ctx ${pct_int}%"; }   # 42.7 -> 42
if [ -n "$toks" ]; then
  k=$((toks/1000))
  [ -n "$ctx" ] && ctx="$ctx · ${k}k" || ctx="ctx ${k}k"
fi

# nudge on EITHER trigger: absolute tokens (primary) or window % (backstop)
warn=0
[ -n "$TOK_AT" ] && [ -n "$toks" ] && [ "${toks:-0}" -ge "$TOK_AT" ] 2>/dev/null && warn=1
[ -n "$pct_int" ]                  && [ "${pct_int:-0}" -ge "$PCT_AT" ] 2>/dev/null && warn=1

if [ -n "$ctx" ]; then
  if [ "$warn" -eq 1 ]; then
    line="$line · $(printf '\033[33m%s ⚠ /compact\033[0m' "$ctx")"
  else
    line="$line · $ctx"
  fi
fi

printf '%s' "$line"
