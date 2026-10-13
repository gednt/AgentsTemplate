<!-- agents-template-schema 1 -->

# AGENTS.md Split Template (v1)

> A **variant** of `AGENTS-TEMPLATE.md` for projects whose `AGENTS.md` becomes too heavy to load in full every session. The root file stays a thin index (≤ ~80 lines); heavy, domain-scoped content moves into sibling overlay files — `AGENTS.POLICY.md`, `AGENTS.STACK.md`, `AGENTS.WORKTREES.md`, and so on — that the agent loads **only when the task touches that domain**.

This variant is distilled from the strategy first deployed in the ControlEasy Reborn repository, where a 9-module platform kept tripping per-turn token budgets because its single `AGENTS.md` carried the CI gate, the worktree ceremony, and two languages' conventions all at once.

Everything in `AGENTS-TEMPLATE.md` and `AGENTS-SPEC.md` still applies. A split `AGENTS.md` is a conforming schema-1 file whose `## Skill overlays` list happens to point at project-owned sibling specification files.

---

## When to split

Split when at least one is true:

- The root `AGENTS.md` has grown past ~150 lines or visibly slows down the first turn of every session.
- Distinct domains (hard policy, language/stack conventions, Git ceremony) each need more than ~30 lines.
- Some domains are irrelevant to most tasks but must still be enforceable when they do apply (e.g., worktree rules only matter when committing).

Stay mono-file when the whole thing fits comfortably in one screen; splitting adds indirection, and the schema's lazy-loading already works within a single well-organized file.

The split is **lossless by construction**: the root keeps one headline line per rule so an agent that never opens a sibling still knows the rule exists and where to find it. Siblings carry the depth.

---

## Loading model

1. Every harness loads the root `AGENTS.md` on session start. It must be short, self-sufficient for orientation, and name every sibling.
2. Siblings are loaded **on demand** — only when the task touches their domain. The load trigger is written in the sibling's pointer line, e.g. *“load it before any non-trivial change.”*
3. Siblings are project-owned specification files. They never carry `<!-- owner:... -->` blocks; they are not workflow state.
4. A sibling may cross-reference another sibling by path (`AGENTS.WORKTREES.md`) but must remain interpretable on its own.

---

## Sibling file conventions

### Naming

`AGENTS.<TOPIC>.md` at the repo root — uppercase topic, dot-separated, sorted adjacent to `AGENTS.md` in every file listing:

- `AGENTS.POLICY.md` — hard rules, verification gates, prohibitions, workflow ownership.
- `AGENTS.STACK.md` — stack identity, per-language conventions, agent concurrency rules.
- `AGENTS.WORKTREES.md` — the Git worktree ceremony, naming conventions, wrapper scripts.

Only create a sibling for a domain that actually earns its depth. An empty placeholder is worse than a headline in the root file.

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
- **`allowed-tools`** — optional, harness-dependent. Where supported (e.g., Claude Code), it scopes the commands the file authorizes. Keep it a narrow allowlist of read-only plus task-relevant commands, not a blanket grant. On harnesses that ignore it, it is inert documentation.
- **`mode: primary`** — the file is authoritative for its domain (a sibling is never a secondary draft of something else).

### Review stamp

Directly after the frontmatter, each sibling carries a project-owned freshness stamp mirroring the schema's workflow-block stamps:

```html
<!-- Last reviewed: YYYY-MM-DD against <reference> -->
```

`<reference>` is whatever the sibling's truth is verified against — a constitution document, an ADR index, or a commit SHA. The same semantics apply as `AGENTS-SPEC.md` §Freshness stamps: stale is a hint to re-verify, not an error. The root `AGENTS.md`'s orientation sections carry no stamp, per the schema.

---

## Root file skeleton

Split the heavy sections of `AGENTS-TEMPLATE.md` like this. Everything else in the base template (reader contract, repo anatomy, workflow blocks, overlays that are not project-owned siblings) is unchanged.

```markdown
<!-- agents-template-schema 1 -->

# AGENTS.md — <project>

<one-line: what the project is.>

Heavy content lives in sibling files listed under `## Skill overlays`;
load them only when the task touches that domain.

---

## Project

<one-paragraph description, users, stack headline.>

---

## Repo anatomy

<orientation — unchanged from AGENTS-TEMPLATE.md>
- AGENTS.POLICY.md / AGENTS.STACK.md / AGENTS.WORKTREES.md — project-owned sibling
  specification files; see `## Skill overlays` for when to load each.

---

## Build, test, and development commands

<canonical commands only — the full gate recipe lives in AGENTS.POLICY.md>

---

## Policy

Hard rules live in [`AGENTS.POLICY.md`](AGENTS.POLICY.md). **Load it before any
non-trivial change.** Headlines: <one clause per rule family, ~1 line each —
e.g. verification gate, worktree rule, per-surface gates, top prohibitions>.

---

## Skill overlays

Load only when the task touches the overlay's domain.

- **AGENTS.POLICY.md** — <one-line role + load trigger>.
- **AGENTS.WORKTREES.md** — <one-line role + load trigger>.
- **AGENTS.STACK.md** — <one-line role + load trigger>.
- <all other (non-sibling) overlays as in AGENTS-TEMPLATE.md>

---

<## Workflow blocks, ## Language conventions (one-line pointer to
AGENTS.STACK.md if present), ## Conventions that differ from defaults — unchanged>

<!-- agents-template-schema 1 -->
```

The header/footer markers, reader contract, and empty-owner-block rules are identical to `AGENTS-TEMPLATE.md` — a split project is still a plain schema-1 file.

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
- **Persistence:** <store, data-access library, LINQ/ORM-first policy>.
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

| Item           | Pattern                            | Example                    |
|----------------|------------------------------------|----------------------------|
| Branch         | `<prefix>/<slug>`                  | `feat/add-export`          |
| Worktree path  | `.worktrees/<branch with slashes as hyphens>` | `.worktrees/feat-add-export` |
| <Compose project / port / volume / other per-worktree resources> | | |
```

---

## Adoption checklist

1. Copy `AGENTS-TEMPLATE.md`, write the project's real content inline, and let it grow naturally.
2. When the split trigger fires (see When to split), move whole rule families — not cherry-picked lines — into `AGENTS.<TOPIC>.md` files with the frontmatter and review stamp above.
3. In the root, leave one headline line per moved rule family, marked in **bold** where the trigger is unconditional ("load it before any non-trivial change").
4. List every sibling under `## Skill overlays` with a one-line role and load trigger.
5. Verify: the root still passes `AGENTS-SPEC.md` §Conformance; each sibling exists, is self-contained, carries no `<!-- owner:... -->` blocks, and is listed in the root's overlays.

---

<!-- agents-template-schema 1 -->