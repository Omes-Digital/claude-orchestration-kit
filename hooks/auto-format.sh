#!/usr/bin/env bash
# PostToolUse(Edit|Write) — best-effort format the file Claude just edited, so it doesn't
# spend a round-trip re-reading to check formatting. Always exits 0 (never blocks an edit);
# silently skips if no formatter is installed. OPTIONAL — it mutates files after each edit,
# which some prefer to keep manual. Requires `jq`.
set -uo pipefail

fp="$(jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
[ -f "$fp" ] || exit 0

case "$fp" in
  *.js|*.ts|*.jsx|*.tsx|*.json|*.css|*.md|*.html)
    command -v prettier >/dev/null 2>&1 && prettier --write "$fp" >/dev/null 2>&1 ;;
  *.py)
    command -v black >/dev/null 2>&1 && black -q "$fp" >/dev/null 2>&1 ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$fp" >/dev/null 2>&1 ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$fp" >/dev/null 2>&1 ;;
esac
exit 0
