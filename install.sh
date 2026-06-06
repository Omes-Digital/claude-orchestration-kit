#!/usr/bin/env bash
#
# install.sh — install the Claude Code Agent Orchestration Kit into ~/.claude
#
#   bash install.sh                 core: CLAUDE.md + agents + 8 own skills + memory seeds + scripts
#   bash install.sh --with-vendor   also install the 15 vendored community skills
#   bash install.sh --all           everything (same as --with-vendor)
#   bash install.sh --check         doctor mode: report what's installed, change nothing
#   bash install.sh --verify        integrity: check files against SHA256SUMS, change nothing
#   bash install.sh --uninstall     preview which kit files would be removed (dry run)
#   bash install.sh --uninstall --yes   actually remove the kit's files
#   bash install.sh --help          show help
#
# Override the target for testing:  CLAUDE_HOME=/tmp/test bash install.sh
#
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${CLAUDE_HOME:-$HOME/.claude}"

WITH_VENDOR=0
CHECK=0
VERIFY=0
UNINSTALL=0
ASSUME_YES=0
BACKUP=""

OWN_SKILLS="align dispatch tdd diagnose review-diff scope-guard reread-before-edit verify-and-report"
MEMORY_ROLES="architect explorer researcher implementer reviewer auditor memory-curator"

usage() {
  cat <<EOF
Install the Claude Code Agent Orchestration Kit into your ~/.claude folder.

Usage: bash install.sh [options]

  (no options)    core: CLAUDE.md + implementer agents + 8 own skills + memory seeds + scripts
  --with-vendor   also install the 15 vendored community skills
  --all           everything (same as --with-vendor)
  --check         doctor mode: report what's installed, change nothing
  --verify        integrity check: verify files against SHA256SUMS, change nothing
  --uninstall     preview the kit files that would be removed (dry run; add --yes to delete)
  --yes           with --uninstall, actually remove (otherwise it only previews)
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
    --verify)            VERIFY=1 ;;
    --uninstall)         UNINSTALL=1 ;;
    --yes|-y)            ASSUME_YES=1 ;;
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
  if [ -e "$TARGET/scripts/statusline.sh" ]; then ok "scripts/ (statusline)"; else bad "scripts/ (statusline)"; fi
  if [ -e "$TARGET/hooks/no-destructive-git.sh" ]; then ok "hooks/ (guardrails)"; else bad "hooks/ (guardrails)"; fi
  if [ "$WITH_VENDOR" -eq 1 ]; then
    for s in caveman grill-me to-issues; do
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

# ---- verify mode ----
if [ "$VERIFY" -eq 1 ]; then
  cd "$SRC"
  if [ ! -f SHA256SUMS ]; then
    echo "No SHA256SUMS found in $SRC." >&2
    echo "Generate it first:  bash scripts/gen-checksums.sh" >&2
    exit 1
  fi
  echo "Verifying $SRC against SHA256SUMS ..."
  verify_tree() {
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum -c --quiet SHA256SUMS
    elif command -v shasum >/dev/null 2>&1; then
      local out st
      out="$(shasum -a 256 -c SHA256SUMS 2>&1)"; st=$?
      printf '%s\n' "$out" | grep -vE ': OK$' >&2 || true
      return $st
    else
      echo "need sha256sum or shasum to verify" >&2; return 2
    fi
  }
  if verify_tree; then
    echo "  OK — all listed files match SHA256SUMS."
    exit 0
  else
    echo "  FAILED — bytes differ from the manifest (see above). Do not trust this copy." >&2
    exit 1
  fi
fi

# ---- uninstall mode ----
if [ "$UNINSTALL" -eq 1 ]; then
  if [ "$ASSUME_YES" -eq 1 ]; then
    echo "Removing the Agent Orchestration Kit from: $TARGET"
  else
    echo "Dry run — these kit files WOULD be removed from: $TARGET"
    echo "(nothing is deleted yet; re-run with --yes to actually remove)"
  fi
  echo ""
  removed=0
  remove_path() {  # $1 = path relative to TARGET, $2 = optional note
    p="$TARGET/$1"
    [ -e "$p" ] || return 0
    if [ "$ASSUME_YES" -eq 1 ]; then
      rm -rf "$p"; printf '  removed    %s' "$1"
    else
      printf '  would rm   %s' "$1"
    fi
    [ -n "${2:-}" ] && printf '   (%s)' "$2"
    printf '\n'
    removed=$((removed+1))
  }

  # own skills
  for s in $OWN_SKILLS; do remove_path "skills/$s"; done
  # vendored skills — only the names this kit ships (your own skills are left alone)
  for base in "$SRC/vendor/mattpocock" "$SRC/vendor/superpowers"; do
    for dir in "$base"/*/; do
      [ -f "$dir/SKILL.md" ] || continue
      remove_path "skills/$(basename "$dir")"
    done
  done
  # implementer agents
  remove_path "agents/implementer-sonnet.md"
  remove_path "agents/implementer-haiku.md"
  # scripts
  remove_path "scripts/statusline.sh"
  remove_path "scripts/statusline.ps1"
  # hooks
  remove_path "hooks/no-destructive-git.sh"
  remove_path "hooks/no-secrets.sh"
  remove_path "hooks/auto-format.sh"
  remove_path "hooks/README.md"
  # agent-memory (you may have curated this)
  remove_path "agent-memory" "may hold notes you curated — a copy is in .kit-backup-* if you used the installer"
  # CLAUDE.md — remove ONLY the kit's unchanged copy; keep a customized/merged one
  if [ -e "$TARGET/CLAUDE.md" ]; then
    if cmp -s "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"; then
      remove_path "CLAUDE.md"
    else
      echo "  KEEPING    CLAUDE.md   (differs from the kit's — looks customized/merged; remove by hand if you want)"
    fi
  fi
  remove_path "CLAUDE.orchestration.md"

  # tidy now-empty dirs we own (rmdir only succeeds if empty, so your files are safe)
  if [ "$ASSUME_YES" -eq 1 ]; then
    rmdir "$TARGET/scripts" "$TARGET/hooks" "$TARGET/agents" 2>/dev/null || true
  fi

  echo ""
  if [ "$ASSUME_YES" -eq 1 ]; then
    echo "Removed $removed item(s). Backups (.kit-backup-*) and anything you added yourself were left untouched."
    echo "Restart Claude Code to drop the kit's skills/agents from the session."
  else
    echo "$removed item(s) would be removed. To actually delete:  bash install.sh --uninstall --yes"
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

# scripts — opt-in status line (context meter) + helpers
backup_if_exists "scripts"
mkdir -p "$TARGET/scripts"
cp -R "$SRC/scripts/." "$TARGET/scripts/"
chmod +x "$TARGET"/scripts/*.sh 2>/dev/null || true
echo "  • scripts/ (statusline meter — opt-in; enable per INSTALL.md §2)"

# hooks — opt-in deterministic guardrails (no-destructive-git, auto-format)
backup_if_exists "hooks"
mkdir -p "$TARGET/hooks"
cp -R "$SRC/hooks/." "$TARGET/hooks/"
chmod +x "$TARGET"/hooks/*.sh 2>/dev/null || true
echo "  • hooks/ (git guardrail + secrets guard + auto-format — opt-in; wire per hooks/README.md)"

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
[ "$WITH_VENDOR" -eq 0 ] && echo "  (Tip: add --all to also install the 15 vendored community skills.)"
exit 0
