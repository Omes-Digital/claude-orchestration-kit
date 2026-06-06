#!/usr/bin/env bash
# PreToolUse(Bash) guardrail — deterministically BLOCK destructive git + catastrophic rm.
#
# Why: CLAUDE.md's strict-mode rules say "no destructive git (reset --hard, push --force,
# clean -fd)". A model instruction is advisory; this hook makes it a hard guarantee that
# doesn't depend on the model remembering. Pairs especially well with the acceptEdits
# efficiency profile (faster, but with a real safety net).
#
# Contract (see Claude Code hooks docs): receives the tool-call event as JSON on stdin;
# exit 2 = BLOCK and send stderr back to Claude as feedback; exit 0 = no objection
# (the normal permission flow still applies). Requires `jq`.
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

block() { echo "BLOCKED by no-destructive-git hook: $1" >&2; exit 2; }

# force-push (any form): --force, --force-with-lease, or -f
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push' \
   && printf '%s' "$cmd" | grep -Eq '(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$))'; then
  block "force-push is denied (kit rule: never force-push)"
fi

printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+reset[[:space:]]+--hard' \
  && block "git reset --hard is denied (destructive — stash or branch instead)"

printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+clean[[:space:]]+-[a-z]*[df]' \
  && block "git clean -fd is denied (destructive — review untracked files first)"

# catastrophic rm at a root-ish path
printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+-[a-z]*[rf][a-z]*[[:space:]]+(/|~|\$HOME)([[:space:]]|/|$)' \
  && block "catastrophic rm denied (refusing rm -rf on /, ~, or \$HOME)"

exit 0
