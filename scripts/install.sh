#!/usr/bin/env bash
# scripts/install.sh — install the split-agents-template skill into your agent harness.
#
# The skill folder (skill/split-agents-template/) is copied verbatim, Agent Skills standard.
# Flat-file slash-command dispatchers are generated for harnesses that use them.
#
# Usage:
#   ./scripts/install.sh                                   interactive harness selection
#   ./scripts/install.sh --list                            list supported harnesses (* = detected)
#   ./scripts/install.sh --harness kiro,claude-code        non-interactive install
#   ./scripts/install.sh --target <repo>                   project-local target repo (default prompts; "." = this repo)
#   ./scripts/install.sh --global                          install to home paths instead of project-local
#
# Never overwrites an existing destination without confirmation. Prints a summary at the end.
#
# Harness tuple: name|local_skills|global_skills|slash_path|detect dirs (space-separated)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$HERE/skill/split-agents-template"
[[ -f "$SKILL_DIR/SKILL.md" ]] || { echo "error: $SKILL_DIR/SKILL.md not found — install this skill folder intact" >&2; exit 1; }

HID="split-agents-template"

HARNESSES=(
  "claude-code|.claude/skills|$HOME/.claude/skills|.claude/commands/$HID.md|$HOME/.claude"
  "opencode||$HOME/.opencode/skills|.opencode/command/$HID.md|$HOME/.opencode $HOME/.config/opencode"
  "codex|.agents/skills|$HOME/.codex/skills|.codex/prompts/$HID.md|$HOME/.codex"
  "cursor|.cursor/skills|$HOME/.cursor/skills|.cursor/commands/$HID.md|$HOME/.cursor"
  "gemini||$HOME/.gemini/skills|.gemini/commands/$HID.toml|$HOME/.gemini"
  "antigravity|.agent/skills|$HOME/.agent/skills||$HOME/.agent $HOME/.gemini"
  "github-copilot||$HOME/.agents/skills|.github/prompts/$HID.prompt.md|$HOME/.config/gh-copilot $HOME/.config/github-copilot"
  "hermes|.hermes/skills|$HOME/.hermes/skills||$HOME/.hermes"
  "kiro|.kiro/skills|$HOME/.kiro/skills||$HOME/.kiro"
  "pi|.pi/skills|$HOME/.pi/skills||$HOME/.pi"
  "qoder|.qoder/skills|$HOME/.qoder/skills||$HOME/.qoder"
  "rovodev|.rovodev/skills|$HOME/.rovodev/skills||$HOME/.rovodev"
  "trae|.trae/skills|$HOME/.trae/skills||$HOME/.trae"
  "trae-cn|.trae-cn/skills|$HOME/.trae-cn/skills||$HOME/.trae-cn"
  "vibe|.vibe/skills|$HOME/.vibe/skills||$HOME/.vibe"
  "deepseek|.dsh/skills|$HOME/.dsh/skills||$HOME/.dsh"
  "veto||$HOME/.veto/skills||$HOME/.veto"
)

INSTALLED=() SKIPPED=()

fields() { IFS='|' read -r NAME LOCAL_SKILLS GLOBAL_SKILLS SLASH_PATH DETECT <<< "$1"; }

detect() {
  for d in $DETECT; do [[ -d "$d" ]] && return 0; done
  return 1
}

confirm_path() {
  local dest="$1"
  [[ -e "$dest" ]] || return 0
  read -r -p "  $dest exists. Overwrite? [y/N] " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]]
}

