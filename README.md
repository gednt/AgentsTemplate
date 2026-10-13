# AgentsTemplate

A vendor-neutral `AGENTS.md` schema for AI coding agents, plus the onboarding skill that scaffolds it in any project.

This repository ships three artifacts:

| File | Role |
| --- | --- |
| `AGENTS-SPEC.md` | The authoritative reader contract. Defines how agents interpret any `AGENTS.md` written against this schema, the extension protocol for new workflows and overlays, and the conformance rules. |
| `AGENTS-TEMPLATE.md` | The canonical template (split edition): a thin root `AGENTS.md` plus heavy sibling `AGENTS.<TOPIC>.md` overlays (policy, stack, worktrees) loaded lazily. Downstream projects copy the root as `AGENTS.md` and create the siblings they earn. |
| `agents-init/SKILL.md` | The canonical onboarding skill. Run it in a downstream project to scaffold or refresh that project's `AGENTS.md`. |

## What it solves

Every AI coding harness (Claude Code, Cursor, Codex, Gemini CLI, Antigravity, GitHub Copilot, OpenCode, Hermes, Kiro, Pi, Qoder, Rovo Dev, Trae, Vibe, Mistral Vibe, Veto, ...) reads a different `AGENTS.md` and a different skill convention. The schema here gives those harnesses a shared structure to obey, so a project can document its workflow once and have every supported agent follow it.

Concretely the schema introduces:

- **Workflow blocks** — `<!-- owner:bmad --> ... <!-- /owner -->` regions that a workflow owns and that the agent obeys only if it runs that workflow.
- **Skill overlays** — pointers to sibling files (e.g. `PRODUCT.md`, `DESIGN.md`) that an agent reads lazily when its task touches the overlay's domain.
- **Freshness stamps** — `<!-- verified YYYY-MM-DD against <sha> -->` and `<!-- approved YYYY-MM-DD -->` markers that let an agent detect stale workflow context without erroring.
- **A conformance contract** — five checks that any `AGENTS.md` must pass to be called conformant.

## Quick start for downstream projects

```bash
# Scaffold or refresh an AGENTS.md in the current repository.
# Reads the repo, asks about gaps, archives any existing AGENTS.md, and writes a conformant one.
# The exact invocation depends on your harness; the canonical body is agents-init/SKILL.md.
```

See `agents-init/SKILL.md` for the full Detect → Interview → Write flow and the archive convention (`AGENTS.md.<slug>.bak`).

## Installing the skill in your harness

The `agents-init` skill body lives once. Vendor wrappers at the repo root make it discoverable to each harness; `scripts/install.sh` and `scripts/install.ps1` detect which harness you have installed and copy the right wrapper.

Priority wrappers shipped here:

- Claude Code, OpenCode, Codex (slash + skill), Cursor (slash), Gemini CLI, Antigravity, GitHub Copilot.

Other supported vendors (Hermes, Kiro, Pi, Qoder, Rovo Dev, Trae, Trae-CN, Vibe, Mistral Vibe, Veto) are added by the installer when it detects their home-directory markers.

The installer never overwrites an existing wrapper without confirmation and prints a summary of what it installed or skipped.

## Schema version

The shipped artifacts conform to `agents-spec-schema 1.3` and `agents-template-schema 1`. The two version numbers move together: bumping either is a breaking change to the contract.

## License

See `LICENSE`.