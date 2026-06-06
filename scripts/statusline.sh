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
# The /compact nudge fires on EITHER trigger (whichever hits first):
#   KIT_COMPACT_TOKENS=80000  absolute context tokens (default; the real "staying lean" signal —
#                             ~80k is where context rot starts to bite, regardless of window size)
#   KIT_COMPACT_AT=40         percent of the context window (backstop; note 40% of a 1M window is
#                             ~400k tokens, so on big-window models the token trigger is what matters)
#
set -u

input="$(cat)"
THRESHOLD_PCT="${KIT_COMPACT_AT:-40}"
THRESHOLD_TOKENS="${KIT_COMPACT_TOKENS:-80000}"

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
[ -n "$toks" ]    && [ "${toks:-0}"    -ge "$THRESHOLD_TOKENS" ] 2>/dev/null && warn=1
[ -n "$pct_int" ] && [ "${pct_int:-0}" -ge "$THRESHOLD_PCT" ]    2>/dev/null && warn=1

if [ -n "$ctx" ]; then
  if [ "$warn" -eq 1 ]; then
    line="$line · $(printf '\033[33m%s ⚠ /compact\033[0m' "$ctx")"
  else
    line="$line · $ctx"
  fi
fi

printf '%s' "$line"
