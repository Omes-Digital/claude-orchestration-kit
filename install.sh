#!/usr/bin/env bash
#
# install.sh — install the Claude Code Agent Orchestration Kit into ~/.claude
#
#   bash install.sh                 core: CLAUDE.md + agents + 5 own skills + memory seeds
#   bash install.sh --with-vendor   also install the 23 vendored community skills
#   bash install.sh --all           everything (same as --with-vendor)
#   bash install.sh --check         doctor mode: report what's installed, change nothing
#   bash install.sh --help          show help
#
# Override the target for testing:  CLAUDE_HOME=/tmp/test bash install.sh
#
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${CLAUDE_HOME:-$HOME/.claude}"

WITH_VENDOR=0
CHECK=0
BACKUP=""

OWN_SKILLS="align dispatch tdd diagnose review-diff"
MEMORY_ROLES="architect explorer researcher implementer reviewer auditor memory-curator"

usage() {
  cat <<EOF
Install the Claude Code Agent Orchestration Kit into your ~/.claude folder.

Usage: bash install.sh [options]

  (no options)    core: CLAUDE.md + implementer agents + 5 own skills + memory seeds
  --with-vendor   also install the 23 vendored community skills
  --all           everything (same as --with-vendor)
  --check         doctor mode: report what's installed, change nothing
  --help          show this help

Target folder: $TARGET
  (override for testing:  CLAUDE_HOME=/tmp/test bash install.sh)
EOF
}

# ---- arg parsing ----
for arg in "$@"; do
  case "$arg" in
    --with-vendor|--all) WITH_VENDOR=1 ;;
    --check)             CHECK=1 ;;
    -h|--help)           usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage; exit 2 ;;
  esac
done

# ---- doctor mode ----
if [ "$CHECK" -eq 1 ]; then
  echo "Checking install at: $TARGET"
  MISSING=0
  ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
  bad()  { printf '  \033[31m✗\033[0m %s  (missing)\n' "$1"; MISSING=$((MISSING+1)); }
  if [ -e "$TARGET/CLAUDE.md" ] || [ -e "$TARGET/CLAUDE.orchestration.md" ]; then
    ok "CLAUDE.md (playbook)"; else bad "CLAUDE.md (playbook)"; fi
  for f in implementer-sonnet implementer-haiku; do
    if [ -e "$TARGET/agents/$f.md" ]; then ok "agents/$f.md"; else bad "agents/$f.md"; fi
  done
  for s in $OWN_SKILLS; do
    if [ -e "$TARGET/skills/$s/SKILL.md" ]; then ok "skills/$s"; else bad "skills/$s"; fi
  done
  if [ -e "$TARGET/agent-memory/README.md" ]; then ok "agent-memory/"; else bad "agent-memory/"; fi
  if [ "$WITH_VENDOR" -eq 1 ]; then
    for s in caveman grill-me test-driven-development; do
      if [ -e "$TARGET/skills/$s/SKILL.md" ]; then ok "vendored skills/$s"; else bad "vendored skills/$s"; fi
    done
  fi
  echo ""
  if [ "$MISSING" -eq 0 ]; then
    echo "All expected files present. Restart Claude Code, then run /skills and /agents."
  else
    echo "$MISSING item(s) missing — run 'bash install.sh' (add --with-vendor for community skills)."
    exit 1
  fi
  exit 0
fi

# ---- install helpers ----
ensure_backup_dir() {
  if [ -z "$BACKUP" ]; then
    BACKUP="$TARGET/.kit-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP"
    echo "  backing up overwritten files to: $BACKUP"
  fi
}
backup_if_exists() {  # $1 = path relative to TARGET
  if [ -e "$TARGET/$1" ]; then
    ensure_backup_dir
    mkdir -p "$BACKUP/$(dirname "$1")"
    cp -R "$TARGET/$1" "$BACKUP/$1"
  fi
}
copy_skill() {  # $1 = skill name, $2 = source base dir
  backup_if_exists "skills/$1"
  mkdir -p "$TARGET/skills"
  rm -rf "${TARGET:?}/skills/$1"
  cp -R "$2/$1" "$TARGET/skills/$1"
}

echo "Installing the Agent Orchestration Kit into: $TARGET"
mkdir -p "$TARGET"

# CLAUDE.md — never clobber a user's own playbook
if [ -e "$TARGET/CLAUDE.md" ]; then
  if cmp -s "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; then
    echo "  • CLAUDE.md already installed (unchanged)"
  else
    backup_if_exists "CLAUDE.orchestration.md"
    cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.orchestration.md"
    echo "  • existing CLAUDE.md preserved → kit playbook written to CLAUDE.orchestration.md (merge manually)"
  fi
else
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  • CLAUDE.md installed"
fi

# implementer agents
mkdir -p "$TARGET/agents"
for f in implementer-sonnet.md implementer-haiku.md; do
  backup_if_exists "agents/$f"
  cp "$SRC/agents/$f" "$TARGET/agents/$f"
done
echo "  • agents/ (implementer-sonnet, implementer-haiku)"

# own skills
for s in $OWN_SKILLS; do copy_skill "$s" "$SRC/skills"; done
echo "  • skills/ ($OWN_SKILLS)"

# agent-memory seeds
backup_if_exists "agent-memory"
mkdir -p "$TARGET/agent-memory"
cp -R "$SRC/agent-memory/." "$TARGET/agent-memory/"
echo "  • agent-memory/ (7 role seeds)"

# vendored skills (optional)
if [ "$WITH_VENDOR" -eq 1 ]; then
  count=0
  for base in "$SRC/vendor/mattpocock" "$SRC/vendor/superpowers"; do
    for dir in "$base"/*/; do
      name="$(basename "$dir")"
      [ -f "$dir/SKILL.md" ] || continue   # skip LICENSE and non-skill files
      copy_skill "$name" "$base"
      count=$((count+1))
    done
  done
  echo "  • vendor/ ($count community skills)"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Restart Claude Code (it reads ~/.claude at startup)."
echo "  2. Run  /skills  and  /agents  to confirm they loaded."
echo "  3. New here? Read START-HERE.md.  Verify anytime with:  bash install.sh --check"
[ "$WITH_VENDOR" -eq 0 ] && echo "  (Tip: add --all to also install the 23 vendored community skills.)"
exit 0
