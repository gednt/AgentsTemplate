#!/usr/bin/env bash
# scripts/install.sh
# Detect installed agent harnesses and copy the right agents-init wrapper.
# Run from the repository root:  ./scripts/install.sh
#
# This script never overwrites an existing wrapper without confirmation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL_SKILL="$REPO_ROOT/agents-init/SKILL.md"

if [[ ! -f "$CANONICAL_SKILL" ]]; then
  echo "error: canonical skill not found at $CANONICAL_SKILL" >&2
  exit 1
fi

HOME_DIR="${HOME:-}"
INSTALLED=()
SKIPPED=()

# --- helpers ---------------------------------------------------------------

confirm_overwrite() {
  local target="$1"
  if [[ -e "$target" ]]; then
    local ans
    read -r -p "  $target exists. Overwrite? [y/N] " ans
    [[ "$ans" == "y" || "$ans" == "Y" ]] || return 1
  fi
  return 0
}

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  installed: $dest"
}

# --- detections ------------------------------------------------------------

# Claude Code: ~/.claude/
if [[ -d "$HOME_DIR/.claude" ]]; then
  INSTALLED+=("claude-code")
fi

# OpenCode: ~/.opencode/ or ~/.config/opencode/
if [[ -d "$HOME_DIR/.opencode" || -d "$HOME_DIR/.config/opencode" ]]; then
  INSTALLED+=("opencode")
fi

# Codex CLI: ~/.codex/
if [[ -d "$HOME_DIR/.codex" ]]; then
  INSTALLED+=("codex")
fi

# Cursor: ~/.cursor/
if [[ -d "$HOME_DIR/.cursor" ]]; then
  INSTALLED+=("cursor")
fi

# Gemini CLI: ~/.gemini/
if [[ -d "$HOME_DIR/.gemini" ]]; then
  INSTALLED+=("gemini")
fi

# Google Antigravity: ~/.gemini/config/ (the harness's config dir is ~/.gemini)
# or the explicit ~/.config/gemini/. Antigravity's project-local path is
# .agent/skills/, singular. We treat ~/.gemini as a sufficient signal.
if [[ -d "$HOME_DIR/.gemini" ]]; then
  INSTALLED+=("antigravity")
fi

# GitHub Copilot: ~/.config/gh-copilot/ or ~/.config/github-copilot/
if [[ -d "$HOME_DIR/.config/gh-copilot" || -d "$HOME_DIR/.config/github-copilot" ]]; then
  INSTALLED+=("github-copilot")
fi

# Hermes: ~/.hermes/
if [[ -d "$HOME_DIR/.hermes" ]]; then
  INSTALLED+=("hermes")
fi

# Kiro: ~/.kiro/
if [[ -d "$HOME_DIR/.kiro" ]]; then
  INSTALLED+=("kiro")
fi

# Pi: ~/.pi/
if [[ -d "$HOME_DIR/.pi" ]]; then
  INSTALLED+=("pi")
fi

# Qoder: ~/.qoder/
if [[ -d "$HOME_DIR/.qoder" ]]; then
  INSTALLED+=("qoder")
fi

# Rovo Dev: ~/.rovodev/
if [[ -d "$HOME_DIR/.rovodev" ]]; then
  INSTALLED+=("rovodev")
fi

# Trae: ~/.trae/ or ~/.trae-cn/
if [[ -d "$HOME_DIR/.trae" ]]; then
  INSTALLED+=("trae")
fi
if [[ -d "$HOME_DIR/.trae-cn" ]]; then
  INSTALLED+=("trae-cn")
fi

# Mistral Vibe: ~/.vibe/
if [[ -d "$HOME_DIR/.vibe" ]]; then
  INSTALLED+=("vibe")
fi

# DeepSeek Harness: ~/.dsh/
if [[ -d "$HOME_DIR/.dsh" ]]; then
  INSTALLED+=("deepseek")
fi

# Veto: ~/.veto/ (global only)
if [[ -d "$HOME_DIR/.veto" ]]; then
  INSTALLED+=("veto")
fi

# --- summary ---------------------------------------------------------------

if [[ ${#INSTALLED[@]} -eq 0 ]]; then
  echo "No agent harnesses detected in $HOME_DIR."
  echo "If your harness is missing, file an issue or copy a wrapper from"
  echo "AGENTS-SPEC.md §Distribution manually."
  exit 0
fi

echo "Detected harnesses:"
printf '  - %s\n' "${INSTALLED[@]}"
echo

# --- install ---------------------------------------------------------------

# In-repo vendor folders are the default for project-local harnesses.
# Global-only harnesses (Veto) install to the home directory.

for harness in "${INSTALLED[@]}"; do
  case "$harness" in
    claude-code)
      src="$REPO_ROOT/.claude/commands/agents-init.md"
      dest="$REPO_ROOT/.claude/commands/agents-init.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    opencode)
      src="$REPO_ROOT/.opencode/command/agents-init.md"
      dest="$REPO_ROOT/.opencode/command/agents-init.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    codex)
      src="$REPO_ROOT/.codex/prompts/agents-init.md"
      dest="$REPO_ROOT/.codex/prompts/agents-init.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      src2="$REPO_ROOT/.agents/skills/agents-init/SKILL.md"
      dest2="$REPO_ROOT/.agents/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest2"; then copy_file "$src2" "$dest2"; fi
      ;;
    cursor)
      src="$REPO_ROOT/.cursor/commands/agents-init.md"
      dest="$REPO_ROOT/.cursor/commands/agents-init.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    gemini)
      src="$REPO_ROOT/.gemini/commands/agents-init.toml"
      dest="$REPO_ROOT/.gemini/commands/agents-init.toml"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    antigravity)
      src="$REPO_ROOT/.agent/skills/agents-init/SKILL.md"
      dest="$REPO_ROOT/.agent/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    github-copilot)
      src="$REPO_ROOT/.github/prompts/agents-init.prompt.md"
      dest="$REPO_ROOT/.github/prompts/agents-init.prompt.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    hermes)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.hermes/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      echo "  note: run 'hermes skills trust' once in this project to allow auto-load."
      ;;
    kiro)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.kiro/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    pi)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.pi/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    qoder)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.qoder/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    rovodev)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.rovodev/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    trae)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.trae/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    trae-cn)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.trae-cn/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    vibe)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.vibe/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    deepseek)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.dsh/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      ;;
    veto)
      src="$REPO_ROOT/agents-init/SKILL.md"
      dest="$HOME_DIR/.veto/skills/agents-init/SKILL.md"
      if confirm_overwrite "$dest"; then copy_file "$src" "$dest"; fi
      echo "  note: Veto discourages project-local installs; installed to home directory."
      ;;
  esac
done

echo
echo "Done. Restart your harness if a newly installed wrapper is not visible."
