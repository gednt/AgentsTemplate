<!-- agents-template-schema 2 -->

# AGENTS.md Template (v1) — Split Edition

> A schema-driven template for `AGENTS.md` that works across BMAD, GSD-core, openspec, impeccable, and any future skill overlay — shipped as a **split set**: a thin root `AGENTS.md` (≤ ~80 lines) plus heavy, domain-scoped sibling files `AGENTS.POLICY.md`, `AGENTS.STACK.md`, `AGENTS.WORKTREES.md`, and so on, loaded **only when the task touches that domain**.

Every harness loads the root file on session start, so the root stays an index: orientation, headline rules, and pointers. Depth lives in the siblings, each with loader frontmatter and a review stamp. This keeps the first turn of every session cheap without giving up enforceable detail — a production proof first ran in the ControlEasy Reborn repository.

For the authoritative reader contract — how agents interpret this template, the extension protocol, and how review stamps behave — see `AGENTS-SPEC.md`.

---

## Loading model

1. The root `AGENTS.md` is loaded by every harness on session start. It must be short, self-sufficient for orientation, and name every sibling with a `## Skill overlays` pointer.
2. Siblings are loaded **on demand** — only when the task touches their domain. The load trigger is written in the sibling's pointer line and reinforced by the sibling's own frontmatter `description`.
3. Siblings are project-owned specification files. They own nothing in `AGENTS.md` and never hold external tool state.
4. A sibling may cross-reference another sibling by path (`AGENTS.WORKTREES.md`), but must remain interpretable on its own.

The split is **lossless by construction**: the root keeps one headline line per rule so an agent that never opens a sibling still knows the rule exists and where to find it. Moving a rule family without leaving its headline is a conformance failure, not a shortcut.

### When to stay mono-file

Tiny projects (a schema artifact, a single-purpose script repo) may inline everything in the root. The moment any domain — hard policy, stack conventions, Git ceremony — needs more than ~30 lines, move it to a sibling using the templates below. An empty sibling placeholder is worse than a headline in the root; only create the siblings the project actually earns.

---

## The root `AGENTS.md`

Copy this skeleton to the project root as `AGENTS.md` and replace the placeholders:

```markdown
<!-- agents-template-schema 2 -->

<optional YAML frontmatter: description + allowed-tools, per sibling
conventions below. Omit entirely on harnesses that ignore it.>

# AGENTS.md

<one line: what the project is.>

Heavy content lives in sibling files under `## Skill overlays`;
load them only when the task touches that domain.

---

## Reader contract (minimal)

An agent reading this `AGENTS.md` alone (without `AGENTS-SPEC.md`) MUST:

1. Treat sections not pointed to from `## Skill overlays` as **project-owned**: their content is binding for this repository and the agent obeys it.
2. Treat the `## Skill overlays` list as a set of pointers to sibling files. The agent reads those sibling files directly, lazily, only when the task touches the overlay's domain; no sibling owns anything in `AGENTS.md`.
3. Treat the schema header (`<!-- agents-template-schema 2 -->`) as the version this file conforms to. Unknown section names do not error; the agent ignores them.

---

## Project

<one-line description of the project, its domain, and its primary users.>

---

## Repo anatomy

<orientation. List the top-level layout, and include one line naming the
AGENTS.* sibling files as project-owned specification files.>

- `AGENTS.POLICY.md` / `AGENTS.STACK.md` / `AGENTS.WORKTREES.md` — project-owned sibling specification files; see `## Skill overlays` for when to load each.

---

## Build, test, and development commands

<canonical commands only — one line each. Full gate recipes, fallbacks,
and pass conditions live in AGENTS.POLICY.md.>

---

## Policy

Hard rules live in [`AGENTS.POLICY.md`](AGENTS.POLICY.md). **Load it before any
non-trivial change.** Headlines: <one clause per rule family, ~1 line each —
e.g. the verification gate, the worktree rule, per-surface gates, and the
top prohibitions>. Stack and language conventions live in
[`AGENTS.STACK.md`](AGENTS.STACK.md); Git ceremony in
[`AGENTS.WORKTREES.md`](AGENTS.WORKTREES.md).

If the project has **no** hard policy, drop the AGENTS.POLICY.md sibling and
write instead: _No project-level policy; see the skill overlays for scope._

---

## Skill overlays

Load only when the task touches the overlay's domain.

