# scripts/install.ps1 — install the split-agents-template skill into your agent harness.
#
# The skill folder (skill/split-agents-template/) is copied verbatim, Agent Skills standard.
# Flat-file slash-command dispatchers are generated for harnesses that use them.
#
# Usage:
#   powershell -NoProfile -File scripts\install.ps1                      interactive harness selection
#   powershell -NoProfile -File scripts\install.ps1 -List                list supported harnesses (* = detected)
#   powershell -NoProfile -File scripts\install.ps1 -Harness kiro,claude-code
#   powershell -NoProfile -File scripts\install.ps1 -Target <repo>       project-local target repo (default prompts; "." = this repo)
#   powershell -NoProfile -File scripts\install.ps1 -Global              install to home paths instead of project-local
#
# Never overwrites an existing destination without confirmation. Prints a summary at the end.

[CmdletBinding()]
param(
  [switch]$List,
  [switch]$Global,
  [string]$Harness,
  [string]$Target
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$SkillDir = Join-Path $RepoRoot 'skill/split-agents-template'

if (-not (Test-Path (Join-Path $SkillDir 'SKILL.md'))) {
  Write-Error "Skill not found at $SkillDir — install this skill folder intact"
  exit 1
}

$HID = 'split-agents-template'
$HomeDir = $env:HOME; if (-not $HomeDir) { $HomeDir = $env:USERPROFILE }

# name, localSkills, globalSkills, slashPath, detectDirs
$Harnesses = @(
  @{ n='claude-code';   l='.claude/skills';   g="$HomeDir/.claude/skills";   s=".claude/commands/$HID.md";          d=@("$HomeDir/.claude") },
  @{ n='opencode';      l='';                 g="$HomeDir/.opencode/skills"; s=".opencode/command/$HID.md";         d=@("$HomeDir/.opencode", "$HomeDir/.config/opencode") },
  @{ n='codex';         l='.agents/skills';   g="$HomeDir/.codex/skills";    s=".codex/prompts/$HID.md";            d=@("$HomeDir/.codex") },
  @{ n='cursor';        l='.cursor/skills';   g="$HomeDir/.cursor/skills";   s=".cursor/commands/$HID.md";          d=@("$HomeDir/.cursor") },
  @{ n='gemini';        l='';                 g="$HomeDir/.gemini/skills";   s=".gemini/commands/$HID.toml";        d=@("$HomeDir/.gemini") },
  @{ n='antigravity';   l='.agent/skills';    g="$HomeDir/.agent/skills";    s='';                                  d=@("$HomeDir/.agent", "$HomeDir/.gemini") },
  @{ n='github-copilot'; l='';                g="$HomeDir/.agents/skills";   s=".github/prompts/$HID.prompt.md";    d=@("$HomeDir/.config/gh-copilot", "$HomeDir/.config/github-copilot") },
  @{ n='hermes';        l='.hermes/skills';   g="$HomeDir/.hermes/skills";   s='';                                  d=@("$HomeDir/.hermes") },
  @{ n='kiro';          l='.kiro/skills';     g="$HomeDir/.kiro/skills";     s='';                                  d=@("$HomeDir/.kiro") },
  @{ n='pi';            l='.pi/skills';       g="$HomeDir/.pi/skills";       s='';                                  d=@("$HomeDir/.pi") },
  @{ n='qoder';         l='.qoder/skills';    g="$HomeDir/.qoder/skills";    s='';                                  d=@("$HomeDir/.qoder") },
  @{ n='rovodev';       l='.rovodev/skills';  g="$HomeDir/.rovodev/skills";  s='';                                  d=@("$HomeDir/.rovodev") },
  @{ n='trae';          l='.trae/skills';     g="$HomeDir/.trae/skills";     s='';                                  d=@("$HomeDir/.trae") },
  @{ n='trae-cn';       l='.trae-cn/skills';  g="$HomeDir/.trae-cn/skills";  s='';                                  d=@("$HomeDir/.trae-cn") },
  @{ n='vibe';          l='.vibe/skills';     g="$HomeDir/.vibe/skills";     s='';                                  d=@("$HomeDir/.vibe") },
  @{ n='deepseek';      l='.dsh/skills';      g="$HomeDir/.dsh/skills";      s='';                                  d=@("$HomeDir/.dsh") },
  @{ n='veto';          l='';                 g="$HomeDir/.veto/skills";     s='';                                  d=@("$HomeDir/.veto") }
)

$Installed = New-Object System.Collections.Generic.List[string]
$Skipped = New-Object System.Collections.Generic.List[string]

function Test-Detected {
  param($H)
  foreach ($d in $H.d) { if ($d -and (Test-Path -LiteralPath $d)) { return $true } }
  return $false
}

function Confirm-Overwrite {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $true }
  $ans = Read-Host "  $Path exists. Overwrite? [y/N]"
  return ($ans -eq 'y' -or $ans -eq 'Y')
}

