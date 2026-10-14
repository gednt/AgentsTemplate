---
agents-template-schema: 4
---

# AGENTS.md Template — Split Edition (schema 4)

> A schema-driven template for `AGENTS.md` that works across BMAD, GSD-core, openspec, impeccable, Kiro steering, and any future skill overlay. Shipped as a split set: a thin root `AGENTS.md` plus domain-scoped siblings `AGENTS.<TOPIC>.md`, loaded only when the task touches that domain.

For the authoritative reader contract, see `AGENTS-SPEC.md` (same folder as this file).

## Loading model

1. Every harness loads the root on session start. The root stays an index: orientation, headline rules, pointers.
2. Siblings load on demand — the pointer line and the sibling's `description` decide when.
3. The split is lossless: the root keeps one headline line per rule family. Moving a rule without leaving its headline in the root is a conformance failure.
4. A sibling stays interpretable on its own; it may cross-reference siblings by path.

### Kiro-style authoring rules (schema 4 discipline)

- **One domain per file.** If a domain needs more than ~30 lines in the root, it earns a sibling. Tiny projects may stay mono-file.
- **Binding statements, not prose.** Write rules as short imperative sentences. Background goes in one line or nowhere.
- **A why on every rule.** A rule with its reason survives situations its author did not anticipate; a bare rule gets applied literally.
- **No stubs.** An empty sibling placeholder is worse than a headline in the root — create only the siblings the project earns.

---

## The root `AGENTS.md`

Copy this skeleton to the project root and replace the placeholders:

```markdown
---
agents-template-schema: 4
project: "<project name>"
description: "<one-line: what the project is>"
language: "<language of this file, e.g. en>"
generated: <YYYY-MM-DD write date>
mode: primary
---

# AGENTS.md

<one line: what the project is.>

Heavy content lives in sibling files under `## Skill overlays`;
load them only when the task touches that domain.

---

## Reader contract (minimal)

An agent reading this `AGENTS.md` alone (without `AGENTS-SPEC.md`) MUST:

1. Treat the content of every section as a binding instruction for this repository — the agent obeys it.
2. Treat the `## Skill overlays` list as pointers to sibling files, read lazily — only when the task touches the overlay's domain.
3. Treat the `agents-template-schema` key in this file's frontmatter as the version this file conforms to. Unknown section names are ignored without error.

---

## Project

<one line: domain, primary users.>

---

## Repo anatomy

<orientation. Top-level layout, one line per entry. Include one line naming the AGENTS.* siblings.>

---

## Build, test, and development commands

<canonical commands only — one line each.>

---

## Policy

<Hard rules live in [`AGENTS.POLICY.md`](AGENTS.POLICY.md). Load before any non-trivial change. Headlines, one clause per rule family.>
No project policy? Drop the POLICY sibling and write: _No project-level policy; see the skill overlays for scope._

---

## Skill overlays

Load only when the task touches the overlay's domain.

- **AGENTS.POLICY** — `AGENTS.POLICY.md`. Hard policy and prohibitions. Load before any non-trivial change.
- **AGENTS.STACK** — `AGENTS.STACK.md`. Stack identity and per-language conventions. Load before touching code in the corresponding language.
- **AGENTS.TOOLS** — `AGENTS.TOOLS.md`. Agent tooling: dev environment, UI validation, MCP servers. Load before running the app, validating UI, or adding tool integrations.
- **AGENTS.WORKTREES** — `AGENTS.WORKTREES.md`. Git worktree ceremony. Load before any commit, branch, or merge.
- **<other overlays>** — `<paths>`. <one-line role + load trigger>.

If a project stops using an overlay, remove its line. Stale pointers mislead agents.

---

## Language conventions

<One line, or one short subsection per language listing only rules that differ from the language's defaults. Depth lives in AGENTS.STACK.md.>

---

## Conventions that differ from defaults

