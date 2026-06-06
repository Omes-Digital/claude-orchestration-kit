#!/usr/bin/env pwsh
#
# statusline.ps1 — opt-in Claude Code status line for the Agent Orchestration Kit (Windows).
#
# Shows:  <model> · <dir> (<git-branch>) · ctx NN% · $cost · 5h/7d limit%   — and nudges /compact
# past a threshold, so the architect keeps its own context lean (frontier context re-processes every
# turn). The cost + rate-limit segments appear only when Claude Code supplies them. PowerShell port of
# statusline.sh; behaviour is identical.
#
# Enable it (NOT turned on automatically): add to %USERPROFILE%\.claude\settings.json —
#   "statusLine": { "type": "command", "command": "pwsh -File ~/.claude/scripts/statusline.ps1", "padding": 1 }
# then restart Claude Code. See INSTALL.md §2 and docs/FAQ.md.
#
# The /compact nudge fires by WINDOW PERCENT, with MODEL-AWARE defaults — the Opus architect nudges
# earlier than the cheaper implementer tiers:
#   Opus           40% of window
#   other models  60% of window
# Note % is window-relative: on a 1M-context model 40% ≈ 400k tokens. To cap by absolute size instead,
# set $env:KIT_COMPACT_TOKENS (off by default). Override the percent with $env:KIT_COMPACT_AT.
#
# Cost + rate limits (always shown when present; the WARN colours are opt-in):
#   $<cost>  from cost.total_cost_usd. Set $env:KIT_BUDGET_USD to a dollar figure to turn it RED past it.
#   5h/7d%   from rate_limits.{five_hour,seven_day}.used_percentage (Claude.ai Pro/Max only);
#            the segment turns yellow at $env:KIT_RATELIMIT_WARN% (default 80).
#
$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()

try { $j = $raw | ConvertFrom-Json } catch { Write-Host -NoNewline 'kit statusline: bad input'; exit 0 }

$model   = if ($j.model.display_name) { $j.model.display_name } elseif ($j.model.id) { $j.model.id } else { '?' }
$dir     = if ($j.workspace.current_dir) { $j.workspace.current_dir } elseif ($j.cwd) { $j.cwd } else { '' }
$dirBase = if ($dir) { Split-Path $dir -Leaf } else { '' }
$pct     = $j.context_window.used_percentage
$toks    = $j.context_window.total_input_tokens
$cost    = $j.cost.total_cost_usd
$lim5    = $j.rate_limits.five_hour.used_percentage
$lim7    = $j.rate_limits.seven_day.used_percentage
$branch  = & git -C $dir rev-parse --abbrev-ref HEAD 2>$null

# model-aware nudge — the Opus architect nudges earlier (40% of window) than the cheaper tiers (60%).
# Percent governs by default; KIT_COMPACT_TOKENS adds an optional absolute-token nudge on top.
if ($model -match '(?i)opus') { $defPct = 40 } else { $defPct = 60 }
$thresholdPct = if ($env:KIT_COMPACT_AT)     { [int]$env:KIT_COMPACT_AT }     else { $defPct }
$thresholdTok = if ($env:KIT_COMPACT_TOKENS) { [int]$env:KIT_COMPACT_TOKENS } else { $null }

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
if ($null -ne $thresholdTok -and $null -ne $toks -and "$toks" -ne '' -and [double]$toks -ge $thresholdTok) { $warn = $true }
if ($null -ne $pi -and $pi -ge $thresholdPct) { $warn = $true }

if ($ctx) {
  if ($warn) { $line += " · " + "$([char]27)[33m$ctx ! /compact$([char]27)[0m" }
  else       { $line += " · $ctx" }
}

# cost — estimated session spend (cost.total_cost_usd); RED once it reaches an opt-in KIT_BUDGET_USD
if ($null -ne $cost -and "$cost" -ne '') {
  $costNum = [double]$cost
  if ($costNum -ge 0.005) {
    $costStr = $costNum.ToString('0.00', [Globalization.CultureInfo]::InvariantCulture)
    $budget = $null
    if ($env:KIT_BUDGET_USD -match '^[0-9]+(\.[0-9]+)?$') { $budget = [double]$env:KIT_BUDGET_USD }
    if ($null -ne $budget -and $costNum -ge $budget) {
      $line += " · " + "$([char]27)[31m`$$costStr !$([char]27)[0m"
    } else {
      $line += " · `$$costStr"
    }
  }
}

# rate limits — % of the 5h / 7d plan window used (Claude.ai Pro/Max); yellow past KIT_RATELIMIT_WARN
$rlAt = 80
if ($env:KIT_RATELIMIT_WARN -match '^[0-9]+$') { $rlAt = [int]$env:KIT_RATELIMIT_WARN }
$rlsegs = @()
foreach ($p in @(@('5h', $lim5), @('7d', $lim7))) {
  if ($null -eq $p[1] -or "$($p[1])" -eq '') { continue }
  $vi  = [int][math]::Floor([double]$p[1])
  $seg = "$($p[0]) $vi%"
  if ($vi -ge $rlAt) { $seg = "$([char]27)[33m$seg$([char]27)[0m" }
  $rlsegs += $seg
}
if ($rlsegs.Count -gt 0) { $line += " · " + ($rlsegs -join ' ') }

Write-Host -NoNewline $line
