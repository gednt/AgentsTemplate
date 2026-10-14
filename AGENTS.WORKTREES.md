---
agents-template-schema: 3
description: "Mandatory Git worktree rules for AgentsTemplate: all Git work happens in a worktree under .worktrees/, never commit/branch/push/merge on main; the agent reports done and the human merges. Load before any commit, branch, or merge."
allowed-tools: [Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git show-ref *), Bash(git worktree *), Bash(git branch --list *)]
mode: primary
---

<!-- Last reviewed: 2026-10-13 against 63859e4 -->

# Git Worktree Rule — AgentsTemplate

Mandatory for every agent (AI or human). Applies to every change, including edits to the schema, the spec, the canonical skill, the vendor wrappers, and the installers. Pointed to from `AGENTS.md` §Policy.

## The rule

- **All Git work happens in a worktree.** Never commit, branch, push, or merge on `main`. The only permitted operation on `main` is fast-forwarding `main` to a feature branch's tip after a human has reviewed and approved the change.
- **One worktree per change.** Create a dedicated worktree at `.worktrees/<task>/` on a branch `feat/<task>`, where `<task>` is a semantic, lowercase, hyphen-separated name describing the change. Downstream projects may adapt the prefix (`fix/`, `chore/`).
- **Pre-flight check before creating a worktree.** Use only read-only Git commands (`git branch --list feat/<task>`, `git worktree list`) to confirm the branch does not exist and the path is not already a worktree. If either exists, abort and pick a different task name.
- **Canonical command.** `git worktree add -b feat/<task> .worktrees/<task> main` creates the branch and the path in one step.
- **The agent reports done; the human merges on `main`.** The agent commits, branches, and pushes inside the worktree, then stops. The agent MUST NOT run `git merge` on `main` for any reason. The only exception: the human explicitly says, in the current turn, "merge on main." Anything else — including approval of the change — is not an instruction to merge.
- **One task, one worktree, one branch.** Do not reuse a `<task>` slug, a `feat/<task>` branch, or a `.worktrees/<task>/` path between concurrent tasks. The same name may be reused only after the previous worktree is removed and its branch is merged or deleted.
- **Push after every commit.** Every commit lands on the worktree branch and is pushed immediately. On push failure: keep the commit local, surface the error + SHA to the user, do not mark the task done, never retry / fall back to another remote / force-push.
- **Clean up after merge.** After a change merges to `main` and is verified, remove only the worktree you created: `git worktree remove .worktrees/<task>`. Do not touch unrelated worktrees, branches, or paths.
- **No force-push, no rewriting shared history.** Do not rewrite commits that have been pushed or that other worktrees share. Local-only history rewrites (interactive rebase before push) are allowed when no one else depends on the branch.

## No build-side ceremony

This repository ships plain Markdown: no build, tests, lint, or CI gate exists. Verification is done by reading `AGENTS-SPEC.md` §Conformance and re-checking the worked example.

The recommended, copy-through form of this rule for downstream projects is in `AGENTS-TEMPLATE.md` (sibling template: `AGENTS.WORKTREES.md`).