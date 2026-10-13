---
description: "AgentsTemplate — vendor-neutral AGENTS.md schema (schema 1). Thin index per the split template; load sibling overlays only when the task touches their domain."
mode: primary
---

<!-- agents-template-schema 1 -->

# AGENTS.md

> Worked example of the universal `AGENTS.md` schema, version 1. Downstream projects copy `AGENTS-TEMPLATE.md` into their repository as `AGENTS.md` and replace the example content with their own; structure, ownership markers, and freshness stamps stay.

Heavy content lives in sibling files under `## Skill overlays`; load them only when the task touches that domain.

---

## Project

`AgentsTemplate` — a template repository that ships a workflow-neutral `AGENTS.md` schema usable across BMAD, GSD-core, openspec, impeccable, and any future workflow or skill overlay. No application code.

---

## Repo anatomy

Schema artifacts only; nothing is generated or rebuilt.

- `AGENTS.md` — this file, the worked example. Replace its content; keep its structure.
- `AGENTS-TEMPLATE.md` — the canonical split template: thin root + lazy-loaded `AGENTS.<TOPIC>.md` siblings.
- `AGENTS.WORKTREES.md` — this repo's own worktree policy (the split template in practice).
- `AGENTS-SPEC.md` — the authoritative reader contract; schema-versioned alongside the template.
- `agents-init/SKILL.md` — the canonical onboarding skill: detect brownfield/greenfield → interview gaps → write → verify conformance.
- `scripts/install.sh`, `scripts/install.ps1` — harness-detecting installers; never overwrite without confirmation.
- Vendor wrappers at the repo root (`.claude/`, `.opencode/`, `.codex/`, `.agents/`, `.cursor/`, `.gemini/`, `.agent/`, `.github/`) — thin dispatchers to the canonical skill. Full matrix: `AGENTS-SPEC.md` §Distribution.
- `AGENTS.md.bookingexperience-bak` — legacy archive from this directory's BMAD-managed era; delete once migration is confirmed.

---

## Build, test, and development commands

Depends on the project being developed or maintained.

---

## Policy

Mandatory Git worktree rules live in [`AGENTS.WORKTREES.md`](AGENTS.WORKTREES.md). **Load it before any commit, branch, or merge.** Headlines: all Git work happens in a worktree (`.worktrees/<task>/` on `feat/<task>`); the agent reports done; the human merges on `main`.

---

## Skill overlays

- **AGENTS.WORKTREES** — `AGENTS.WORKTREES.md`. Mandatory Git worktree rule (all Git work in a worktree; human merges on `main`). Load before any commit, branch, or merge.
- **agents-template** — `AGENTS-TEMPLATE.md` (the canonical split template), `AGENTS-SPEC.md` (the reader contract), `agents-init/SKILL.md` (the onboarding skill). Read all three before changing the schema or running onboarding. The spec wins on conflict. Vendor wrappers and the `scripts/` installers are how this overlay reaches the user's harness.

Downstream projects that adopt additional overlays list them here as pointers, e.g. `- **impeccable** — \`PRODUCT.md\`, \`DESIGN.md\`. Read both before any UI work.`

---

## Language conventions

None. Plain Markdown; downstream projects add a `### <Language>` subsection per language as needed.

---

## Conventions that differ from defaults

- No preprocessing, includes, or templating — the template is copied verbatim, not transpiled.
- Header line numbering in `AGENTS-SPEC.md` is intentional (sections are cited by number, e.g. `AGENTS-SPEC.md §5`); do not strip it.
- Workflow block markers (`<!-- owner:<code> -->`, `<!-- /owner -->`) are schema contract; do not rename or restyle them.
- Schema markers (`<!-- agents-template-schema N -->`) appear both in the first 20 lines and in the footer (agents that read partial files need both).

---

<!-- agents-template-schema 1 -->