---
name: AGENTS.md Writing Guide (Quick Reference)
description: One-page cheat sheet for error-driven writing. For the full guide, see guides/error-driven-writing.md.
---

# AGENTS.md Writing Guide — Quick Reference

## The Loop

```
Observe agent fail → Diagnose why → Write ONE rule → Verify it works → Repeat
```

## Diagnosis Table

| Agent did... | Root cause | Fix |
|---|---|---|
| Ran wrong command | Missing info | Add correct command to AGENTS.md |
| Looked for file that doesn't exist | Missing info | Add "does not exist" note |
| Violated architecture boundary | Missing constraint | Add linter rule + AGENTS.md note |
| Couldn't verify its work | Missing tool | Create script, add to Verification |
| Forgot project convention | Missing context | Add to File Conventions section |

## Good Rule Checklist

- [ ] Based on an observed failure (not a guess)
- [ ] Specific (exact paths, commands, patterns)
- [ ] Minimal (one problem, one line)
- [ ] Not discoverable from config files
- [ ] Verified to fix the original failure

## DO Write

```markdown
- Use pnpm, not npm
- Tests: `pnpm test -- --watchAll=false` (not watch mode)
- No unit tests in src/legacy/. Don't try to run them.
- Components go in src/components/[Name]/index.tsx
```

## DON'T Write

```markdown
- Write clean, readable code          ← generic, agent already knows
- Handle errors appropriately          ← vague, not actionable
- The agent might use deprecated APIs  ← speculative, not observed
- Use TypeScript strict mode           ← discoverable from tsconfig.json
```

## Size Guide

| Lines | Status |
|-------|--------|
| 0-5 | Just starting — normal |
| 5-30 | Growing from real usage — healthy |
| 30-100 | Well-established project — ideal |
| 100-200 | Consider splitting into sub-directory AGENTS.md files |
| 200+ | Too long — agent adherence drops, split or prune |

Full methodology: [guides/error-driven-writing.md](../../guides/error-driven-writing.md)
