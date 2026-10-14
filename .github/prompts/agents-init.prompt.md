---
name: agents-init
description: Scaffold or refresh an AGENTS.md for any project against the agents-template-schema. Detects brownfield vs greenfield, interviews the user for gaps, writes a conformant file, and archives any previous AGENTS.md.
mode: agent
---

Load and follow the canonical skill body at `skill/split-agents-template/SKILL.md` in the repository root.

This wrapper is a thin dispatcher. The full procedure (detection, interview, write protocol, conformance verification) lives in the canonical file and must not be duplicated here.
