<!-- agents-template-schema 1 -->

# AGENTS.md

> Worked example of the universal `AGENTS.md` schema, version 1. This file is part of the [AgentsTemplate](https://github.com/) repository, which ships the template (`AGENTS-TEMPLATE.md`) and the authoritative reader contract (`AGENTS-SPEC.md`).
>
> Downstream projects copy `AGENTS-TEMPLATE.md` into their repository as `AGENTS.md` and replace the example content with their own. The structure, ownership markers, and freshness stamps stay; the prose changes.

---

## Reader contract (minimal)

An agent reading this `AGENTS.md` alone (without `AGENTS-SPEC.md`) MUST:

1. Treat sections without an `<!-- owner:... -->` comment as **project-owned**: their content is binding for this repository and the agent obeys it.
2. Treat sections marked `<!-- owner:<workflow> -->` as **workflow-owned**: the agent obeys the *non-empty* blocks for workflows it knows it is running. Empty blocks (between `<!-- owner:<workflow> -->` and `<!-- /owner -->` with no content) are inert.
3. Honor a freshness stamp (`<!-- verified YYYY-MM-DD against <sha> -->` or `<!-- approved YYYY-MM-DD -->`) on workflow blocks as a cache-invalidation signal. Orientation sections do not carry stamps.
4. Treat the `## Skill overlays` list as a set of pointers to sibling files. The agent reads those sibling files directly; it does not assume any overlay owns anything in `AGENTS.md`.
5. Treat the schema header (`<!-- agents-template-schema 1 -->`) as the version this file conforms to. Unknown section names do not error; the agent ignores them.

---

## Project

`AgentsTemplate` — a template repository that ships a workflow-neutral `AGENTS.md` schema usable across BMAD, GSD-core, openspec, impeccable, and any future workflow or skill overlay. The repository's only project is the schema itself; there is no application code.

---

## Repo anatomy

This repository contains only the schema artifacts. There is no source code, no build output, and no generated distribution.

- `AGENTS.md` — this file. The worked example, conforming to schema 1. Downstream projects replace its content; they keep its structure.
- `AGENTS-TEMPLATE.md` — the canonical template. New projects copy this file (under the name `AGENTS.md`) and fill in their own content. The template itself is not edited by downstream projects.
- `AGENTS-SPEC.md` — the authoritative reader contract. Defines how agents interpret any `AGENTS.md` written against this schema, the extension protocol for adding new workflows and overlays, and the conformance rules. Schema-versioned alongside the template.
- `agents-init/SKILL.md` — the canonical onboarding skill. Run it in a downstream project to scaffold or refresh that project's `AGENTS.md` against the schema. Detects brownfield vs. greenfield, interviews the user for gaps, writes a conformant file, and archives any previous `AGENTS.md`.
- `scripts/install.sh`, `scripts/install.ps1` — installers. Detect the user's installed agent harnesses and copy the right `agents-init` wrapper to the right location. Never overwrite without confirmation.
- Vendor wrappers at the repo root (`.claude/`, `.opencode/`, `.codex/`, `.agents/`, `.cursor/`, `.gemini/`, `.agent/`, `.github/`) — thin slash-command files and skill auto-discovery copies that make the canonical skill discoverable by the seven most popular agent harnesses. See `AGENTS-SPEC.md` §Distribution for the full vendor matrix.
- `AGENTS.md.bookingexperience-bak` — the previous `AGENTS.md` from when this directory hosted a real BMAD-managed project. Kept for reference; delete it once the migration is confirmed.
- `README.md` — short pointer to the schema artifacts.
- `LICENSE` — the license under which the schema artifacts are released.

Generated output: none. The repository ships only its source artifacts; there is nothing to rebuild.

---

## Build, test, and development commands

There is no build, no test suite, and no local development server. The artifacts are plain Markdown. Downstream projects replace this section with their toolchain.

- No build step. Editing the Markdown files is the entire development loop.
- No tests. Schema changes are validated by reading `AGENTS-SPEC.md`'s conformance section and by re-checking worked examples like this file.
- No linter. Keep Markdown consistent with the existing files (two-space list indentation, fenced code blocks with language hints, header levels step by one).

---

## Policy

_No project-level policy; see workflow blocks for ceremony._

The repository has no hard rules beyond what the workflow blocks (none active) and skill overlays (`AGENTS-TEMPLATE.md` and `AGENTS-SPEC.md`) enforce. Downstream projects add their own policy here when they copy the template.

---

## Workflow blocks

This repository does not run a planning or state workflow. All three workflow blocks are intentionally empty (inert) so a downstream project that copies this file as a starting point can populate whichever blocks its workflow needs without first removing the others.

### BMAD

<!-- owner:bmad -->
<!-- /owner -->

### GSD-core

<!-- owner:gsd -->
<!-- /owner -->

### openspec

<!-- owner:openspec -->
<!-- /owner -->

### Other workflows

To add a new workflow, append a new `### <Workflow name>` subsection here with an `<!-- owner:<workflow-code> --> ... <!-- /owner -->` block, and register the code in `AGENTS-SPEC.md` (see Extension protocol).

---

## Skill overlays

This repository uses one overlay: the agents-template overlay, which is the schema artifacts themselves plus the onboarding skill. They are sibling files and a sibling skill that any agent reading this `AGENTS.md` should consult before editing the schema, producing a downstream `AGENTS.md`, or running onboarding in a new repo.

- **agents-template** — `AGENTS-TEMPLATE.md` (the canonical template), `AGENTS-SPEC.md` (the reader contract), `agents-init/SKILL.md` (the onboarding skill). Read all three before changing the schema or running onboarding. Treat `AGENTS-SPEC.md` as authoritative when this example file and the spec disagree. The vendor wrappers at the repo root and the installers in `scripts/` are how this overlay reaches the user's harness.

Downstream projects that adopt additional overlays list them here as pointers. Example: a project using the impeccable design overlay would add a line of the form `- **impeccable** — \`PRODUCT.md\` (durable product truth), \`DESIGN.md\` (visual direction). Read both before any UI work.` See `AGENTS-TEMPLATE.md` for the full overlay-pointer pattern.

---

## Language conventions

None. The schema artifacts are plain Markdown with no language-specific tooling. Downstream projects add a `### <Language>` subsection per language they use.

---

## Conventions that differ from defaults

- Schema artifacts are plain Markdown. No preprocessing, no includes, no templating. The template is meant to be copied verbatim, not transpiled.
- Header line numbering in `AGENTS-SPEC.md` is intentional: it lets readers cite sections by number (`AGENTS-SPEC.md §5`). Do not strip the numbers.
- Workflow block markers (`<!-- owner:<code> -->`, `<!-- /owner -->`) are part of the schema contract. Do not rename them or fold them into a different comment style.
- The schema version marker (`<!-- agents-template-schema N -->`) appears in the first 20 lines and as a footer at the end of the file. Both occurrences are required for agents that read partial files.

---

<!-- agents-template-schema 1 -->