<One line per convention. Catch-alls with depth belong in a sibling.>
```

Schema 1–2 `<!-- agents-template-schema N -->` HTML markers are legacy input; never write them. Workflows (BMAD, GSD-core, openspec) are adopted as ordinary overlay pointers; their state stays in their own artifact directories.

---

## Sibling conventions

### Naming

`AGENTS.<TOPIC>.md` at the repo root — uppercase, dot-separated, so siblings sort adjacent to `AGENTS.md`.

### Frontmatter — every generated file

```yaml
---
agents-template-schema: 4
description: "<what the file governs> + <load trigger, e.g. 'Load before any non-trivial change.'>"
allowed-tools: [Read, Grep, Glob, Bash(<narrow allowlist>)]   # optional
mode: primary
---
```

- `agents-template-schema` — required, integer, identical on the root and every sibling. Identical is the conformance check: a split set is one logical document.
- `description` — mandatory, two parts: what the file governs + when to load it. This is the trigger an agent reads instead of the file.
- `allowed-tools` — optional, keep it a narrow allowlist, not a blanket grant.
- `mode: primary` — required; a generated file is never a secondary draft.
- The root carries the additional identity keys (`project`, `description`, `language`, `generated`). Harnesses that ignore frontmatter render it as inert text — the block MUST NOT be omitted for their sake.

### Review stamp

Directly after the frontmatter, each sibling carries:

```html
<!-- Last reviewed: YYYY-MM-DD against <reference> -->
```

Stale is a hint to re-verify, not an error (§ AGENTS-SPEC Freshness stamps). The root's orientation sections carry no stamp.

---

## Sibling template: `AGENTS.POLICY.md`

```markdown
---
agents-template-schema: 4
description: "Hard policy: <verification gate>, <per-surface gates>, prohibitions, workflow directories. Load before any non-trivial change."
allowed-tools: [Read, Grep, Glob, Bash(<gate and read-only commands>)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Hard Policy — <project>

## <Verification gate(s)>

<Exact command, stages, cadence, per tier. "No task is done until the final tier passes on the final state." Name the docs-only exception paths.>

## <Per-surface gates>

<Gates for a specific subtree only: canonical recipe, pass condition, fallbacks in priority order.>

## Platform-aware command execution

<Detect host OS + shell before issuing commands; route mismatches; prefer platform-neutral composition.>

## Hard prohibitions

- **No work on `main`.** <Worktrees only.>
- **No host-side tool installation.** <All tooling in containers; stop and surface missing dependencies.>
- **Atomic commits.** <One logical change, tree green, Conventional Commits.>
- **Push after every commit.** <On failure: surface error + SHA, never force-push.>
- **<project rules>** — <rule + why in one clause each.>

## Workflow directories (non-overlapping)

- **<workflow>** keeps its state in `<directory>`. Each workflow writes only inside its own directory.
```

---

## Sibling template: `AGENTS.STACK.md`

```markdown
---
agents-template-schema: 4
description: "Stack identity and per-language conventions. Load before touching code in the corresponding language."
allowed-tools: [Read, Grep, Glob, Bash(<build/test/lint commands>)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Stack & Language Conventions — <project>

## Stack

- **Backend:** <framework, version, API style>.
- **Frontend:** <framework, version, key patterns>.
- **Persistence:** <store, data-access library>. Why: <the one reason>
- **Testing:** <toolchain>.
- **Errors/logging:** <error envelope, pipeline>.

## <Language>

- <Only rules that differ from the language's defaults, one line each, why attached.>

## Agent workflow conventions

- <Concurrency budget, post-task verification pointer, pre-commit review gate.>
```

---

## Sibling template: `AGENTS.TOOLS.md`

Create when the project's agent tooling — dev environment, UI validation, MCP servers — has real choices a fresh agent must follow. Skip when there is nothing binding to say. The rules encode two disciplines: Docker-only development, and UI validation as a gate with CI parity.

```markdown
---
agents-template-schema: 4
description: "Agent tooling: development environment, UI validation, MCP servers. Load before running the app, validating UI changes, or adding tool integrations."
allowed-tools: [Read, Grep, Glob, Bash(<dev/validate/docker commands>)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Agent Tooling — <project>

## Development environment

- **Docker-only execution.** All build/test/run commands execute inside containers; <`docker` CLI> is the only host requirement. Never install <project toolchain: SDK, runtimes, package managers> on the host. Why: dev runs match CI image-for-image; the host stays clean.
- **Dev shell:** <devcontainer path / named container>. The host shell is for read-only inspection only. Why: <one reason>
- **Run the app:** <canonical command, e.g. `docker compose -f docker/docker-compose.yml up -d --build`>.
- **Per-worktree isolation:** <Compose project name `-p <prefix>-<branch-hyphens>` / local ports file>. Why: two worktrees must never share containers, networks, or volumes.
- **No host-side tool installation** (`apt`, `brew`, `choco`, `winget`, `npm i -g`, `dotnet tool install -g`, ...). A missing tool with the container runtime down → surface the dependency to the user and stop; do not start Docker on their behalf. Why: silent host installs drift from CI.
- **Docker-pulling stages (image downloads, container builds) run once at task completion, not per turn.** Why: they dominate turn time.

## UI validation

- **Every change under <UI path(s)> is validated before reporting "done":** <exact procedure — e.g. smoke-test the running SPA with the webapp-testing skill / Playwright MCP; then run the UI test gate>. Contributor responsibility, not auto-invoked. Why: UI regressions ship silently otherwise.
- **Canonical recipe — bit-for-bit parity with CI** <name the job>; its pass condition: <exact observable, e.g. exit 0 + summary grep, no FAILED lines>.
- **Fallbacks, in priority order, only when the canonical recipe cannot run:** <devcontainer-direct / host-direct / invoke-otherwise> — each marked as *not* equivalent; always run the canonical recipe before pushing. No "done" claim with the gate unverified.
- <Where evidence goes: screenshot/trace path, log location.>

## MCP servers

- **<server-name>** — <one-line role>. <Install/config location>.
- New servers are added by the user, not the agent. Why: servers grant tool capabilities; silent additions surprise the user.
```

---

## Sibling template: `AGENTS.WORKTREES.md`

Strongly recommended for every adopting project — this sibling is its canonical home.

```markdown
---
agents-template-schema: 4
description: "Mandatory Git worktree rule: all Git work happens in a worktree under .worktrees/, never on main. Load before any commit, branch, or merge."
allowed-tools: [Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git worktree *)]
mode: primary
---

<!-- Last reviewed: YYYY-MM-DD against <reference> -->

# Git Worktree Rule — <project>

## The rule

- **All Git work happens in a worktree.** Why: `main` must merge clean after human review.
- **One task, one worktree, one branch** — `.worktrees/<task>/` on `feat/<task>`. Why: no slug reuse.
- **The agent reports done; the human merges on `main`.** Why: merge approval is exactly that — approving the change is not an instruction to merge.
- **Push after every commit.** Why: work survives a lost worktree.
- **No force-push, no rewriting shared history.**
- **Pre-flight check** (`git branch --list feat/<task>`, `git worktree list`) before creating; abort on collision.

## Canonical command

```bash
git worktree add -b feat/<task> .worktrees/<task> main
```
```

---

## Adding more siblings

1. Pick the topic: `AGENTS.<TOPIC>.md`, uppercase, hyphenated.
2. Copy frontmatter + review stamp from the templates above.
3. Move the **whole rule family** to the sibling; leave its headline in the root.
4. Add the pointer line under `## Skill overlays`.

## Adoption checklist

1. Copy the root skeleton as `AGENTS.md`, fill placeholders.
2. Create only the siblings the project earns.
3. Verify: root passes §Conformance in `AGENTS-SPEC.md`; every sibling exists, is self-contained, and is listed in `## Skill overlays`.