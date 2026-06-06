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
# Threshold is overridable:  KIT_COMPACT_AT=80  (percent of the context window; default 75).
#
set -u

input="$(cat)"
THRESHOLD="${KIT_COMPACT_AT:-75}"

if ! command -v jq >/dev/null 2>&1; then
  printf 'kit statusline: install jq to show the context meter'
  exit 0
fi

model=$(printf '%s' "$input"  | jq -r '.model.display_name // .model.id // "?"')
dir=$(printf '%s' "$input"    | jq -r '.workspace.current_dir // .cwd // ""')
pct=$(printf '%s' "$input"    | jq -r '.context_window.used_percentage // empty')
dir_base=${dir##*/}
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

line="$model"
[ -n "$dir_base" ] && line="$line · $dir_base"
[ -n "$branch" ]   && line="$line ($branch)"

if [ -n "$pct" ]; then
  pct_int=${pct%.*}                       # 42.7 -> 42
  if [ "${pct_int:-0}" -ge "$THRESHOLD" ] 2>/dev/null; then
    # yellow warning when the context window is getting full
    line="$line · $(printf '\033[33mctx %s%% ⚠ /compact\033[0m' "$pct_int")"
  else
    line="$line · ctx ${pct_int}%"
  fi
fi

printf '%s' "$line"
