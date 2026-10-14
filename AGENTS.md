---
agents-template-schema: 4
project: "AgentsTemplate"
description: "Vendor-neutral agent-instructions schema (schema 4) shipped as a skill collection; thin index per the split template; load sibling overlays only when the task touches their domain."
language: en
generated: 2026-10-13
mode: primary
---

# AGENTS.md

Worked example of the universal `AGENTS.md` schema, version 4. Downstream projects ship the same structure as the `split-agents-template` skill and install it into their harness's skills directory.

Heavy content lives in sibling files under `## Skill overlays`; load them only when the task touches their domain.

---

## Reader contract (minimal)

An agent reading this `AGENTS.md` alone (without `AGENTS-SPEC.md`) MUST:

1. Treat section content as binding for this repository — the agent obeys it.
2. Treat `## Skill overlays` as pointers to sibling files, read lazily when the task touches the overlay's domain.
3. Treat the `agents-template-schema` frontmatter key as the version this file conforms to. Unknown sections are ignored without error.

---

## Project

`AgentsTemplate` — a template repository that ships a workflow-neutral `AGENTS.md` schema usable across BMAD, GSD-core, openspec, impeccable, Kiro steering, and any future skill overlay. No application code.

---

## Repo anatomy

- `skill/split-agents-template/SKILL.md` — the canonical onboarding skill (Agent Skills standard).
- `skill/split-agents-template/assets/` — `AGENTS-SPEC.md` (the authoritative reader contract) and `AGENTS-TEMPLATE.md` (the split template the skill writes from).
- `AGENTS.WORKTREES.md` — this repo's own worktree policy, in split form.
- `scripts/install.sh`, `scripts/install.ps1` — installers; copy the skill folder to the harness the user selects.
- Vendor folders at the root (`.claude/`, `.opencode/`, `.codex/`, `.cursor/`, ...) — **generated, untracked** dispatcher output. Why: wrappers are build artifacts; the canonical skill lives once under `skill/`.

Nothing is generated or rebuilt; the artifacts are plain Markdown.

---

## Build, test, and development commands

There is no build, test suite, or dev server. Editing the Markdown is the entire development loop. Schema changes are validated against `AGENTS-SPEC.md` §Conformance.

---

## Policy

Mandatory Git worktree rules live in [`AGENTS.WORKTREES.md`](AGENTS.WORKTREES.md). **Load it before any commit, branch, or merge.** Headlines: all Git work happens in a worktree; the agent reports done; the human merges on `main`.

---

## Skill overlays

- **AGENTS.WORKTREES** — `AGENTS.WORKTREES.md`. Mandatory worktree rule. Load before any commit, branch, or merge.
- **agents-template** — `skill/split-agents-template/SKILL.md`, `skill/split-agents-template/assets/`. Read both assets before changing the schema or running onboarding; the spec (`assets/AGENTS-SPEC.md`) wins on conflict. Installers and vendor wrappers are how this overlay reaches the user's harness.

---

## Language conventions

None. Plain Markdown; downstream projects add a `### <Language>` subsection per language as needed.

---

## Conventions that differ from defaults

- No preprocessing, includes, or templating — the skill folder is copied verbatim, not transpiled.
- Header line numbering in `AGENTS-SPEC.md` is intentional (sections are cited by number, e.g. `AGENTS-SPEC.md §5`); do not strip it.
- Schema version is declared once in YAML frontmatter (`agents-template-schema: 4`); schema 1–3 forms are legacy input and are not written.