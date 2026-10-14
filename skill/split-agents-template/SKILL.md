---
name: split-agents-template
description: "Scaffold or refresh a project's AGENTS.md against agents-template-schema 4, with Kiro-style discipline: one domain per file, short binding statements, a why on every rule. Use when setting up AGENTS.md for the first time, refreshing a non-conformant one, or migrating a legacy file. Detects brownfield vs greenfield and asks only what the repo can't answer. Never overwrites an existing AGENTS.md without archiving it."
---

# split-agents-template

Onboarding procedure for the `agents-template-schema` (schema 4). Flow: Detect → Interview → Write → Verify. This folder is the canonical skill; `assets/` ships the template and reader contract it writes from. Install the folder verbatim under any Agent Skills-standard harness (see §Installation).

## Authoring rules — apply to every file written

- One domain per file. Depth goes in an `AGENTS.<TOPIC>.md` sibling, loaded by its frontmatter description.
- Short. A section is binding statements plus reasons, not prose.
- Every rule carries a one-line **why**. A rule without a reason gets applied where it makes no sense.
- No catch-all dumps. Omit a section that has nothing binding to say.

## Phase 1 — Detect

1. **Identity.** Read `package.json`, `Cargo.toml`, `pyproject.toml`, `*.sln`/`*.csproj`, `pom.xml`, `go.mod`, `README.md` (first heading + paragraph) for name + description. Prefer the source closest to the project's primary language; surface disagreements to the user.
2. **Anatomy.** Classify top-level entries:
   - Source: `src/`, `lib/`, `tests/`, `docs/`, and the like.
   - Generated: `dist/`, `build/`, `target/`, `node_modules/` — noise to an agent.
   - Workflow artifacts: `_bmad-output/` or `_bmad/` → BMAD; `.planning/` → GSD-core; `openspec/changes/` → openspec.
   - Overlay artifacts: `.impeccable/`, `PRODUCT.md`, `DESIGN.md`, installed skill directories.
   - VCS/meta: exclude from the anatomy.
3. **Commands.** Map build / test / dev from `package.json` scripts, Cargo, `pyproject.toml` + pytest/Makefile, CI workflows, compose files. Prefer the most specific source. Confirm with the user.
4. **Existing `AGENTS.md`.** Conformant (frontmatter integer schema key + `## Reader contract (minimal)` obligations in order) → offer *refresh in place* (default) or *archive and rewrite*. Legacy (HTML schema markers or missing key) → offer *archive and rewrite* with frontmatter migration (default: rewrite).
5. **Kiro.** If `.kiro/` exists, set Kiro mode (Phase 3, step 5).
6. **Skills and MCP.** Note installed skill dirs — they can signal adopted overlays. Read the MCP configs (`opencode.json`, `mcp.json`, `.claude/settings.json`, and the like) for existing servers — Phase 2 confirms them instead of re-asking.

## Phase 2 — Interview

Ask only the gaps; group questions by the section they populate.