- **AGENTS.POLICY** — `AGENTS.POLICY.md`. Hard policy (verification gate, per-surface gates, prohibitions, workflow ownership). Load before any non-trivial change.
- **AGENTS.STACK** — `AGENTS.STACK.md`. Stack identity and per-language conventions. Load before touching code in the corresponding language.
- **AGENTS.WORKTREES** — `AGENTS.WORKTREES.md`. Git worktree rule and naming ceremony. Load before any commit, branch, or merge.
- **agents-template** — `AGENTS-TEMPLATE.md`, `AGENTS-SPEC.md`. Schema authoring. Read when editing `AGENTS.md` structure.

<all other overlays as pointer lines, same pattern>

If a project stops using an overlay, remove its line. Do not leave stale pointers.

---

## Language conventions

One line only; the depth lives in `AGENTS.STACK.md`:

Per-language style rules (naming, structure, strictness, formatting) live in [`AGENTS.STACK.md`](AGENTS.STACK.md). Load it before touching code in the corresponding language.

If no stack sibling exists, replace this section with one subsection per language, listing only rules that differ from the language's defaults.

---

## Conventions that differ from defaults

<catch-all for project-wide conventions that don't fit elsewhere. One line
per convention; details belong in the sibling that owns the domain.>

---

<!-- agents-template-schema 2 -->
```

The header/footer markers and the reader contract are the schema-2 contract; a split project is a plain schema-2 file. Workflows (BMAD, GSD-core, openspec, ...) are adopted as ordinary overlay pointers; their state lives in their own artifact directories.

---

## Sibling file conventions

### Naming

`AGENTS.<TOPIC>.md` at the repo root — uppercase topic, dot-separated, sorted adjacent to `AGENTS.md` in every file listing:

- `AGENTS.POLICY.md` — hard rules, verification gates, prohibitions, workflow ownership.
- `AGENTS.STACK.md` — stack identity, per-language conventions, agent concurrency rules.
- `AGENTS.WORKTREES.md` — the Git worktree ceremony, naming conventions, wrapper scripts.

### Frontmatter

Every sibling file starts with a YAML frontmatter block that harnesses and agents use to decide whether and how to load it:

```yaml
---
description: "<what the file governs> + <explicit load trigger, e.g. 'Load before any non-trivial change.'>"
allowed-tools: [Read, Grep, Glob, Bash(<allowlisted commands>)]   # optional
mode: primary
---
```

- **`description`** — mandatory. Two parts: what the file governs, and when to load it. This is what an agent reads instead of the whole file when deciding.
- **`allowed-tools`** — optional, harness-dependent. Where supported, it scopes the commands the file authorizes. Keep it a narrow allowlist of read-only plus task-relevant commands, not a blanket grant. On harnesses that ignore it, it is inert documentation.
- **`mode: primary`** — the file is authoritative for its domain (a sibling is never a secondary draft of something else).

The root file may carry the same frontmatter shape (omit `allowed-tools` where the root needs no shell access, or keep an allowlist of read-only commands).

### Review stamp

Directly after the frontmatter, each sibling carries a project-owned review stamp:

```html
<!-- Last reviewed: YYYY-MM-DD against <reference> -->
```

`<reference>` is whatever the sibling's truth is verified against — a constitution document, an ADR index, or a commit SHA. Semantics per `AGENTS-SPEC.md` §Freshness stamps: stale is a hint to re-verify, not an error. The root's orientation sections carry no stamp, per the schema.

---

## Sibling template: `AGENTS.POLICY.md`

```markdown
---
description: "Hard policy: <verification gate>, <per-surface gates>, platform-aware execution, hard prohibitions, workflow ownership. Load before any non-trivial change."
allowed-tools: [Read, Grep, Glob, Bash(<gate scripts and read-only commands>)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Hard Policy — <project>

Mandatory rules an agent must not violate. Pointed to from `AGENTS.md` §Policy.

## <Verification gate(s)>

<Tiered cadence; each tier: exact command, stages, duration, when it runs.
"No task is done until the final tier passes on the final state."
Documentation-only exception: which paths count as docs-only, which checks
are skipped, which obligations still apply.>

## <Per-surface gates>

<Gates that apply only to a specific subtree (e.g., a web SPA) and are not
covered by the main gate: the canonical recipe, the pass condition,
fallbacks in priority order, and where enforcement hooks live.>

## Platform-aware command execution

<Detect host OS + shell before issuing commands. Which syntaxes are
forbidden on which hosts, how to fix or route around a mismatch, and the
escalation path. Prefer platform-neutral composition.>

## Hard prohibitions

- **No work on `main`.** <summary + pointer to AGENTS.WORKTREES.md>
- **No host-side tool installation.** <all tooling in containers; surface
  missing dependencies and stop>
- **Atomic commits.** <one logical change, tree builds green, Conventional
  Commits, body explains why>
- **Push after every commit.** <immediate push; on failure surface error +
  SHA, do not mark done, never retry/fallback/force-push>
- **<domain-specific prohibitions>** — <top N project-specific rules with
  the reason compressed to a clause (e.g., 'No EF Core — DBTools is the
  only data-access library, per ADR 0002')>

## Workflow ownership (non-overlapping)

- **<workflow>** owns `<directory>` — <what it stores there>.

No workflow may write into another workflow's directory.
```

## Sibling template: `AGENTS.STACK.md`

```markdown
---
description: "Stack and language conventions: <backend>, <frontend>, <persistence>. Per-language style rules, agent workflow conventions. Load before touching code in the corresponding language."
allowed-tools: [Read, Grep, Glob, Bash(<build/test/lint tool commands>)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Stack & Language Conventions — <project>

## Stack

- **Backend:** <framework, language version, API style>.
- **Frontend:** <framework, version, key patterns>.
- **Persistence:** <store, data-access library, query-first policy>.
- **Auth:** <mechanism>.
- **Testing:** <unit, integration, E2E toolchain>.
- **Errors/logging:** <error envelope, logging pipeline>.

## <Language 1>

- <naming, structure, nullable/strictness, package-versioning>
- <API route / naming conventions>

## <Language 2>

- <component model, state, change detection, lint/format config>
- <code-generation policy: generated clients, no shared models>

## Agent workflow conventions

- **Concurrency budget.** <max sub-agents in flight; how to justify exceeding it>
- **Post-task verification.** See `AGENTS.POLICY.md` §<gate name>.
- **Pre-commit adversarial review.** <what must be green before `git commit`>
```

## Sibling template: `AGENTS.WORKTREES.md`

The Git worktree rule is **strongly recommended** for every project that adopts this template; this sibling is its canonical home in the split model.

```markdown
---
description: "Mandatory Git worktree rule: all Git work happens in a worktree under .worktrees/, never commit/branch/push/merge on main; canonical wrapper script and naming convention. Load before any commit, branch, or merge."
allowed-tools: [Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git worktree *), Bash(scripts/<wrapper>*)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Git Worktree Rule — <project>

Mandatory for every agent (AI or human).

## The rule

- **The main tree stays pristine.** <main checkout is read-only; only
  read-only git commands allowed before work starts>
- **All Git work happens in a worktree.** <branch prefix, slug pattern>
- **Worktrees live under `.worktrees/`.** <gitignored; canonical path pattern>
- **The agent reports done; the human merges on `main`.** <no merge except
  human's explicit in-turn "merge on main">
- **One task, one worktree, one branch.** <no slug reuse>
- **Atomic commits land on the worktree branch only.** <pointer to AGENTS.POLICY.md>
- **Push after every commit.** <exact push commands; failure handling>
- **Clean up after merge.** <remove only your own worktree>
- **No force-push, no rewriting shared history.**

## Canonical command — <host platform>

```powershell
scripts/<wrapper>.ps1 -Branch <branch-syntax>
```

<What the wrapper does: pre-flight check, worktree creation, per-worktree
environment writes. POSIX / other-host equivalent for reference, with the
warning that it must not be invoked from a mismatched host shell.>

## Worktree naming convention

| Item           | Pattern                                     | Example                       |
|----------------|---------------------------------------------|-------------------------------|
| Branch         | `<prefix>/<slug>`                           | `feat/add-export`             |
| Worktree path  | `.worktrees/<branch with slashes as hyphens>` | `.worktrees/feat-add-export` |
| <Compose project / port / volume / other per-worktree resources> | | |
```

Without wrapper scripts, the canonical command is plain Git:

```bash
git worktree add -b feat/<task> .worktrees/feat-<task> main
```

---

## Writing your own sibling

Any domain may earn its own sibling beyond the three above. Follow the formula:

1. Pick the topic word: `AGENTS.<TOPIC>.md`, uppercase, hyphenated if multi-word.
2. Copy the frontmatter + review stamp block from the templates.
3. Move **whole rule families** from the root — not cherry-picked lines — and replace each with a headline line in the root's `## Policy` or the relevant section.
4. Add the pointer line under `## Skill overlays`, in the same format: bold name with the dotted file, path, one-line role, load trigger.

---

## Adoption checklist

1. Copy the root skeleton above into the project as `AGENTS.md` and fill in the placeholders.
2. Create the siblings the project actually needs from the templates above. Skip a domain entirely if it fits in one line rather than creating a stub.
3. Move nothing without leaving its headline in the root; remove nothing that is enforceable.
4. Verify: the root still passes `AGENTS-SPEC.md` §Conformance; each sibling exists, is self-contained, and is listed in the root's `## Skill overlays`.

---

<!-- agents-template-schema 2 -->