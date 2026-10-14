# AgentsTemplate

A vendor-neutral `AGENTS.md` schema for AI coding agents, shipped as a **skill collection** — the onboarding skill installs verbatim into any harness's skills directory.

## Artifacts

| Path | Role |
| --- | --- |
| `skill/split-agents-template/SKILL.md` | The canonical onboarding skill (Agent Skills standard): Detect → Interview → Write → Verify, Kiro-style. |
| `skill/split-agents-template/assets/AGENTS-SPEC.md` | The authoritative reader contract: how agents interpret any `AGENTS.md` written against this schema, the extension protocol, and conformance rules. |
| `skill/split-agents-template/assets/AGENTS-TEMPLATE.md` | The canonical split template: thin root `AGENTS.md` plus lazily loaded `AGENTS.<TOPIC>.md` siblings. |
| `scripts/install.sh`, `scripts/install.ps1` | Installers: select the harness, copy the skill folder (project-local, committed — or global). |

## What it solves

Every AI coding harness (Claude Code, Cursor, Codex, Gemini CLI, Antigravity, Kiro, GitHub Copilot, OpenCode, Hermes, Pi, Qoder, Rovo Dev, Trae, Vibe, Veto, ...) reads a different `AGENTS.md` and discovers skills differently. The schema gives them a shared structure, so a project documents its workflow once and every supported agent follows it.

Concretely:

- **Skill collection layout** — canonical skills live at `skill/<name>/SKILL.md` with assets beside them; copy the folder into `.claude/skills/`, `.kiro/skills/`, `.cursor/skills/`, `.agents/skills/`, or the matching home path and it works.
- **Frontmatter versioning** — every generated file declares its schema version (`agents-template-schema: 4`); schema 1–3 HTML markers are legacy input.
- **Skill overlays** — pointers to sibling files an agent reads lazily when its task touches the overlay's domain; BMAD, GSD-core, openspec, impeccable integrate as overlays.
- **Kiro-style discipline** — schema 4 content rules: one domain per file, short binding statements, a *why* on every rule, no stub sections.
- **Kiro integration** — Kiro loads a proper `AGENTS.md` natively as always-on steering (CLI v2.18 / IDE 1.0.309+); the skill can optionally add an on-demand `.kiro/steering/` file with `inclusion: auto` + `#[[file:AGENTS.md]]`.
- **A conformance contract** — a short checklist any `AGENTS.md` must pass.

## Quick start for downstream projects

Install the skill into your harness's skills directory:

```bash
# From a clone of this repository:
git clone <repo> skill/split-agents-template   # or copy the skill/ folder
cp -r skill/split-agents-template ~/.claude/skills/        # global
cp -r skill/split-agents-template .claude/skills/          # project-local (commit it — do not gitignore; see AGENTS-SPEC.md §Distribution)
```

Or run `scripts/install.sh` / `scripts/install.ps1` to pick the harness interactively. Then, in your harness, invoke **split-agents-template** and follow the Detect → Interview → Write flow.

## Vendor wrappers

Vendor folders (`.claude/`, `.opencode/`, `.codex/`, `.cursor/`, `.gemini/`, `.agent/`, `.github/`, ...) are **generated installer output and excluded from this repository**. Each harness honors `.gitignore` (or its own ignore file: `.cursorignore`, `.kiroignore`) — the mechanism table and its caveats are in `AGENTS-SPEC.md` §Distribution.

## Schema version

The shipped artifacts conform to `agents-spec-schema 4` and `agents-template-schema 4`; the two version numbers move together — bumping either is a breaking change.

## License

See `LICENSE`.