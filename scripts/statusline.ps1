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
# The /compact nudge fires on EITHER trigger (whichever hits first):
#   $env:KIT_COMPACT_TOKENS = 80000  absolute context tokens (default; the real "staying lean" signal —
#                                    ~80k is where context rot starts to bite, regardless of window size)
#   $env:KIT_COMPACT_AT = 40         percent of the context window (backstop; 40% of a 1M window is ~400k)
#
$ErrorActionPreference = 'SilentlyContinue'

$raw          = [Console]::In.ReadToEnd()
$thresholdPct = if ($env:KIT_COMPACT_AT)     { [int]$env:KIT_COMPACT_AT }     else { 40 }
$thresholdTok = if ($env:KIT_COMPACT_TOKENS) { [int]$env:KIT_COMPACT_TOKENS } else { 80000 }

try { $j = $raw | ConvertFrom-Json } catch { Write-Host -NoNewline 'kit statusline: bad input'; exit 0 }

$model   = if ($j.model.display_name) { $j.model.display_name } elseif ($j.model.id) { $j.model.id } else { '?' }
$dir     = if ($j.workspace.current_dir) { $j.workspace.current_dir } elseif ($j.cwd) { $j.cwd } else { '' }
$dirBase = if ($dir) { Split-Path $dir -Leaf } else { '' }
$pct     = $j.context_window.used_percentage
$toks    = $j.context_window.total_input_tokens
$branch  = & git -C $dir rev-parse --abbrev-ref HEAD 2>$null

$line = $model
if ($dirBase) { $line += " · $dirBase" }
if ($branch)  { $line += " ($branch)" }

# build the context segment ("ctx 8% · 84k") from whichever fields are present
$pi  = $null
$ctx = ''
if ($null -ne $pct  -and "$pct"  -ne '') { $pi = [int][math]::Floor([double]$pct); $ctx = "ctx $pi%" }
if ($null -ne $toks -and "$toks" -ne '') {
  $k = [int][math]::Floor([double]$toks / 1000)
  if ($ctx) { $ctx += " · ${k}k" } else { $ctx = "ctx ${k}k" }
}

# nudge on EITHER trigger: absolute tokens (primary) or window % (backstop)
$warn = $false
if ($null -ne $toks -and "$toks" -ne '' -and [double]$toks -ge $thresholdTok) { $warn = $true }
if ($null -ne $pi -and $pi -ge $thresholdPct) { $warn = $true }

if ($ctx) {
  if ($warn) { $line += " · " + "$([char]27)[33m$ctx ! /compact$([char]27)[0m" }
  else       { $line += " · $ctx" }
}

Write-Host -NoNewline $line