function Write-Dispatcher {
  param([string]$DestPath, [string]$SkillRef)
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DestPath) | Out-Null
  if ($DestPath -like '*.toml') {
    @'
name = "split-agents-template"
description = "Scaffold or refresh a project's AGENTS.md against agents-template-schema 4 (Kiro-style: one domain per file, concise, why on every rule)."

prompt = """
Run the installed split-agents-template skill. Full procedure: {0}

This dispatcher is thin; do not duplicate the procedure here.
"""
'@ -f $SkillRef | Set-Content -Path $DestPath -Encoding UTF8
  } else {
    @'
---
name: split-agents-template
description: "Scaffold or refresh a project's AGENTS.md against agents-template-schema 4 (Kiro-style: one domain per file, concise, why on every rule). Use to set up, refresh, or migrate AGENTS.md."
---

Run the installed split-agents-template skill. Full procedure: `{0}`

This dispatcher is thin; do not duplicate the procedure here.
'@ -f $SkillRef | Set-Content -Path $DestPath -Encoding UTF8
  }
}

function Install-One {
  param([hashtable]$H, [string]$Scope, [string]$ScopeRoot)

  # 1) skill folder
  if ($Scope -eq 'global') {
    $Dest = Join-Path $H.g $HID
  } elseif ($H.l) {
    $Dest = Join-Path $ScopeRoot ($H.l -replace '/', '\')
    $Dest = Join-Path $Dest $HID
  } elseif ($H.g) {
    Write-Host "  note: $($H.n) has no project-local skills dir; skill installs globally, dispatcher goes local."
    Install-One $H 'global' ''
    if ($H.s) {
      $Sp = Join-Path $ScopeRoot ($H.s -replace '/', '\')
      if (Confirm-Overwrite $Sp) {
        Write-Dispatcher -DestPath $Sp -SkillRef (Join-Path $H.g "$($HID)/SKILL.md")
        $Installed.Add($Sp); Write-Host "  installed: $Sp"
      } else {
        $Skipped.Add($Sp)
      }
    }
    return
  } else {
    Write-Host "  note: $($H.n) has no skills path; skipped entirely."
    $Skipped.Add("$($H.n) (no skills path)")
    return
  }
  $SkillRef = Join-Path $Dest 'SKILL.md'

  if (Confirm-Overwrite $SkillRef) {
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Copy-Item -Path (Join-Path $SkillDir '*') -Destination $Dest -Recurse -Force
    $Installed.Add($Dest); Write-Host "  installed: $Dest"
  } else {
    $Skipped.Add($SkillRef); Write-Host "  skipped: $SkillRef"
  }

  # 2) flat-file dispatcher (project-local only)
  if ($H.s -and $Scope -eq 'local') {
    $Sp = Join-Path $ScopeRoot ($H.s -replace '/', '\')
    if (Confirm-Overwrite $Sp) {
      Write-Dispatcher -DestPath $Sp -SkillRef $SkillRef
      $Installed.Add($Sp); Write-Host "  installed: $Sp"
    } else {
      $Skipped.Add($Sp)
    }
  }

  if ($H.n -eq 'veto') { Write-Host "  note: Veto discourages project-local installs; installed to the home path." }
}

# --- list --------------------------------------------------------------------

if ($List) {
  Write-Host 'Supported harnesses (* = detected on this machine):'
  $i = 0
  foreach ($H in $Harnesses) {
    $i++
    $mark = ''; if (Test-Detected $H) { $mark = ' *' }
    Write-Host ('  {0,2}. {1,-15}{2}' -f $i, $H.n, $mark)
  }
  exit 0
}

# --- select -------------------------------------------------------------------

$Chosen = @()
if ($Harness) {
  $Harness.Split(',') | ForEach-Object {
    $sel = $_.Trim()
    if ($sel -match '^\d+$') {
      $idx = [int]$sel - 1
      if ($idx -lt 0 -or $idx -ge $Harnesses.Count) { Write-Error "number out of range: $sel (see -List)" }
      $sel = $Harnesses[$idx].n
    }
    $Chosen += $sel
  }
} else {
  Write-Host 'Supported harnesses (* = detected on this machine):'
  $i = 0
  foreach ($H in $Harnesses) {
    $i++
    $mark = ''; if (Test-Detected $H) { $mark = ' *' }
    Write-Host ('  {0,2}. {1,-15}{2}' -f $i, $H.n, $mark)
  }
  $ans = Read-Host 'Select by number (comma-separated), "a" for all detected, or "all"'
  if ($ans -eq 'a' -or $ans -eq 'A' -or $ans -eq 'all') {
    foreach ($H in $Harnesses) { if (Test-Detected $H) { $Chosen += $H.n } }
    if ($Chosen.Count -eq 0) { Write-Host 'No harnesses detected. Re-run and pick by number.'; exit 0 }
  } else {
    $Chosen = @($ans.Split(',') | ForEach-Object {
      $sel = $_.Trim()
      if ($sel -match '^\d+$') {
        $idx = [int]$sel - 1
        if ($idx -lt 0 -or $idx -ge $Harnesses.Count) { Write-Error "number out of range: $sel" }
        $Harnesses[$idx].n
      } else { $sel }
    })
  }
}

# --- scope --------------------------------------------------------------------

$ScopeRoot = $null
if (-not $Global) {
  Write-Host 'Scope: project-local. Skills are source for agents: COMMIT the installed folder, do not gitignore it'
  Write-Host '(Codex, Antigravity, and Kiro honor ignore rules and will not see ignored skills).'
  if (-not $Target -or $Target -eq '.') { $Target = Read-Host 'Target repo path (blank = current dir)' }
  if (-not $Target) { $Target = '.' }
  $ScopeRoot = (Resolve-Path $Target).Path
  $GitIgnore = Join-Path $ScopeRoot '.gitignore'
  if ((Test-Path $GitIgnore) -and (Select-String -Path $GitIgnore -Pattern '^\s*\W*(claude|kiro|codex)/skills' -Quiet)) {
    Write-Host "  WARNING: $GitIgnore ignores a skills path — installed skills may stay invisible to some harnesses."
  }
} else {
  Write-Host 'Scope: global (home paths).'
}

# --- install -------------------------------------------------------------------

foreach ($name in $Chosen) {
  $H = $Harnesses | Where-Object { $_.n -eq $name }
  if (-not $H) { Write-Error "unknown harness '$name' (see -List)" }
  if ($Global) { Install-One $H 'global' '' } else { Install-One $H 'local' $ScopeRoot }
}

Write-Host ''
if ($Installed.Count -gt 0) {
  Write-Host 'Installed:'
  foreach ($p in $Installed) { Write-Host "  - $p" }
}
if ($Skipped.Count -gt 0) {
  Write-Host 'Skipped (existed, not overwritten):'
  foreach ($p in $Skipped) { Write-Host "  - $p" }
}
Write-Host ''
Write-Host 'Done. Restart your harness if a newly installed skill or dispatcher is not visible.'