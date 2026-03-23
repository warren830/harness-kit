---
name: AGENTS.md Standard Template
description: For most projects. ~100 lines. Structured as a "table of contents" that points to deeper docs.
when_to_use: Projects with 2+ developers, established conventions, and regular AI agent usage.
when_not_to_use: Tiny personal projects (use minimal.md) or massive monorepos (use monorepo.md).
---

<!-- =================================================================
     AGENTS.md Standard Template — harness-kit

     HOW TO USE:
     1. Copy this file to your project root as AGENTS.md
     2. Replace ALL content in [brackets] with your project's real info
     3. Delete sections you don't need
     4. Delete all <!-- comments --> when done
     5. IMPORTANT: Don't fill in "Agent Pitfalls" yet —
        let it grow from real observed failures (error-driven writing)

     TARGET: ~60-100 lines after customization.
     PRINCIPLE: Table of contents, not encyclopedia.
     ================================================================= -->

# AGENTS.md

## Project Overview

[One sentence: what this project does.]

Tech stack: [e.g., Next.js 14, TypeScript, PostgreSQL, Prisma, Tailwind CSS]

## Commands

<!-- Only list commands agents actually need. Delete unused rows. -->

| Action | Command | Notes |
|--------|---------|-------|
| Install | `[pnpm install]` | [Do NOT use npm or yarn] |
| Dev server | `[pnpm dev]` | [Runs on port 3000] |
| Test | `[pnpm test -- --watchAll=false]` | [Must pass before committing] |
| Lint | `[pnpm lint]` | [Zero errors required] |
| Type check | `[pnpm tsc --noEmit]` | |
| Build | `[pnpm build]` | [Must succeed before PR] |
| DB migrate | `[pnpm prisma migrate dev]` | [Generates client automatically] |

## Architecture

<!-- Keep this brief. Point to docs/ARCHITECTURE.md for details. -->

```
[src/
  app/          — Next.js App Router pages and API routes
  components/   — React UI components
  services/     — Business logic
  repositories/ — Database access (Prisma)
  lib/          — Shared utilities
  types/        — TypeScript type definitions]
```

**Dependency rules** (enforced by linter):
- [UI → Services → Repositories → Types (never reverse)]
- [Components must NOT import from repositories/ directly]
- [All DB access goes through repositories/]

For full architecture docs, see `docs/ARCHITECTURE.md`.

## File Conventions

- [Components: `src/components/[Name]/index.tsx` + `[Name].test.tsx`]
- [API routes: `src/app/api/[resource]/route.ts`]
- [Services: `src/services/[name].service.ts`]
- [Types: `src/types/[name].types.ts`]
- [Tests: colocated with source in `__tests__/` subdirectories]

## Environment

- [`.env.local` for local dev (not `.env`)]
- [Never commit `.env.local` — copy from `.env.example`]
- [Required env vars: DATABASE_URL, NEXT_PUBLIC_API_URL]

## Agent Pitfalls (Error-Driven)

<!-- ⚠️  DO NOT pre-fill this section.
     Start empty. Add one line each time you observe the agent making a mistake.
     See guides/error-driven-writing.md for the methodology.

     Example entries (delete these, add your own from real observations):
     - Do NOT use `npm` — this project uses `pnpm`
     - Tests in src/legacy/ don't exist. Don't try to create or run them.
     - The config/ directory is auto-generated. Never edit files in it.
     - Use `--watchAll=false` with test command to prevent watch mode.
-->

## What Does NOT Exist

<!-- List things the agent commonly looks for but that don't exist in your project.
     This prevents the agent from wasting time searching.

     Example entries (replace with your own):
     - No docker-compose.yml. The app runs directly on the host.
     - No GraphQL. All APIs are REST.
     - No Storybook. Components are tested with Jest + Testing Library.
-->

## Documentation Map

<!-- Point the agent to deeper docs instead of putting everything here. -->

- Architecture: `docs/ARCHITECTURE.md`
- [Design docs: `docs/designs/`]
- [API specs: `docs/api/`]
- [Technical debt: `docs/TECH-DEBT.md`]

## Verification Checklist

<!-- This is critical. The agent must verify its own work before declaring done. -->

After modifying code, run in this order:
1. `[pnpm lint]` — zero errors
2. `[pnpm test -- --watchAll=false]` — all tests pass
3. `[pnpm tsc --noEmit]` — no type errors
4. `[pnpm build]` — builds successfully

If any step fails, fix and re-run from step 1.
