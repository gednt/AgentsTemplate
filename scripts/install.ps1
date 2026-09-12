# scripts/install.ps1
# Detect installed agent harnesses and copy the right agents-init wrapper.
# Run from the repository root:  powershell -NoProfile -File .\scripts\install.ps1
#
# This script never overwrites an existing wrapper without confirmation.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$CanonicalSkill = Join-Path $RepoRoot 'agents-init/SKILL.md'

if (-not (Test-Path -LiteralPath $CanonicalSkill)) {
  Write-Error "Canonical skill not found at $CanonicalSkill"
  exit 1
}

$HomeDir = $env:HOME
if (-not $HomeDir) { $HomeDir = $env:USERPROFILE }

$Installed = New-Object System.Collections.Generic.List[string]

function Test-HarnessDir {
  param([string]$Path)
  if ($Path -and (Test-Path -LiteralPath $Path)) { return $true }
  return $false
}

# --- detections ------------------------------------------------------------

if (Test-HarnessDir (Join-Path $HomeDir '.claude'))                                 { $Installed.Add('claude-code') }
if (Test-HarnessDir (Join-Path $HomeDir '.opencode'))                                { $Installed.Add('opencode') }
if (Test-HarnessDir (Join-Path $HomeDir '.codex'))                                   { $Installed.Add('codex') }
if (Test-HarnessDir (Join-Path $HomeDir '.cursor'))                                  { $Installed.Add('cursor') }
if (Test-HarnessDir (Join-Path $HomeDir '.gemini'))                                  { $Installed.Add('gemini'); $Installed.Add('antigravity') }
if (Test-HarnessDir (Join-Path $HomeDir '.config/gh-copilot'))                       { $Installed.Add('github-copilot') }
if (Test-HarnessDir (Join-Path $HomeDir '.config/github-copilot'))                   { $Installed.Add('github-copilot') }
if (Test-HarnessDir (Join-Path $HomeDir '.hermes'))                                  { $Installed.Add('hermes') }
if (Test-HarnessDir (Join-Path $HomeDir '.kiro'))                                    { $Installed.Add('kiro') }
if (Test-HarnessDir (Join-Path $HomeDir '.pi'))                                      { $Installed.Add('pi') }
if (Test-HarnessDir (Join-Path $HomeDir '.qoder'))                                   { $Installed.Add('qoder') }
if (Test-HarnessDir (Join-Path $HomeDir '.rovodev'))                                 { $Installed.Add('rovodev') }
if (Test-HarnessDir (Join-Path $HomeDir '.trae'))                                    { $Installed.Add('trae') }
if (Test-HarnessDir (Join-Path $HomeDir '.trae-cn'))                                 { $Installed.Add('trae-cn') }
if (Test-HarnessDir (Join-Path $HomeDir '.vibe'))                                    { $Installed.Add('vibe') }
if (Test-HarnessDir (Join-Path $HomeDir '.dsh'))                                     { $Installed.Add('deepseek') }
if (Test-HarnessDir (Join-Path $HomeDir '.veto'))                                    { $Installed.Add('veto') }

# --- summary ---------------------------------------------------------------

if ($Installed.Count -eq 0) {
  Write-Host "No agent harnesses detected in $HomeDir."
  Write-Host "If your harness is missing, file an issue or copy a wrapper from"
  Write-Host "AGENTS-SPEC.md (Distribution) manually."
  exit 0
}

Write-Host 'Detected harnesses:'
foreach ($h in $Installed) { Write-Host "  - $h" }
Write-Host ''

# --- helpers ---------------------------------------------------------------

function Confirm-Overwrite {
  param([string]$Target)
  if (Test-Path -LiteralPath $Target) {
    $ans = Read-Host "  $Target exists. Overwrite? [y/N]"
    if ($ans -notin @('y', 'Y')) { return $false }
  }
  return $true
}

function Copy-Wrapper {
  param([string]$Source, [string]$Dest)
  $destDir = Split-Path -Parent $Dest
  if (-not (Test-Path -LiteralPath $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  }
  Copy-Item -LiteralPath $Source -Destination $Dest -Force
  Write-Host "  installed: $Dest"
}

# --- install ---------------------------------------------------------------

foreach ($harness in $Installed) {
  switch ($harness) {
    'claude-code' {
      $src = Join-Path $RepoRoot '.claude/commands/agents-init.md'
      $dest = Join-Path $RepoRoot '.claude/commands/agents-init.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'opencode' {
      $src = Join-Path $RepoRoot '.opencode/command/agents-init.md'
      $dest = Join-Path $RepoRoot '.opencode/command/agents-init.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'codex' {
      $src1 = Join-Path $RepoRoot '.codex/prompts/agents-init.md'
      $dest1 = Join-Path $RepoRoot '.codex/prompts/agents-init.md'
      if (Confirm-Overwrite $dest1) { Copy-Wrapper $src1 $dest1 }
      $src2 = Join-Path $RepoRoot '.agents/skills/agents-init/SKILL.md'
      $dest2 = Join-Path $RepoRoot '.agents/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest2) { Copy-Wrapper $src2 $dest2 }
    }
    'cursor' {
      $src = Join-Path $RepoRoot '.cursor/commands/agents-init.md'
      $dest = Join-Path $RepoRoot '.cursor/commands/agents-init.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'gemini' {
      $src = Join-Path $RepoRoot '.gemini/commands/agents-init.toml'
      $dest = Join-Path $RepoRoot '.gemini/commands/agents-init.toml'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'antigravity' {
      $src = Join-Path $RepoRoot '.agent/skills/agents-init/SKILL.md'
      $dest = Join-Path $RepoRoot '.agent/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'github-copilot' {
      $src = Join-Path $RepoRoot '.github/prompts/agents-init.prompt.md'
      $dest = Join-Path $RepoRoot '.github/prompts/agents-init.prompt.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'hermes' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.hermes/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
      Write-Host '  note: run ''hermes skills trust'' once in this project to allow auto-load.'
    }
    'kiro' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.kiro/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'pi' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.pi/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'qoder' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.qoder/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'rovodev' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.rovodev/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'trae' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.trae/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'trae-cn' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.trae-cn/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'vibe' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.vibe/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'deepseek' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.dsh/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
    }
    'veto' {
      $src = $CanonicalSkill
      $dest = Join-Path $HomeDir '.veto/skills/agents-init/SKILL.md'
      if (Confirm-Overwrite $dest) { Copy-Wrapper $src $dest }
      Write-Host '  note: Veto discourages project-local installs; installed to home directory.'
    }
  }
}

Write-Host ''
Write-Host 'Done. Restart your harness if a newly installed wrapper is not visible.'
