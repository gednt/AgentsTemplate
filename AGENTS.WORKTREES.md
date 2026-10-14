---
agents-template-schema: 4
description: "Mandatory Git worktree rules for AgentsTemplate: all Git work happens in a worktree under .worktrees/, never commit/branch/push/merge on main; the agent reports done and the human merges. Load before any commit, branch, or merge."
allowed-tools: [Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git show-ref *), Bash(git worktree *), Bash(git branch --list *)]
mode: primary
---

<!-- Last reviewed: 2026-10-13 against bf44776 -->

# Git Worktree Rule — AgentsTemplate

Mandatory for every agent (AI or human); applies to every change. Pointed to from `AGENTS.md` §Policy.

## The rule

- **All Git work happens in a worktree.** Why: `main` merges clean after human review — the only permitted `main` operation is fast-forwarding to a reviewed tip.
- **One task, one worktree, one branch** — `.worktrees/<task>/` on `feat/<task>`, `<task>` semantic, lowercase, hyphen-separated. Why: no slug reuse while branches coexist; a name frees up only after merge/delete.
- **Pre-flight check before creating.** Read-only check (`git branch --list feat/<task>`, `git worktree list`); abort on collision and pick a new name.
- **Canonical command.** `git worktree add -b feat/<task> .worktrees/<task> main` — branch and path in one step.
- **The agent reports done; the human merges on `main`.** The agent commits and pushes inside the worktree, then stops. Why: merge approval is exactly that — approving the change is not an instruction to merge. Only the literal in-turn words "merge on main" authorize a merge.
- **Push after every commit.** On push failure: keep the commit local, surface error + SHA, do not mark done, never retry or force-push.
- **Clean up after merge.** Remove only your own worktree (`git worktree remove .worktrees/<task>`); touch no other worktrees or paths.
- **No force-push, no rewriting shared history.** Local-only rewrites before push are allowed when nothing else depends on the branch.
- **Downstream projects copy this** from `AGENTS-TEMPLATE.md`'s sibling template verbatim, or adapt the prefix (`fix/`, `chore/`).

## No build-side ceremony

This repository ships plain Markdown: no build, tests, lint, or CI gate exists. Verification is reading `AGENTS-SPEC.md` §Conformance and re-checking the worked example.