---
name: "HARNESS.md Starter"
description: Minimal HARNESS.md for solo devs, MVPs, and hackathons. ~30 lines.
when_to_use: Solo projects, hackathons, MVPs, or your first HARNESS.md ever.
when_not_to_use: Team projects with shared conventions (use standard.md).
---

<!-- Copy to your project root as HARNESS.md.
     Replace [brackets] with your info, then delete these comments.
     Add lines ONLY when you observe the agent making a mistake. -->

# HARNESS.md

[Project name]: [One sentence description].

## Commands

```bash
[npm install]          # install dependencies
[npm test]             # run tests — must pass before commit
[npm run lint]         # lint — zero errors required
```

## Boundaries

Always: run tests before committing, read existing code before editing
Ask first: deleting files, changing DB schema, adding dependencies
Never: push to main, modify .env files, run destructive DB commands

## Pitfalls

<!-- Start empty. Add one line each time the agent makes a mistake.
     Example entries (replace with real observations):
     - Use `pnpm`, not `npm` — this project uses pnpm workspaces
     - No tests exist in src/legacy/ — don't try to create them
     - Config in config/ is auto-generated — never edit directly -->
