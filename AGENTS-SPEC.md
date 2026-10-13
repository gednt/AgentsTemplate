<!-- agents-spec-schema 3 -->

# AGENTS-SPEC.md — Reader Contract for `AGENTS.md` (v3)

> The authoritative specification for how agents read and obey `AGENTS.md` files written against the `agents-template-schema` family. The template (`AGENTS-TEMPLATE.md`) and any `AGENTS.md` written from it MUST conform to this spec. When the two conflict, this spec wins.

## Table of contents

1. [Scope](#scope)
2. [Terminology](#terminology)
3. [Schema versioning](#schema-versioning)
4. [Sections](#sections)
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

- `AGENTS.md` files written against `agents-template-schema 3` (or later). Files written against schema 1 or 2 are **legacy** input; agents read them best-effort (§Reader algorithm).
- `AGENTS-TEMPLATE.md`, the canonical template that produces conforming `AGENTS.md` files.
- Any agent that reads a conforming `AGENTS.md`, regardless of which tool or overlay produced or consumes the file.

This spec does **not** govern:

- The internal layout of overlay artifact directories (`_bmad-output/`, `.planning/`, `openspec/changes/`, `.impeccable/`, etc.).
- The internal layout of skill-overlay sibling files (`PRODUCT.md`, `DESIGN.md`, and `AGENTS.<TOPIC>.md` content beyond the conventions below).
- The content of `AGENTS.md` sections — only their structure and interpretation.

---

## Terminology

- **Agent** — any AI tool that reads `AGENTS.md` to inform its behavior in a repository (Claude Code, Cursor, Codex, GitHub Copilot, Gemini CLI, OpenCode, Hermes, Kiro, and custom harnesses).
- **Project** — the repository whose `AGENTS.md` is being read.
- **Skill overlay** — an adopted tool, workflow, or convention system integrated through a pointer line in `AGENTS.md` whose sibling files the agent reads lazily. Examples: impeccable (design), BMAD / GSD-core / openspec (planning workflows), formatters, linters.
- **Sibling specification file** — a file at the repo root, named `AGENTS.<TOPIC>.md`, that carries the depth for one domain of `AGENTS.md`.
- **Freshness stamp** — an HTML comment that records when a sibling file was last verified against a known-good reference.

---

## Schema versioning

Every conforming `AGENTS.md` declares its schema version in YAML frontmatter:

```yaml
---
agents-template-schema: 3
---
```

- The frontmatter block MUST be the first content of the file, delimited by `---` lines, so an agent discovers the key on a cheap prefix read.
- The `agents-template-schema` key MUST be an integer and is the **authoritative** schema version marker.
- Every generated file carries the key: the root `AGENTS.md` and every sibling `AGENTS.<TOPIC>.md`.
- Schema 1 and 2 files carried the version as HTML header/footer comments (`<!-- agents-template-schema <N> -->`). Those markers are **legacy**; agents read them best-effort (§Reader algorithm) and MUST NOT write them.

The schema 1–2 footer marker existed to guard against agent harnesses that read large files from the bottom. Schema 3 drops it and relies solely on the top-of-file frontmatter — an accepted trade-off, stated here so the choice is explicit. Where bottom-reading matters, agents parse the frontmatter of the first lines; no footer analogue is required.

A new minor version (e.g., `3.1`) adds sections or markers in a backward-compatible way. A new major version (e.g., `4`) may rename or repurpose sections and is **not** backward-compatible.

---

## Sections

An `AGENTS.md` written against schema 3 carries a frontmatter header followed by the following sections, in order. Sections MAY be omitted; sections in **bold** are recommended.

### Frontmatter

Every generated file (root and siblings) starts with YAML frontmatter. On the root `AGENTS.md`:

```yaml
---
agents-template-schema: 3
project: "<project name>"
description: "<one-line: what the project is>"
language: "<language of the file, e.g. en>"
generated: YYYY-MM-DD
mode: primary
---
```

Key semantics:

- **`agents-template-schema`** — required, integer. The authoritative schema version marker (§Schema versioning).
- **`project`**, **`description`**, **`language`**, **`generated`** — required in files written by a conforming onboarding skill; optional in hand-maintained files. `description` mirrors the project's one-line identity, not the file's load trigger.
- **`mode: primary`** — required. The file is authoritative for its domain (a generated file is never a secondary draft of something else).
- **`allowed-tools`** — optional; per the sibling conventions in `AGENTS-TEMPLATE.md`.
- Unknown keys are ignored without error (§Reader algorithm).

On siblings (`AGENTS.<TOPIC>.md`), the required frontmatter is `agents-template-schema`, `description`, and `mode: primary`, with `description` carrying the two-part "what the file governs + when to load it" value defined in `AGENTS-TEMPLATE.md`. Harnesses that do not parse frontmatter see the block as plain text between horizontal rules — inert but present; it MUST NOT be omitted for their sake.

1. **Reader contract (minimal)** — restated at the top of `AGENTS.md` so the file is interpretable without this spec. MUST be present if `AGENTS-SPEC.md` is absent.
2. **Project** — one-line description, domain, users.
3. **Repo anatomy** — orientation, top-level layout.
4. **Build, test, and development commands** — orientation, canonical commands.
5. **Policy** — hard rules as headlines; depth in `AGENTS.POLICY.md` siblings. Optional; may be a one-line placeholder.
6. **Skill overlays** — pointer list to sibling files.
7. **Language conventions** — per-language style overrides; one-line pointer or short subsections.
8. **Conventions that differ from defaults** — catch-all for project-wide conventions.

Content rules:

- Every other section's text is a binding instruction for the repository: the agent obeys it.
- `## Skill overlays` holds pointer lines to sibling files. The agent reads those files lazily — when the task touches their domain. Overlay siblings extend `AGENTS.md` from the outside; their text is not part of `AGENTS.md`.
- Adopted tools and workflows (BMAD, GSD-core, openspec, ...) are overlays: their state lives in their own artifact directories, and they appear as pointer lines under `## Skill overlays`.

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

- The onboarding skill reads `AGENTS-TEMPLATE.md` and replaces its placeholders with project-specific content. It MUST NOT modify the `agents-template-schema` key or the `## Reader contract (minimal)` section. With the user's answers it populates the frontmatter identity keys (`project`, `description`, `language`) and stamps `generated` with the write date.
- The onboarding skill is **non-destructive**: it MUST archive any existing `AGENTS.md` to `AGENTS.md.<suffix>.bak` before overwriting. The suffix is the project slug (preferred) or a date stamp (fallback).
- The onboarding skill MUST verify conformance against §Conformance before declaring success. If any check fails, the skill aborts and surfaces the failed checks; it does not write a non-conformant file.
- The onboarding skill may create the project's `AGENTS.<TOPIC>.md` sibling specification files (the split template is canonical for this). It MUST NOT write other overlays' artifacts (`_bmad-output/`, `.planning/`, `openspec/changes/`); those belong to the other overlays' onboarding skills.
- An adopted workflow is registered as an overlay pointer; the user is told to run the workflow's onboarding skill if it ships one.
- The onboarding skill is idempotent: re-running it on a project with a conformant `AGENTS.md` is allowed and offers *refresh in place* (default) or *archive and rewrite*.

A project may ship its onboarding skill in a separate overlay. Such a skill MUST honor the same contract. Register the skill in the Supported overlays table by extending the `agents-template` row or adding a new overlay row.

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

A **sibling specification file** (`AGENTS.<TOPIC>.md`) carries a review stamp directly after its frontmatter:

- `<!-- Last reviewed: YYYY-MM-DD against <reference> -->` — the sibling's content was last verified against `<reference>` (a constitution document, an ADR index, or a commit SHA) on `<date>`.

Semantics:

- A sibling's maintainer SHOULD update the stamp when they re-verify or rewrite the file.
- An agent SHOULD treat a stale stamp (older than the latest commit that touches the domain the sibling governs) as a signal to re-verify before trusting the sibling's content.
- An agent MUST NOT enforce a freshness threshold on its own. Staleness is a hint, not a hard error.
- The root `AGENTS.md`'s orientation sections do not carry stamps.

---

## Reader algorithm

When an agent encounters `AGENTS.md` in a repository:

1. Read the file's first lines. If the file starts with a `---`-delimited YAML frontmatter block, read `agents-template-schema` from it. If the key is absent, look for legacy HTML markers (`<!-- agents-template-schema N -->` header/footer, schema 1–2). If neither is present, treat the file as **legacy** and apply best-effort interpretation: section names map to their schema-3 counterparts if recognizable.
2. Read the `## Reader contract (minimal)` section if present. Honor the obligations listed there.
3. For each section in order: obey its content as repository instruction, except pointer lines under `## Skill overlays`, which name files to read lazily.
4. Resolve the `## Skill overlays` list. For each pointer, read the referenced file(s) lazily — when the agent's task touches the overlay's domain.
5. If a sibling file carries a review stamp, check the stamp against the domain's recent changes. If the stamp is stale, surface a soft warning to the user before trusting the sibling's content.
6. Ignore unknown sections and unknown stamp types. Never error on an unknown construct.

---

## Extension protocol

New overlays join the spec by addition, not modification. To register one:

1. **Choose a name.** A short lowercase identifier (`myoverlay`).
2. **Define the sibling structure.** Where the overlay's files live and what the pointer line names.
3. **Add a row** to the Supported overlays table in this spec.
4. **Bump the schema marker** in this spec (`<!-- agents-spec-schema 3 -->` → `3.1` for additions, `4` for a breaking schema change) and in the template's frontmatter `agents-template-schema` key.

The spec does not require a central registry. Overlay authors are responsible for proposing their entries; the spec is updated by the template maintainer when consensus forms.

---

## Conformance

A schema-3 file is **conformant** if:

1. Its first content is a `---`-delimited YAML frontmatter block carrying an integer `agents-template-schema: 3` key, with no legacy HTML `<!-- agents-template-schema ... -->` header or footer markers.
2. If the `## Reader contract (minimal)` section is present (it is required when `AGENTS-SPEC.md` does not ship in the repository), it contains the obligations listed in the template, in the listed order, with wording substantively equivalent.
3. Every `## Skill overlays` pointer references a file or directory that exists in the repository.

A file generated by a conforming onboarding skill additionally passes the frontmatter checks of §Sections: the root carries `agents-template-schema`, `project`, `description`, `language`, `generated`, and `mode: primary`; every sibling carries `agents-template-schema`, its two-part `description`, and `mode: primary`.

An agent MUST treat a non-conformant file as a best-effort input: it parses what it can, ignores what it cannot, and does not error.

---

## Change history

- **v1** (initial) — the section model, skill overlays, freshness stamps, extension protocol.
- **v1.1** — added Onboarding section. Overlays may now ship skills (not just point at sibling files); the agents-template overlay is registered with three pointers (template, spec, `agents-init` skill); the conformance pointer check was generalized from "files" to "files or directories."
- **v1.2** — added Distribution section. Documented the vendor-wrapper convention, the full vendor matrix, and the installer scripts. Added Antigravity to the priority vendor list.
- **v1.3** — the canonical template became the **split edition**: a thin root `AGENTS.md` (≤ ~80 lines) plus heavy, domain-scoped siblings `AGENTS.POLICY.md`, `AGENTS.STACK.md`, `AGENTS.WORKTREES.md`, ... with `description`/`allowed-tools`/`mode` frontmatter and a `<!-- Last reviewed: ... -->` stamp, loaded lazily via `## Skill overlays` pointers. Distilled from a first production deployment in the ControlEasy Reborn repository.
- **v2** — overlay pointers became the single integration point: adopted tools and workflows (BMAD, GSD-core, openspec, impeccable) are registered as pointer lines under `## Skill overlays`, with their state kept in their own artifact directories. Freshness stamps are sibling review stamps. Schema marker bumped to `agents-template-schema 2`.
- **v3** (breaking) — the schema version marker moved from HTML header/footer comments into a mandatory YAML frontmatter key (`agents-template-schema: 3`); the comments are removed from generated files and are read as legacy input. Generated roots additionally carry the identity keys `project`, `description`, `language`, `generated`, and `mode: primary`; every generated sibling carries the schema key in its own frontmatter. Schema 1–2 files no longer conform; agents read them best-effort.

<!-- agents-spec-schema 3 -->