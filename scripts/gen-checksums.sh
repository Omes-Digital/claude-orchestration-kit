#!/usr/bin/env bash
#
# gen-checksums.sh — (re)generate SHA256SUMS over the kit's publishable files.
#
# Lists everything git would publish (tracked + new-but-not-ignored, honouring .gitignore), hashes
# each file, and writes SHA256SUMS at the repo root. Re-run this after ANY change to kit files, then
# commit the updated SHA256SUMS alongside them. Users verify their own copy with:
#
#     bash install.sh --verify          (or, on Windows:  pwsh -File install.ps1 -Verify)
#
# This is the integrity half of "trust, but verify": the manifest proves a clone's bytes match what
# the maintainer published. (To also prove the manifest itself is authentic, sign it — e.g. minisign —
# and distribute the public key out of band; that hardening is optional and not required here.)
#
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"
cd "$ROOT"

if   command -v sha256sum >/dev/null 2>&1; then SHA=(sha256sum)
elif command -v shasum    >/dev/null 2>&1; then SHA=(shasum -a 256)
else echo "gen-checksums: need sha256sum or shasum on PATH" >&2; exit 1; fi

# publishable files = tracked + untracked-not-ignored, minus the manifest/signature themselves
files="$(git ls-files --cached --others --exclude-standard \
          | grep -vxE 'SHA256SUMS|SHA256SUMS\.minisig' \
          | LC_ALL=C sort -u)"

: > SHA256SUMS.tmp
count=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  [ -f "$f" ] || continue
  "${SHA[@]}" "$f" >> SHA256SUMS.tmp
  count=$((count+1))
done <<EOF
$files
EOF
mv SHA256SUMS.tmp SHA256SUMS
echo "Wrote SHA256SUMS over $count files (sha256)."
