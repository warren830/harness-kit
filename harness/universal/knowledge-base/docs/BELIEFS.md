---
name: Core Beliefs / Golden Principles Template
description: Non-negotiable rules that agents must NEVER violate. The "constitution" of your codebase.
when_to_use: Any project where certain rules are absolute regardless of context.
when_not_to_use: You should always have at least a few core beliefs. Even a one-line file is valuable.
---

# Core Beliefs

> These are non-negotiable. No exceptions. No "just this once."
> AI agents must treat these as hard constraints, not suggestions.

## Engineering Principles

<!-- List 3-7 absolute principles. More than 10 becomes noise. -->

1. **[Tests before merge]** — No code enters main without passing tests. No exceptions.
2. **[Types everywhere]** — No `any` in TypeScript. All function signatures typed. All API responses typed.
3. **[Security by default]** — All user input validated. All API endpoints authenticated. No secrets in code.
4. **[Backward compatibility]** — API changes must not break existing clients. Use versioning.
5. **[Small PRs]** — Each PR does one thing. If a PR touches more than 10 files, split it.

## Architectural Boundaries

<!-- Absolute lines that must not be crossed -->

1. **[Client/server boundary]** — Client code must NEVER import server modules. Server code must NEVER depend on client components.
2. **[Database abstraction]** — Only repository layer touches the database. Services must NEVER use Prisma/SQL directly.
3. **[Core protection]** — `src/core/` is the protected kernel. Modifications require explicit approval.

## Process Rules

<!-- Workflow rules for agents -->

1. **[Verify before done]** — Always run lint + test + build before declaring a task complete.
2. **[Don't guess, ask]** — If requirements are ambiguous, ask for clarification instead of guessing.
3. **[Don't fix what ain't broke]** — When fixing a bug, don't refactor surrounding code. Stay focused.