- **Project:** name (if ambiguous), one-line description (offer the detected text), language of `AGENTS.md` (default: the README's language, else English. Template and spec stay in English).
- **Anatomy:** confirm classifications. Defaults: include all source; include generated only if shipped or referenced by CI; workflows noted as keeping their state there; exclude VCS/meta.
- **Commands:** confirm each detected canonical command; ask where a category (lint, e2e) has no detection.
- **Policy:** any hard rules? If none, drop the `AGENTS.POLICY.md` sibling and use the root's one-line placeholder. Process ceremony (merge approval, pre-ship checks) belongs in its own sibling (`AGENTS.WORKTREES.md`), not POLICY.
- **Workflows:** confirm detected ones; offer one-liners if asked. Adopted workflows become pointer lines; tell the user to run the workflow's onboarding skill.
- **Overlays:** confirm detected ones (impeccable → `PRODUCT.md` + `DESIGN.md`; agents-template → the schema artifacts).
- **Languages:** defaults or per-language overrides (overrides go to `AGENTS.STACK.md`).
- **Catch-alls:** only conventions that differ from defaults. If none, omit the section.
- **Tooling — always ask the user; these are preferences, not repo gaps (answers populate `AGENTS.TOOLS.md`):**
  - **Development environment:** ask how the user wants to develop — locally or in Docker. Offer what detection found; if none exists, ask open-ended ("How do you want to run the project — locally or in Docker?"). If Docker is chosen, write Docker-only rules — Docker-only execution (toolchain runs in containers, host shell read-only), no host-side tool installs, per-worktree isolation (Compose project per branch), pulling stages once per task. If local is chosen, name the exact prerequisites and their source of truth.
  - **UI validation:** ask how the user wants to validate UI changes — Playwright MCP, another browser harness, or manual hand-off to the user. If detection found nothing, ask open-ended. Record the exact procedure; for a test gate, require the canonical recipe with CI parity, its pass condition, and fallbacks in priority order (each marked as not equivalent — always run the canonical recipe before pushing). Record where evidence goes (screenshot/trace path).
  - **MCP servers:** ask which MCP servers the user wants installed. Offer the ones detected first; if none exists, or as a supplement, offer the community top-10 for dev workflows as a multi-select — **Playwright** (browser automation; pairs with UI validation), **GitHub** (repos, PRs, issues), **Context7** (current library docs), **Filesystem** (file access), **Docker** (container management; pairs with a Docker env), **Chrome DevTools** (live browser debugging), **Figma** (design-to-code), **Brave Search** (web search), **Postgres** (database), **Sequential Thinking** (structured reasoning). Offer the ones the stack warrants, not all ten — every server costs context and reliability. Record each server's role and its install/config location, and who installs it — the user, or the agent on the user's request. Never install or configure a server unprompted; installing and configuring is allowed only when the user asks.
  - Do not skip these questions when detection found nothing — that is when they matter most. The sibling stays unwritten only if the user answers "none" to all three.

## Phase 3 — Write

1. Locate `assets/AGENTS-TEMPLATE.md` relative to this skill. Missing → abort with: "`assets/AGENTS-TEMPLATE.md` not found — install this skill folder intact."
2. If `AGENTS.md` exists, archive it first as `AGENTS.md.<slug>.bak` (slug: project name, else date). If that bak exists, abort and ask the user to resolve. Record the archived path in the transcript.
3. Copy the template to `AGENTS.md`. Fill the frontmatter identity keys, stamp `generated` with the write date. Never touch the `agents-template-schema` key or the `## Reader contract (minimal)` section.
4. Create only the siblings the project earns — `AGENTS.POLICY.md`, `AGENTS.STACK.md`, `AGENTS.TOOLS.md`, `AGENTS.WORKTREES.md` — from the template's sibling templates, each with its frontmatter and review stamp. Fill a rule family only when it has real rules with reasons. Update `## Skill overlays` to list exactly the siblings that exist.
5. **Kiro branch.** If `.kiro/` exists:
   - Default: nothing further — Kiro loads `AGENTS.md` natively as always-on steering.
   - Offer an optional `.kiro/steering/split-agents-template.md` for *on-demand* loading: frontmatter `inclusion: auto` with `name`/`description`, body one line plus `#[[file:AGENTS.md]]`.
   - Never write `product.md`, `tech.md`, or `structure.md`. Never touch existing steering files.
6. **Verify conformance** against `assets/AGENTS-SPEC.md` §Conformance. Any failure → abort, surface the checks, write nothing non-conformant.
7. **Present** the full populated file; require explicit user approval before committing. The skill never commits.
8. **Next steps.** BMAD → run `bmad-project-context`. GSD-core → run `gsd-onboard`. openspec → run `openspec init`. Confirm each adopted overlay's pointer.

## Does not

- Write other overlays' artifacts (`_bmad-output/`, `.planning/`, `openspec/changes/`, `PRODUCT.md`, `DESIGN.md`).
- Install tools, packages, or MCP servers. It writes the file that tells an agent which tools are in use; installing and configuring them is the user's job.
- Commit, or delete `.bak` archives. Both are the user's job.

## Re-running

Safe to re-run. Conformant file present → offer refresh in place (default). Non-conformant → archive and rewrite. A re-run picks up newly adopted workflows and overlays. Why: adoption is incremental; the file must follow the project.

## Outputs

- `AGENTS.md` — populated, conformant.
- `AGENTS.<TOPIC>.md` — only the siblings the project earns.
- `AGENTS.md.<slug>.bak` — the previous file, if any.
- Transcript — printed to the conversation, not written to disk.

## Installation

The folder installs **verbatim** — `SKILL.md` plus `assets/` — under any Agent Skills-standard harness:

- Project-local (default; must be committed, not gitignored — Codex, Antigravity, and Kiro honor ignore rules and will not see ignored skills): `.claude/skills/`, `.kiro/skills/`, `.cursor/skills/`, `.agents/skills/`, `.agent/skills/`
- Global fallback: `~/.claude/skills/`, `~/.kiro/skills/`, and the other home paths in the vendor matrix (`assets/AGENTS-SPEC.md` §Distribution).

Thin slash-command dispatchers (optional) point at the locally installed folder and add nothing to it. Run `scripts/install.sh` or `scripts/install.ps1` for guided installs.