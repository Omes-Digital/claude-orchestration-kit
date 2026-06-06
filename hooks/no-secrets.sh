#!/usr/bin/env bash
# PreToolUse(Bash) guardrail — BLOCK a `git commit` that would write secrets/credentials to history.
#
# Why: the repo-hygiene rule "scrub secrets / personal identifiers before commit" is advisory, and a
# real .env once leaked into a repo here. This hook makes the commit-time secret check a hard,
# deterministic gate that does not depend on the model remembering. Sibling of no-destructive-git.sh;
# pairs especially well with acceptEdits / skipAutoPermissionPrompt (faster, with a real safety net).
#
# Scope — deliberately high-precision, to avoid crying wolf:
#   - engages ONLY on `git commit` (the moment secrets enter history; `git push` is out of scope, since
#     by then they are already committed locally — catch it here instead).
#   - scans STAGED additions, plus unstaged tracked changes when the commit uses -a/--all.
#   - blocks on credential FILES (*.pem/*.key/id_rsa/.env ...) and high-confidence secret CONTENT
#     (private-key blocks; AWS/GitHub/Slack/Google/sk- tokens; non-placeholder secret= assignments).
#   - *.example / *.sample / *.template / *.dist files are trusted dummy data and skipped ENTIRELY.
#
# Contract (Claude Code hooks): event JSON on stdin; exit 2 = BLOCK + stderr is fed back to Claude;
# exit 0 = no objection. Requires jq + git; if either is missing, or the cwd is not a repo, it FAILS
# OPEN (exit 0) rather than blocking legitimate work — this is a safety net, not a hard boundary.
# Genuine false positive? Bypass for the current shell:  export KIT_ALLOW_SECRETS=1
set -uo pipefail

event="$(cat)"
cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# engage only when the command runs a git commit (loose match — over-engaging just means a cheap,
# silent scan that finds nothing; under-engaging would miss a real commit)
printf '%s' "$cmd" | grep -Eq 'git[[:space:]].*commit' || exit 0

# explicit override
[ -n "${KIT_ALLOW_SECRETS:-}" ] && exit 0

# fail open if we cannot actually scan
command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0
cwd="$(printf '%s' "$event" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$cwd" ] && cwd="$PWD"
git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# which files to inspect: staged always; + unstaged tracked when committing with -a / --all
staged="$(git -C "$cwd" diff --cached --name-only 2>/dev/null || true)"
all_flag=0
printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(--all([[:space:]]|$)|-[A-Za-z]*a[A-Za-z]*([[:space:]]|=|$))' && all_flag=1
unstaged=""
[ "$all_flag" = 1 ] && unstaged="$(git -C "$cwd" diff --name-only 2>/dev/null || true)"

# nothing actually staged/changed → nothing to guard
printf '%s\n%s\n' "$staged" "$unstaged" | grep -q '[^[:space:]]' || exit 0

findings=""
flag() { findings="${findings}  - $1"$'\n'; }

# scan the ADDED lines of one file's diff for high-confidence secrets
check_added() {  # $1 = file label, $2 = added-lines text
  f="$1"; a="$2"
  printf '%s' "$a" | grep -Eq -e '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'                && flag "private key in $f"
  printf '%s' "$a" | grep -Eq 'AKIA[0-9A-Z]{16}'                                          && flag "AWS access key id in $f"
  printf '%s' "$a" | grep -Eq 'aws_secret_access_key[[:space:]]*[=:][[:space:]]*[A-Za-z0-9/+]{40}' && flag "AWS secret key in $f"
  printf '%s' "$a" | grep -Eq 'gh[pousr]_[A-Za-z0-9]{36,}'                                && flag "GitHub token in $f"
  printf '%s' "$a" | grep -Eq 'xox[baprs]-[A-Za-z0-9-]{10,}'                              && flag "Slack token in $f"
  printf '%s' "$a" | grep -Eq 'sk-(ant-)?[A-Za-z0-9_-]{20,}'                              && flag "API key (sk-...) in $f"
  printf '%s' "$a" | grep -Eq 'AIza[0-9A-Za-z_-]{35}'                                     && flag "Google API key in $f"
  # generic secret= assignment, but only if a hit is NOT an obvious placeholder
  re='(secret|password|passwd|api[_-]?key|access[_-]?token)[[:space:]]*[=:][[:space:]]*["'\''][^"'\'' ]{8,}["'\'']'
  if printf '%s' "$a" | grep -Eiq "$re" \
     && printf '%s' "$a" | grep -Ei "$re" \
          | grep -Evqi '(change[_-]?me|placeholder|example|your[_-]|xxx+|dummy|sample|redacted|<[^>]+>|\*\*\*|\.\.\.)'; then
    flag "hardcoded secret assignment in $f"
  fi
}

# inspect one file: skip trusted templates entirely, else check its name + added content
scan_file() {  # $1 = path, $2 = cached|worktree
  case "$1" in *.example|*.sample|*.template|*.dist) return 0 ;; esac
  case "$1" in
    *.pem|*.key|*.p12|*.pfx|*id_rsa|*id_dsa|*id_ecdsa|*id_ed25519) flag "credential file staged: $1" ;;
    .env|.env.*|*/.env|*/.env.*)                                   flag "env file staged: $1" ;;
  esac
  if [ "$2" = cached ]; then
    added="$(git -C "$cwd" diff --cached --unified=0 -- "$1" 2>/dev/null | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
  else
    added="$(git -C "$cwd" diff --unified=0 -- "$1" 2>/dev/null | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
  fi
  [ -n "$added" ] && check_added "$1" "$added"
}

while IFS= read -r file; do [ -n "$file" ] && scan_file "$file" cached; done < <(printf '%s\n' "$staged"   | LC_ALL=C sort -u)
if [ "$all_flag" = 1 ]; then
  while IFS= read -r file; do [ -n "$file" ] && scan_file "$file" worktree; done < <(printf '%s\n' "$unstaged" | LC_ALL=C sort -u)
fi

# dedupe (a file can be both staged and unstaged-modified) and decide
findings="$(printf '%s' "$findings" | awk 'NF && !seen[$0]++')"
[ -z "$findings" ] && exit 0

{
  echo "BLOCKED by no-secrets hook — this commit would add likely secrets/credentials:"
  printf '%s\n' "$findings"
  echo "Fix: unstage/remove them (git restore --staged <file>), .gitignore the file, or use a secret store."
  echo "If it is genuinely safe, bypass for this shell:  export KIT_ALLOW_SECRETS=1"
} >&2
exit 2
