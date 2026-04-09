---
name: AGENTS.md Monorepo Template
description: For monorepos with multiple packages/services. Root AGENTS.md acts as a map; each package has its own.
when_to_use: Monorepos (Nx, Turborepo, Lerna, pnpm workspaces) with 3+ packages.
when_not_to_use: Single-package repos (use standard.md).
---

<!-- =================================================================
     AGENTS.md Monorepo Template — harness-kit

     STRATEGY:
     - Root AGENTS.md = project map (~50-80 lines)
     - Each package gets its own AGENTS.md (~20-50 lines)
     - Agent reads root first, then the relevant package's file

     OpenAI uses 88 AGENTS.md files across subsystems.
     Kiro auto-detects AGENTS.md at any directory level.
     Claude Code supports nested CLAUDE.md (child overrides parent).
     ================================================================= -->

# AGENTS.md (Root)

[Project name]: A monorepo containing [N] packages for [purpose].

## Monorepo Structure

```
[packages/
  web/              — Next.js frontend
  api/              — Express API server
  shared/           — Shared types and utilities
  mobile/           — React Native app
  infra/            — CDK/Terraform infrastructure]
```

Each package has its own AGENTS.md with package-specific commands and conventions.

## Global Commands

| Action | Command | Scope |
|--------|---------|-------|
| Install all | `[pnpm install]` | Root |
| Build all | `[pnpm build]` | Root |
| Test all | `[pnpm test]` | Root |
| Lint all | `[pnpm lint]` | Root |
| Build one package | `[pnpm --filter <pkg> build]` | Package |
| Test one package | `[pnpm --filter <pkg> test]` | Package |

## Cross-Package Rules

- `shared/` is the ONLY package that can be imported by other packages
- Direct imports between `web/` and `api/` are FORBIDDEN — use `shared/` types
- Each package manages its own dependencies in its own `package.json`
- Root `package.json` is for workspace tooling only — no application dependencies

## Dependency Graph

```
[web ──→ shared
 api ──→ shared
 mobile ──→ shared
 infra ──→ (standalone, no internal deps)]
```

## Working on a Specific Package

When working on a specific package:
1. Read that package's AGENTS.md first
2. Run that package's tests, not the entire monorepo
3. Stay within that package's directory unless modifying shared types

## Agent Pitfalls (Error-Driven)

<!-- Add global monorepo pitfalls here. Package-specific ones go in package AGENTS.md. -->
<!-- Example:
     - Use `pnpm --filter web dev` not `cd packages/web && pnpm dev`
     - Do NOT add dependencies to root package.json
     - Shared types must be exported from shared/src/index.ts barrel file
-->

## Verification

After modifying code in package `<pkg>`:
1. `[pnpm --filter <pkg> lint]`
2. `[pnpm --filter <pkg> test]`
3. `[pnpm --filter <pkg> build]`
4. If you modified `shared/`, also run tests for all dependent packages

---

<!-- =================================================================
     Below: Template for a PACKAGE-LEVEL AGENTS.md
     Copy this into each package directory as packages/<pkg>/AGENTS.md
     ================================================================= -->

# Template: Package-Level AGENTS.md

<!-- Copy this to packages/<pkg>/AGENTS.md and customize -->

## [Package Name]

[One line: what this package does.]

## Commands (this package only)

| Action | Command |
|--------|---------|
| Dev | `[pnpm --filter <pkg> dev]` |
| Test | `[pnpm --filter <pkg> test]` |
| Build | `[pnpm --filter <pkg> build]` |

## Package-Specific Conventions

- [Entry point: `src/index.ts`]
- [Components: `src/components/[Name]/index.tsx`]
- [Tests: colocated `__tests__/` directories]

## Agent Pitfalls

<!-- Package-specific observed failures only -->

## Verification

1. `[pnpm --filter <pkg> lint]`
2. `[pnpm --filter <pkg> test]`
3. `[pnpm --filter <pkg> build]`
