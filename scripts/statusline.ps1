#!/usr/bin/env pwsh
#
# statusline.ps1 — opt-in Claude Code status line for the Agent Orchestration Kit (Windows).
#
# Shows:  <model> · <dir> (<git-branch>) · ctx NN%   — and nudges /compact past a threshold,
# so the architect keeps its own context lean (frontier context re-processes every turn).
# This is the PowerShell port of statusline.sh; behaviour is identical.
#
# Enable it (NOT turned on automatically): add to %USERPROFILE%\.claude\settings.json —
#   "statusLine": { "type": "command", "command": "pwsh -File ~/.claude/scripts/statusline.ps1", "padding": 1 }
# then restart Claude Code. See INSTALL.md §2 and docs/FAQ.md.
#
# Threshold override:  $env:KIT_COMPACT_AT = 80   (percent of the context window; default 75).
#
$ErrorActionPreference = 'SilentlyContinue'

$raw       = [Console]::In.ReadToEnd()
$threshold = if ($env:KIT_COMPACT_AT) { [int]$env:KIT_COMPACT_AT } else { 75 }

try { $j = $raw | ConvertFrom-Json } catch { Write-Host -NoNewline 'kit statusline: bad input'; exit 0 }

$model   = if ($j.model.display_name) { $j.model.display_name } elseif ($j.model.id) { $j.model.id } else { '?' }
$dir     = if ($j.workspace.current_dir) { $j.workspace.current_dir } elseif ($j.cwd) { $j.cwd } else { '' }
$dirBase = if ($dir) { Split-Path $dir -Leaf } else { '' }
$pct     = $j.context_window.used_percentage
$branch  = & git -C $dir rev-parse --abbrev-ref HEAD 2>$null

$line = $model
if ($dirBase) { $line += " · $dirBase" }
if ($branch)  { $line += " ($branch)" }

if ($null -ne $pct -and "$pct" -ne '') {
  $pi = [int][math]::Floor([double]$pct)
  if ($pi -ge $threshold) {
    $line += " · " + "$([char]27)[33mctx $pi% ! /compact$([char]27)[0m"   # yellow warning
  } else {
    $line += " · ctx $pi%"
  }
}

Write-Host -NoNewline $line
