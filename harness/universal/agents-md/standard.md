---
name: "AGENTS.md Standard"
description: For team projects with established conventions. ~80 lines.
when_to_use: Multi-contributor projects with CI, code review, and shared conventions.
when_not_to_use: Solo projects (use starter.md) or monorepos with 3+ packages (use monorepo.md).
---

<!-- Copy to your project root as AGENTS.md.
     Replace ALL [brackets] with real values. Delete unused sections.
     The "Pitfalls" section starts empty — grow it from observed failures only.
     Target: ~60-80 lines after customization. -->

# AGENTS.md

[Project name]: [One sentence description].

Tech stack: [e.g., Next.js 14, TypeScript 5.4, PostgreSQL 16, Prisma 5, Tailwind CSS 3]

## Commands

<!-- Commands go first — agents reference these most frequently. -->

```bash
[pnpm install]                    # install — do NOT use npm or yarn
[pnpm dev]                        # dev server on port 3000
[pnpm test -- --watchAll=false]   # test — disable watch mode
[pnpm lint]                       # lint — zero errors required
[pnpm tsc --noEmit]               # type check
[pnpm build]                      # build — must pass before PR
[pnpm prisma migrate dev]         # db migrate — also generates client
```

## Boundaries

<!-- Three tiers: Always / Ask First / Never. Be specific. -->

Always:
- Run the full verification checklist before declaring work done
- Write tests for new business logic in [src/services/]
- Use existing patterns in the codebase — check 2-3 similar files first

Ask first:
- Adding new dependencies to package.json
- Modifying database schema or migrations
- Changing API response shapes (breaking changes)
- Deleting any file

Never:
- Commit .env.local or any file matching .env*
- Modify files in [config/generated/] — these are auto-generated
- Run `prisma migrate reset` — destroys local data
- Skip the type check step (`tsc --noEmit`)

## Code Style

<!-- Show patterns with examples — examples >> descriptions. -->

```typescript
// File naming: src/services/[name].service.ts
// Good:
import { UserService } from "@/services/user.service";

// Bad — never import repositories from components:
import { UserRepo } from "@/repositories/user.repo"; // WRONG in components
```

```typescript
// Error handling: always use Result type, never throw in services
// Good:
function createUser(data: Input): Result<User, ValidationError> { ... }

// Bad:
function createUser(data: Input): User { throw new Error(...) } // WRONG
```

## File Conventions

- [Components: `src/components/[Name]/index.tsx` + `[Name].test.tsx`]
- [API routes: `src/app/api/[resource]/route.ts`]
- [Services: `src/services/[name].service.ts`]
- [Tests: colocated in `__tests__/` subdirectories]

## What Does NOT Exist

<!-- Prevents the agent from searching for things that aren't there. -->

- [No GraphQL — all APIs are REST]
- [No Storybook — components tested with Jest + Testing Library]
- [No Docker — app runs directly on host for local dev]

## Pitfalls

<!-- DO NOT pre-fill. Add one line per observed agent mistake.
     See writing-guide.md for methodology.

     Example entries (replace with real observations):
     - Use `--watchAll=false` with test command or it hangs in watch mode
     - The migrations/ dir is checked in — do NOT regenerate from scratch
     - Shared types live in src/types/, not in individual component dirs -->

## Verification

After modifying code, run in order:
```bash
[pnpm lint]                       # 1. zero lint errors
[pnpm test -- --watchAll=false]   # 2. all tests pass
[pnpm tsc --noEmit]               # 3. no type errors
[pnpm build]                      # 4. build succeeds
```
If any step fails, fix it and re-run from step 1.
