#!/usr/bin/env pwsh
#
# install.ps1 — install the Claude Code Agent Orchestration Kit into ~/.claude
#
#   pwsh -File install.ps1                core: CLAUDE.md + agents + 5 own skills + memory seeds
#   pwsh -File install.ps1 -WithVendor    also install the 23 vendored community skills
#   pwsh -File install.ps1 -All           everything (same as -WithVendor)
#   pwsh -File install.ps1 -Check         doctor mode: report what's installed, change nothing
#   pwsh -File install.ps1 -Help          show help
#
# Override the target for testing:  $env:CLAUDE_HOME = "C:\tmp\test"; pwsh -File install.ps1
#
[CmdletBinding()]
param(
  [switch]$WithVendor,
  [switch]$All,
  [switch]$Check,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
$Src    = $PSScriptRoot
$Target = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }
if ($All) { $WithVendor = $true }

$OwnSkills   = @('align','dispatch','tdd','diagnose','review-diff')
$script:Backup = $null

function Show-Usage {
  @"
Install the Claude Code Agent Orchestration Kit into your ~/.claude folder.

Usage: pwsh -File install.ps1 [options]

  (no options)   core: CLAUDE.md + implementer agents + 5 own skills + memory seeds
  -WithVendor    also install the 23 vendored community skills
  -All           everything (same as -WithVendor)
  -Check         doctor mode: report what's installed, change nothing
  -Help          show this help

Target folder: $Target
  (override for testing:  `$env:CLAUDE_HOME = "C:\tmp\test"; pwsh -File install.ps1)
"@ | Write-Host
}

if ($Help) { Show-Usage; exit 0 }

# ---- doctor mode ----
if ($Check) {
  Write-Host "Checking install at: $Target"
  $script:missing = 0
  function Ok($m)  { Write-Host "  " -NoNewline; Write-Host "OK " -ForegroundColor Green -NoNewline; Write-Host $m }
  function Bad($m) { Write-Host "  " -NoNewline; Write-Host "-- " -ForegroundColor Red   -NoNewline; Write-Host "$m  (missing)"; $script:missing++ }

  if ((Test-Path (Join-Path $Target 'CLAUDE.md')) -or (Test-Path (Join-Path $Target 'CLAUDE.orchestration.md'))) {
    Ok "CLAUDE.md (playbook)" } else { Bad "CLAUDE.md (playbook)" }
  foreach ($f in @('implementer-sonnet','implementer-haiku')) {
    if (Test-Path (Join-Path $Target "agents/$f.md")) { Ok "agents/$f.md" } else { Bad "agents/$f.md" }
  }
  foreach ($s in $OwnSkills) {
    if (Test-Path (Join-Path $Target "skills/$s/SKILL.md")) { Ok "skills/$s" } else { Bad "skills/$s" }
  }
  if (Test-Path (Join-Path $Target 'agent-memory/README.md')) { Ok "agent-memory/" } else { Bad "agent-memory/" }
  if ($WithVendor) {
    foreach ($s in @('caveman','grill-me','test-driven-development')) {
      if (Test-Path (Join-Path $Target "skills/$s/SKILL.md")) { Ok "vendored skills/$s" } else { Bad "vendored skills/$s" }
    }
  }
  Write-Host ""
  if ($script:missing -eq 0) {
    Write-Host "All expected files present. Restart Claude Code, then run /skills and /agents."
    exit 0
  } else {
    Write-Host "$($script:missing) item(s) missing — run 'pwsh -File install.ps1' (add -WithVendor for community skills)."
    exit 1
  }
}

# ---- install helpers ----
function Backup-IfExists($rel) {
  $p = Join-Path $Target $rel
  if (Test-Path $p) {
    if (-not $script:Backup) {
      $script:Backup = Join-Path $Target (".kit-backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
      New-Item -ItemType Directory -Force -Path $script:Backup | Out-Null
      Write-Host "  backing up overwritten files to: $script:Backup"
    }
    $dest = Join-Path $script:Backup $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    Copy-Item -Recurse -Force $p $dest
  }
}
function Copy-Skill($name, $base) {
  Backup-IfExists "skills/$name"
  New-Item -ItemType Directory -Force -Path (Join-Path $Target 'skills') | Out-Null
  $d = Join-Path (Join-Path $Target 'skills') $name
  if (Test-Path $d) { Remove-Item -Recurse -Force $d }
  Copy-Item -Recurse -Force (Join-Path $base $name) $d
}

Write-Host "Installing the Agent Orchestration Kit into: $Target"
New-Item -ItemType Directory -Force -Path $Target | Out-Null

# CLAUDE.md — never clobber a user's own playbook
$claudeTarget = Join-Path $Target 'CLAUDE.md'
$claudeSrc    = Join-Path $Src 'CLAUDE.md'
if (Test-Path $claudeTarget) {
  $same = (Get-FileHash $claudeTarget).Hash -eq (Get-FileHash $claudeSrc).Hash
  if ($same) {
    Write-Host "  - CLAUDE.md already installed (unchanged)"
  } else {
    Backup-IfExists 'CLAUDE.orchestration.md'
    Copy-Item -Force $claudeSrc (Join-Path $Target 'CLAUDE.orchestration.md')
    Write-Host "  - existing CLAUDE.md preserved -> kit playbook written to CLAUDE.orchestration.md (merge manually)"
  }
} else {
  Copy-Item -Force $claudeSrc $claudeTarget
  Write-Host "  - CLAUDE.md installed"
}

# implementer agents
New-Item -ItemType Directory -Force -Path (Join-Path $Target 'agents') | Out-Null
foreach ($f in @('implementer-sonnet.md','implementer-haiku.md')) {
  Backup-IfExists "agents/$f"
  Copy-Item -Force (Join-Path $Src "agents/$f") (Join-Path $Target "agents/$f")
}
Write-Host "  - agents/ (implementer-sonnet, implementer-haiku)"

# own skills
foreach ($s in $OwnSkills) { Copy-Skill $s (Join-Path $Src 'skills') }
Write-Host "  - skills/ ($($OwnSkills -join ', '))"

# agent-memory seeds (idempotent per top-level entry)
Backup-IfExists 'agent-memory'
New-Item -ItemType Directory -Force -Path (Join-Path $Target 'agent-memory') | Out-Null
Get-ChildItem (Join-Path $Src 'agent-memory') | ForEach-Object {
  $dest = Join-Path (Join-Path $Target 'agent-memory') $_.Name
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item -Recurse -Force $_.FullName $dest
}
Write-Host "  - agent-memory/ (7 role seeds)"

# vendored skills (optional)
if ($WithVendor) {
  $count = 0
  foreach ($base in @((Join-Path $Src 'vendor/mattpocock'), (Join-Path $Src 'vendor/superpowers'))) {
    Get-ChildItem -Directory $base | ForEach-Object {
      if (Test-Path (Join-Path $_.FullName 'SKILL.md')) {
        Copy-Skill $_.Name $base
        $count++
      }
    }
  }
  Write-Host "  - vendor/ ($count community skills)"
}

Write-Host ""
Write-Host "Done. Next steps:"
Write-Host "  1. Restart Claude Code (it reads ~/.claude at startup)."
Write-Host "  2. Run  /skills  and  /agents  to confirm they loaded."
Write-Host "  3. New here? Read START-HERE.md.  Verify anytime with:  pwsh -File install.ps1 -Check"
if (-not $WithVendor) { Write-Host "  (Tip: add -All to also install the 23 vendored community skills.)" }
exit 0
