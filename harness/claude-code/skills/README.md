---
name: Claude Code Skills Template Guide
description: Progressive disclosure system — agent loads specialized knowledge only when needed.
when_to_use: Projects where context window bloat is a concern, or where tasks require specialized knowledge.
when_not_to_use: If your HARNESS.md is under 50 lines, you probably don't need skills yet.
---

# Claude Code Skills

## What Are Skills?

Skills are loadable instruction sets that Claude Code loads **on demand**, not at every session start. This prevents context window bloat while keeping specialized knowledge available.

```
Without Skills: All knowledge loaded upfront → context fills fast → performance drops
With Skills:    HARNESS.md loaded always, skills loaded when relevant → lean context → better performance
```

LangChain found that Claude Code achieved **82% task completion with skills vs. 9% without**.

## Key Design Principles

### 1. Twelve consolidated > twenty fragmented

LangChain's testing showed 12 well-structured skills outperform 20 fragmented ones. Each skill should cover a **cohesive domain**, not a single command.

### 2. Skills complement HARNESS.md, they don't replace it

```
HARNESS.md:  "Run tests with `npm test -- --watchAll=false`"     ← always loaded
Skill:      Full debugging methodology with 15 steps             ← loaded when debugging
```

Put frequently-needed facts in HARNESS.md. Put detailed methodologies in Skills.

### 3. Under 2% of context window per skill

Claude Code allocates ~2% of the context window budget for skills. Keep each skill focused. If a skill is too long, split it.

## Installation

1. Copy desired skill `.md` files to your project's `.claude/skills/` directory
2. Customize the content for your project (replace placeholders)
3. Skills are automatically discovered by Claude Code

```bash
mkdir -p .claude/skills
cp harness-kit/harness/claude-code/skills/code-review.md .claude/skills/
cp harness-kit/harness/claude-code/skills/debugging.md .claude/skills/
# ... copy whichever skills you need
```

## Available Skills (12)

### Core (start with these)

| Skill | File | When It Loads |
|-------|------|---------------|
| Code Review | `code-review.md` | When reviewing code or PRs |
| Debugging | `debugging.md` | When investigating bugs or errors |
| Refactoring | `refactoring.md` | When restructuring code |
| Test Writing | `test-writing.md` | When creating or updating tests |
| API Design | `api-design.md` | When creating or modifying API endpoints |
| CI Fix | `ci-fix.md` | When fixing CI/CD pipeline failures |

### Extended (add as needed)

| Skill | File | When It Loads |
|-------|------|---------------|
| Security Audit | `security-audit.md` | When reviewing code for security |
| Performance Optimization | `performance-opt.md` | When optimizing speed or resources |
| Database Migration | `database-migration.md` | When changing database schema |
| Documentation Writing | `doc-writing.md` | When writing or updating docs |
| UI Implementation | `ui-implementation.md` | When building UI components |
| Entropy Cleanup | `entropy-cleanup.md` | When cleaning up drift and debt |

## Recommended Starting Set

**Most projects**: Start with 3-4 skills, add more as needed.

```
.claude/skills/
  code-review.md       ← Every project needs this
  debugging.md         ← Most common task
  test-writing.md      ← Ensures quality
```