# write_dispatcher_file PATH SKILL_REF — md or TOML by extension
write_dispatcher_file() {
  local sp="$1" ref="$2"
  mkdir -p "$(dirname "$sp")"
  if [[ "$sp" == *.toml ]]; then
    cat > "$sp" <<EOF
name = "$HID"
description = "Scaffold or refresh a project's AGENTS.md against agents-template-schema 4 (Kiro-style: one domain per file, concise, why on every rule)."

prompt = """
Run the installed $HID skill. Full procedure: $ref

This dispatcher is thin; do not duplicate the procedure here.
"""
EOF
  else
    cat > "$sp" <<EOF
---
name: $HID
description: "Scaffold or refresh a project's AGENTS.md against agents-template-schema 4 (Kiro-style: one domain per file, concise, why on every rule). Use to set up, refresh, or migrate AGENTS.md."
---

Run the installed $HID skill. Full procedure: \`$ref\`

This dispatcher is thin; do not duplicate the procedure here.
EOF
  fi
}

# install_one NAME SCOPE TARGET_ROOT   (SCOPE: local|global; TARGET_ROOT for local; empty for global)
install_one() {
  local scope="$2" target_root="$3" sp dest
  fields "$1"

  if [[ "$scope" == "global" ]]; then
    dest="$GLOBAL_SKILLS/$HID"
  elif [[ -n "$LOCAL_SKILLS" ]]; then
    dest="$target_root/$LOCAL_SKILLS/$HID"
  elif [[ -n "$GLOBAL_SKILLS" ]]; then
    echo "  note: $NAME has no project-local skills dir; skill installs globally, dispatcher goes local."
    install_one "$1" global ""
    if [[ -n "$SLASH_PATH" ]]; then
      sp="$target_root/$SLASH_PATH"
      if confirm_path "$sp"; then
        write_dispatcher_file "$sp" "$GLOBAL_SKILLS/$HID/SKILL.md"
        INSTALLED+=("$sp"); echo "  installed: $sp"
      else
        SKIPPED+=("$sp")
      fi
    fi
    if [[ "$NAME" == "hermes" ]]; then echo "  note: run 'hermes skills trust' once in this project to allow auto-load."; fi
    return 0
  else
    echo "  note: $NAME has no skills path; skipped entirely."
    SKIPPED+=("$NAME (no skills path)"); return
  fi
  local ref="$dest/SKILL.md"

  if confirm_path "$ref"; then
    mkdir -p "$dest"; cp -r "$SKILL_DIR/." "$dest/"
    INSTALLED+=("$dest"); echo "  installed: $dest"
  else
    SKIPPED+=("$ref"); echo "  skipped: $ref"
  fi

  # 2) flat-file dispatcher (project-local only)
  if [[ -n "$SLASH_PATH" && "$scope" == "local" ]]; then
    sp="$target_root/$SLASH_PATH"
    if confirm_path "$sp"; then
      write_dispatcher_file "$sp" "$ref"
      INSTALLED+=("$sp"); echo "  installed: $sp"
    else
      SKIPPED+=("$sp")
    fi
  fi

  if [[ "$NAME" == "hermes" ]]; then echo "  note: run 'hermes skills trust' once in this project to allow auto-load."; fi
  if [[ "$NAME" == "veto" ]]; then echo "  note: Veto discourages project-local installs; installed to the home path."; fi
}

# --- flags -------------------------------------------------------------------

LIST=0; GLOBAL=0; PICK=""; TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list|-l)                 LIST=1; shift ;;
    --harness|-h)              PICK="${2:?--harness needs a value}"; shift 2 ;;
    --target|-t)               TARGET="${2:?--target needs a value}"; shift 2 ;;
    --global|-g)               GLOBAL=1; shift ;;
    --help)                    sed -n '3,15p' "$0"; exit 0 ;;
    *) echo "unknown flag: $1 (see --help)" >&2; exit 1 ;;
  esac
done

list_menu() {
  echo "Supported harnesses (* = detected on this machine):"
  local i=0
  for row in "${HARNESSES[@]}"; do
    fields "$row"; i=$((i+1)); detect && mark=" *" || mark=""
    printf '  %2d. %-15s%s\n' "$i" "$NAME" "$mark"
  done
}

if [[ "$LIST" == "1" ]]; then list_menu; exit 0; fi

# --- select ------------------------------------------------------------------

if [[ -z "$PICK" ]]; then
  list_menu; echo
  read -r -p "Select by number (comma-separated), 'a' for all detected, or 'all': " PICK
fi

if [[ "$PICK" == "a" || "$PICK" == "A" || "$PICK" == "all" ]]; then
  PICK=""
  for row in "${HARNESSES[@]}"; do fields "$row"; detect && PICK="${PICK:+$PICK,}$NAME"; done
fi

# --- scope -------------------------------------------------------------------

if [[ "$GLOBAL" == "1" ]]; then
  echo "Scope: global (home paths)."
  TARGET=""
else
  echo "Scope: project-local. Skills are source for agents: COMMIT the installed folder, do not gitignore it"
  echo "(Codex, Antigravity, and Kiro honor ignore rules and will not see ignored skills)."
  if [[ -z "$TARGET" ]]; then
    read -r -p "Target repo path (blank = current dir): " TARGET
    TARGET="${TARGET:-.}"
  fi
  if command -v cygpath >/dev/null 2>&1 && [[ "$TARGET" =~ ^[A-Za-z]: ]]; then
    TARGET="$(cygpath -u "$TARGET")"
  fi
  if [[ ! -d "$TARGET" ]]; then
    echo "error: target repo not found: $TARGET" >&2
    exit 1
  fi
  TARGET="$(cd "$TARGET" && pwd)"
  if grep -qiE '^\s*(\.|/)?(claude|kiro|codex|agents)/skills' "$TARGET/.gitignore" 2>/dev/null; then
    echo "  WARNING: $TARGET/.gitignore ignores a skills path — installed skills may stay invisible to some harnesses."
  fi
fi

# --- install -------------------------------------------------------------------

IFS=',' read -r -a CHOSEN <<< "$PICK"
for c in "${CHOSEN[@]}"; do
  c="${c//[[:space:]]/}"
  row=""
  if [[ "$c" =~ ^[0-9]+$ ]]; then
    idx=$((c-1))
    if [[ $idx -lt 0 || $idx -ge ${#HARNESSES[@]} ]]; then
      echo "error: number out of range: $c (see --list)" >&2; exit 1
    fi
    row="${HARNESSES[$idx]}"
  else
    for r in "${HARNESSES[@]}"; do
      fields "$r"
      if [[ "$NAME" == "$c" ]]; then row="$r"; break; fi
    done
    if [[ -z "$row" ]]; then
      echo "error: unknown harness '$c' (see --list)" >&2; exit 1
    fi
  fi
  if [[ "$GLOBAL" == "1" ]]; then install_one "$row" global ""; else install_one "$row" local "$TARGET"; fi
done

echo
if [[ ${#INSTALLED[@]} -gt 0 ]]; then
  echo "Installed:"; printf '  - %s\n' "${INSTALLED[@]}"
fi
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo "Skipped (existed, not overwritten):"; printf '  - %s\n' "${SKIPPED[@]}"
fi
echo
echo "Done. Restart your harness if a newly installed skill or dispatcher is not visible."