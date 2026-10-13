<!-- agents-spec-schema 2 -->

# AGENTS-SPEC.md — Reader Contract for `AGENTS.md` (v2)

> The authoritative specification for how agents read and obey `AGENTS.md` files written against the `agents-template-schema` family. The template (`AGENTS-TEMPLATE.md`) and any `AGENTS.md` written from it MUST conform to this spec. When the two conflict, this spec wins.

## Table of contents

1. [Scope](#scope)
2. [Terminology](#terminology)
3. [Schema versioning](#schema-versioning)
4. [Sections and ownership](#sections-and-ownership)
5. [Skill overlays](#skill-overlays)
6. [Onboarding](#onboarding)
7. [Distribution](#distribution)
8. [Freshness stamps](#freshness-stamps)
9. [Reader algorithm](#reader-algorithm)
10. [Extension protocol](#extension-protocol)
11. [Conformance](#conformance)
12. [Change history](#change-history)

---

## Scope

This spec governs:

- `AGENTS.md` files written against `agents-template-schema 2` (or later).
- `AGENTS-TEMPLATE.md`, the canonical template that produces conforming `AGENTS.md` files.
- Any agent that reads a conforming `AGENTS.md`, regardless of which tool or overlay produced or consumes the file.

This spec does **not** govern:

- The internal structure of overlay-owned artifacts (`_bmad-output/`, `.planning/`, `openspec/changes/`, `.impeccable/`, etc.). Those are owned by their tools.
- The internal structure of skill-overlay sibling files (`PRODUCT.md`, `DESIGN.md`, `AGENTS.<TOPIC>.md` content beyond the conventions below). Those are owned by their overlays.
- The content of `AGENTS.md` sections — only their structure and interpretation.

---

## Terminology

- **Agent** — any AI tool that reads `AGENTS.md` to inform its behavior in a repository (Claude Code, Cursor, Codex, GitHub Copilot, Gemini CLI, OpenCode, Hermes, Kiro, and custom harnesses).
- **Project** — the repository whose `AGENTS.md` is being read.
- **Skill overlay** — any adopted tool, workflow, or convention system that adds capabilities without owning anything inside `AGENTS.md`. Examples: impeccable (design), BMAD / GSD-core / openspec (planning workflows), formatters, linters.
- **Sibling specification file** — a project-owned file at the repo root, named `AGENTS.<TOPIC>.md`, that carries the depth for one domain of `AGENTS.md`.
- **Freshness stamp** — an HTML comment that records when a sibling file was last verified against a known-good reference.

---

## Schema versioning

Every conforming `AGENTS.md` carries a header comment of the form:

```html
<!-- agents-template-schema <N> -->
```

where `<N>` is a positive integer. The header MUST appear:

1. Within the first 20 lines of the file (so an agent discovers it on a cheap prefix read).
2. Also as a footer comment at the very end of the file, so a partial-read agent that scrolls from the bottom still detects it.

The footer is redundant by design: it guards against agent harnesses that truncate large files.

A new minor version (e.g., `2.1`) adds sections or markers in a backward-compatible way. A new major version (e.g., `3`) may rename or repurpose sections and is **not** backward-compatible.

---

## Sections and ownership

An `AGENTS.md` written against schema 2 carries the following sections, in order. Sections MAY be omitted; sections in **bold** are recommended.

1. **Reader contract (minimal)** — restated at the top of `AGENTS.md` so the file is interpretable without this spec. MUST be present if `AGENTS-SPEC.md` is absent.
2. **Project** — one-line description, domain, users.
3. **Repo anatomy** — orientation, top-level layout.
4. **Build, test, and development commands** — orientation, canonical commands.
5. **Policy** — hard rules as headlines; depth in `AGENTS.POLICY.md` siblings. Optional; may be a one-line placeholder.
6. **Skill overlays** — pointer list to sibling files.
7. **Language conventions** — per-language style overrides; one-line pointer or short subsections.
8. **Conventions that differ from defaults** — catch-all for project-wide conventions.

Schema 2 has **no workflow-block machinery**. Ownership is binary:

- A section not pointed to from `## Skill overlays` is **project-owned**. The agent obeys it as policy for this repository.
- Everything named in `## Skill overlays` is an overlay: a pointer to one or more sibling files the agent reads lazily. No overlay owns any block or section of `AGENTS.md`.
- Adopted workflows (BMAD, GSD-core, openspec, ...) are overlays. They record their state in their own artifact directories and are registered as pointer lines under `## Skill overlays`.

Section names are case-insensitive but conventionally Title Case (`## Policy`, not `## policy`). An agent encountering an unknown section name ignores it without error.

---

## Skill overlays

A skill overlay is listed in `AGENTS.md` under `## Skill overlays` as a pointer:

```markdown
- **<overlay name>** — `<path/to/sibling/file>`. <one-line role + load trigger>.
```

Sibling `AGENTS.<TOPIC>.md` specification files (the split template's own output) are listed the same way, with the dotted file name as the pointer label.

An overlay may also ship one or more **skills** (executable onboarding, refresh, or maintenance procedures). A skill is identified by its directory under the overlay (e.g., `agents-init/`) and is named in the overlay's pointer with a brief description of when to invoke it.

Rules:

- The overlay's pointers MUST resolve to existing files or directories relative to the repository root.
- The agent reads the sibling file(s) directly when its tasks touch the overlay's domain (e.g., impeccable's `PRODUCT.md` and `DESIGN.md` are read before any UI work; `AGENTS.POLICY.md` is read before any non-trivial change).
- The overlay MAY write files under a project-local subdirectory (e.g., `.impeccable/`, `.planning/`) without touching `AGENTS.md`.
- An overlay that ships skills MUST document the skill's name, invocation, and preconditions in the pointer line so an agent knows when to run it.

### Supported overlays

| Name             | Pointer(s)                                                  | Read / invoke when                       |
| ---------------- | ----------------------------------------------------------- | ---------------------------------------- |
| `agents-template` | `AGENTS-TEMPLATE.md`, `AGENTS-SPEC.md`, `agents-init/SKILL.md` | Editing the schema or onboarding a project (read template + spec; run `agents-init` to scaffold). The canonical template ships as a split set: thin root `AGENTS.md` plus heavy, lazily loaded sibling `AGENTS.<TOPIC>.md` overlays |
| `impeccable`     | `PRODUCT.md`, `DESIGN.md`                                   | Any UI/design work                       |

---

## Onboarding

A downstream project that adopts the schema writes a conformant `AGENTS.md` by running an **onboarding skill** shipped by the agents-template overlay. The canonical onboarding skill is `agents-init`. The contract between the onboarding skill and the schema is:

- The onboarding skill reads `AGENTS-TEMPLATE.md` and replaces its placeholders with project-specific content. It MUST NOT modify the schema header/footer or the `## Reader contract (minimal)` section.
- The onboarding skill is **non-destructive**: it MUST archive any existing `AGENTS.md` to `AGENTS.md.<suffix>.bak` before overwriting. The suffix is the project slug (preferred) or a date stamp (fallback).
- The onboarding skill MUST verify conformance against §Conformance before declaring success. If any check fails, the skill aborts and surfaces the failed checks; it does not write a non-conformant file.
- The onboarding skill may create the project's own `AGENTS.<TOPIC>.md` sibling specification files (the split template is canonical for this). It MUST NOT write other overlays' artifacts (`_bmad-output/`, `.planning/`, `openspec/changes/`); those are the overlays' own onboarding skills' jobs.
- An adopted workflow is registered as an overlay pointer; the user is told to run the workflow's own onboarding skill if it ships one.
- The onboarding skill is idempotent: re-running it on a project with a conformant `AGENTS.md` is allowed and offers *refresh in place* (default) or *archive and rewrite*.

A project may ship its own onboarding skill under its own overlay. Such a skill MUST honor the same contract. Register the skill in the Supported overlays table by extending the `agents-template` row or adding a new overlay row.

---

## Distribution

A skill that conforms to this spec is **inert** until a harness can find it. Each agent harness scans one or more vendor-specific directories at the repo root (or under the user's home directory) for skill and slash-command definitions. The canonical skill body lives in a single place; vendor-specific entries are thin wrappers that point at it.

### Canonical skill location

A skill body MUST live in a single file whose path is documented in the overlay's pointer in `AGENTS.md`. The agents-template overlay's canonical skill is `agents-init/SKILL.md`. All vendor-specific wrappers dispatch to this file.

### Vendor wrapper shapes

Two shapes are in use across the supported harnesses:

- **Flat-file slash command** — a single file with frontmatter that the harness registers as a slash command. Body is short: frontmatter + a pointer to the canonical skill. Used by Claude Code, OpenCode, Codex (prompts), Cursor, Gemini CLI, GitHub Copilot.
- **Directory-with-`SKILL.md` skill** — a directory containing a `SKILL.md` (and optionally other files) that the harness auto-discovers. Body is the full skill. Used by Antigravity, Codex (skills), Hermes, Kiro, Pi, Qoder, Rovo Dev, Trae, Trae-CN, Vibe, DeepSeek Harness, Mistral Vibe.

A wrapper MUST be a copy of the canonical skill (for directory-with-`SKILL.md` shapes) or a thin dispatcher (for flat-file slash commands). Wrappers MUST NOT silently modify the canonical skill body.

### Vendor matrix

| Harness            | Wrapper path (project-local)                       | Shape                          | Notes                                                                              |
| ------------------ | --------------------------------------------------- | ------------------------------ | ---------------------------------------------------------------------------------- |
| Claude Code        | `.claude/commands/agents-init.md`                   | Flat-file slash command        | Anthropic's flagship harness.                                                       |
| OpenCode           | `.opencode/command/agents-init.md`                  | Flat-file slash command        | Singular `command/`.                                                                |
| Codex (slash)      | `.codex/prompts/agents-init.md`                     | Flat-file slash command        | Codex also has a skills system; both are supported.                                 |
| Codex (skill)      | `.agents/skills/agents-init/SKILL.md`               | Directory-with-`SKILL.md`       | Plural `.agents/`.                                                                   |
| Cursor (slash)     | `.cursor/commands/agents-init.md`                   | Flat-file slash command        |                                                                                    |
| Cursor (skill)     | `.cursor/skills/agents-init/SKILL.md`               | Directory-with-`SKILL.md`       |                                                                                    |
| Gemini CLI         | `.gemini/commands/agents-init.toml`                 | Flat-file slash command (TOML) | TOML frontmatter, not YAML.                                                         |
| Antigravity        | `.agent/skills/agents-init/SKILL.md`                | Directory-with-`SKILL.md`       | Singular `.agent/` (not `.agents/`). Google's flagship.                             |
| GitHub Copilot     | `.github/prompts/agents-init.prompt.md`             | Flat-file prompt file          | `.prompt.md` suffix is the Copilot convention.                                     |
| Hermes             | `.hermes/skills/agents-init/SKILL.md`               | Directory-with-`SKILL.md`       | Project-local skills require a `hermes skills trust` step.                          |
| Kiro               | `.kiro/skills/agents-init/SKILL.md`                 | Directory-with-`SKILL.md`       |                                                                                    |
| Pi                 | `.pi/skills/agents-init/SKILL.md`                   | Directory-with-`SKILL.md`       |                                                                                    |
| Qoder              | `.qoder/skills/agents-init/SKILL.md`                | Directory-with-`SKILL.md`       |                                                                                    |
| Rovo Dev           | `.rovodev/skills/agents-init/SKILL.md`              | Directory-with-`SKILL.md`       | Atlassian.                                                                          |
| Trae               | `.trae/skills/agents-init/SKILL.md`                 | Directory-with-`SKILL.md`       |                                                                                    |
| Trae-CN            | `.trae-cn/skills/agents-init/SKILL.md`              | Directory-with-`SKILL.md`       |                                                                                    |
| Vibe               | `.vibe/skills/agents-init/SKILL.md`                 | Directory-with-`SKILL.md`       | Mistral.                                                                             |
| DeepSeek Harness   | `.dsh/skills/agents-init/SKILL.md`                  | Directory-with-`SKILL.md`       |                                                                                    |
| Veto (global)      | `~/.veto/skills/agents-init/SKILL.md`                | Directory-with-`SKILL.md`       | Project-local install is discouraged; use the global path.                          |

The seven priority wrappers shipped in this repository are: Claude Code, OpenCode, Codex (slash + skill), Cursor (slash), Gemini CLI, Antigravity, and GitHub Copilot. Other vendors are supported via the installer in `scripts/install.sh` and `scripts/install.ps1`, which detects the user's installed harness and copies the right wrapper.

### Installer behavior

The installer scripts (`scripts/install.sh`, `scripts/install.ps1`) detect installed harnesses by looking for their home-directory markers (`~/.claude/`, `~/.opencode/`, `~/.codex/`, `~/.cursor/`, `~/.gemini/`, `~/.agent/`, `~/.config/gh-copilot/`, etc.) and, for each detected harness, copy the corresponding wrapper to the user's home directory (for global-install vendors) or print instructions for project-local vendors that the user must run themselves.

The installer MUST NOT overwrite an existing wrapper without confirmation. It MUST print a summary of which wrappers it installed and which it skipped.

---

## Freshness stamps

A **sibling specification file** (`AGENTS.<TOPIC>.md`) carries a project-owned review stamp directly after its frontmatter:

- `<!-- Last reviewed: YYYY-MM-DD against <reference> -->` — the sibling's content was last verified against `<reference>` (a constitution document, an ADR index, or a commit SHA) on `<date>`.

Semantics:

- A sibling's maintainer SHOULD update the stamp when they re-verify or rewrite the file.
- An agent SHOULD treat a stale stamp (older than the latest commit that touches the domain the sibling governs) as a signal to re-verify before trusting the sibling's content.
- An agent MUST NOT enforce a freshness threshold on its own. Staleness is a hint, not a hard error.
- The root `AGENTS.md`'s orientation sections do not carry stamps.

---

## Reader algorithm

When an agent encounters `AGENTS.md` in a repository:

1. Read the file's first 20 lines and the last 5 lines. Locate the `<!-- agents-template-schema N -->` header (one or both should be present). If neither is present, treat the file as **legacy** and apply best-effort interpretation: section names map to their schema-2 counterparts if recognizable.
2. Read the `## Reader contract (minimal)` section if present. Honor the obligations listed there.
3. For each section in order: treat it as **project-owned** policy unless it is a pointer line under `## Skill overlays`.
4. Resolve the `## Skill overlays` list. For each pointer, read the referenced file(s) lazily — when the agent's task touches the overlay's domain.
5. If a sibling file carries a review stamp, check the stamp against the domain's recent changes. If the stamp is stale, surface a soft warning to the user before trusting the sibling's content.
6. Ignore unknown sections and unknown stamp types. Never error on an unknown construct.

---

## Extension protocol

New overlays join the spec by addition, not modification. To register one:

1. **Choose a name.** A short lowercase identifier (`myoverlay`).
2. **Define the sibling structure.** Where the overlay's files live and what the pointer line names.
3. **Add a row** to the Supported overlays table in this spec.
4. **Bump the schema marker** in this spec and the template (`<!-- agents-spec-schema 2 -->` → `2.1` for additions, `3` for breaking changes).

The spec does not require a central registry. Overlay authors are responsible for proposing their entries; the spec is updated by the template maintainer when consensus forms.

---

## Conformance

A schema-2 file is **conformant** if:

1. It carries both the header and footer `<!-- agents-template-schema N -->` markers with the same `N`.
2. Its `## Reader contract (minimal)` section contains the obligations listed in the template, in the listed order, with wording substantively equivalent.
3. Every `## Skill overlays` pointer references a file or directory that exists in the repository.

An agent MUST treat a non-conformant file as a best-effort input: it parses what it can, ignores what it cannot, and does not error.

---

## Change history

- **v1** (initial) — five-section schema, workflow blocks, skill overlays, freshness stamps, extension protocol.
- **v1.1** — added Onboarding section. Overlays may now ship skills (not just point at sibling files); the agents-template overlay is registered with three pointers (template, spec, `agents-init` skill); conformance rule 5 generalized from "files" to "files or directories."
- **v1.2** — added Distribution section. Documented the vendor-wrapper convention, the full vendor matrix, and the installer scripts. Added Antigravity to the priority vendor list.
- **v1.3** — the canonical template is now the **split edition**: a thin root `AGENTS.md` (≤ ~80 lines) plus heavy, domain-scoped project-owned siblings `AGENTS.POLICY.md`, `AGENTS.STACK.md`, `AGENTS.WORKTREES.md`, ... with `description`/`allowed-tools`/`mode` frontmatter and a `<!-- Last reviewed: ... -->` stamp, loaded lazily via `## Skill overlays` pointers. Distilled from a first production deployment in the ControlEasy Reborn repository. (Never shipped as a release; folded into v2.)
- **v2** — **removed the workflow-blocks mechanism**: adopted tools and workflows — BMAD, GSD-core, openspec, impeccable — are overlays, registered as pointer lines under `## Skill overlays`, with state kept in their own artifact directories. Freshness stamps are project-owned `<!-- Last reviewed: ... -->` stamps on sibling specification files. Breaking change: schema marker bumped to `agents-template-schema 2`.

<!-- agents-spec-schema 2 -->