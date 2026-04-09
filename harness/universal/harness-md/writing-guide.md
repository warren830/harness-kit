---
name: "HARNESS.md Writing Guide"
description: How to write effective HARNESS.md files using error-driven methodology and data-backed rules.
when_to_use: Before writing or revising any HARNESS.md file.
when_not_to_use: N/A — everyone writing HARNESS.md should read this.
---

# HARNESS.md Writing Guide

## The Error-Driven Loop

```
Observe agent fail → Diagnose root cause → Write ONE rule → Verify it works → Repeat
```

Start with a near-empty HARNESS.md. Add rules only when the agent makes a real mistake. Speculative rules ("the agent might do X") add noise and reduce adherence.

For the full methodology, see [error-driven-methodology](error-driven-methodology).

## Rules from GitHub's 2,500-Repo Analysis

### 1. Put commands first

Agents reference commands more than any other section. Put them at the top.

```markdown
<!-- Bad: commands buried after architecture overview -->
## Architecture
(50 lines of description...)
## Commands
npm test

<!-- Good: commands first, with all flags -->
## Commands
npm test -- --watchAll=false    # disable watch mode
```

### 2. Use three-tier boundaries, not prose

```markdown
<!-- Bad: paragraph of instructions -->
Please be careful with the database and always run tests.

<!-- Good: structured boundary tiers -->
## Boundaries
Always: run tests before committing, write tests for new logic
Ask first: adding dependencies, changing DB schema, deleting files
Never: modify .env files, push to main, run DROP commands
```

### 3. Show code examples, not descriptions

```markdown
<!-- Bad: text description of style -->
Use the Result type for error handling in services.

<!-- Good: concrete example -->
// Good:
function getUser(id: string): Result<User, NotFoundError> { ... }
// Bad:
function getUser(id: string): User { throw new Error(...) }
```

### 4. Skip the architecture overview

Agents discover project structure by reading code. Architecture sections add tokens without improving performance. Point to `docs/ARCHITECTURE.md` instead.

### 5. Never auto-generate your HARNESS.md

LLM-generated HARNESS.md files reduce task success by 0.5-2% and increase token cost by 20-23% (GitHub data). Write from observed failures, not AI output.

## Diagnosis Table

| Agent did... | Root cause | Fix |
|---|---|---|
| Ran wrong command | Missing info | Add correct command with flags |
| Looked for nonexistent file | Missing context | Add "What Does NOT Exist" entry |
| Broke architecture boundary | Missing constraint | Add boundary rule + linter |
| Could not verify its work | Missing verification | Add to verification checklist |
| Used wrong pattern | Missing example | Add code example showing right pattern |

## Good Rule Checklist

A rule belongs in HARNESS.md only if ALL of these are true:

- [ ] Based on an observed failure (not a guess)
- [ ] Specific — exact paths, commands, or patterns
- [ ] Minimal — one problem per line
- [ ] Not discoverable from config files (tsconfig, eslint, etc.)
- [ ] Verified to actually fix the original failure

## Size Guide

| Lines | Status | Action |
|-------|--------|--------|
| 0-30 | Starting out | Normal — keep growing from failures |
| 30-80 | Established | Ideal range for most projects |
| 80-150 | Large project | Consider splitting into sub-directory files |
| 150+ | Too long | Agent adherence drops — prune or split |

Research shows performance degrades at ~40% context utilization. A 200+ line HARNESS.md competes with your actual code for context space.

## Anti-Patterns

```markdown
<!-- These reduce performance. Remove if you find them. -->
- "Write clean, readable code"           ← generic, agent already knows
- "Handle errors appropriately"          ← vague, not actionable
- "The agent might use deprecated APIs"  ← speculative, not observed
- "Use TypeScript strict mode"           ← discoverable from tsconfig.json
- "You are a helpful coding assistant"   ← generic persona hurts performance
```
