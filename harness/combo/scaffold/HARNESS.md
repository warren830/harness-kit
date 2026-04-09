# HARNESS.md

> Shared rules for all AI coding agents. Both Kiro and Claude Code read this file.

[Project name]: [One sentence description]. Built with [tech stack].

## Commands

| Action | Command |
|--------|---------|
| Install | `[pnpm install]` |
| Dev | `[pnpm dev]` |
| Test | `[pnpm test -- --watchAll=false]` |
| Lint | `[pnpm lint]` |
| Type check | `[pnpm tsc --noEmit]` |
| Build | `[pnpm build]` |

## Architecture

```
[src/
  components/   — UI components
  services/     — Business logic
  repositories/ — Database access
  types/        — Type definitions]
```

Dependencies flow down only: UI → Services → Repositories → Types.

## Agent Pitfalls

<!-- Add one line per observed mistake. Grows over time. -->

## What Does NOT Exist

<!-- Things agents look for that don't exist here. -->

## Verification

1. `[pnpm lint]` — zero errors
2. `[pnpm test -- --watchAll=false]` — all pass
3. `[pnpm tsc --noEmit]` — no type errors
