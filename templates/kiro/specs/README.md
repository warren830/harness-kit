---
name: Kiro Specs Template Guide
description: Structured development workflow — requirements → design → tasks. Kiro's unique differentiator.
when_to_use: New features requiring planning, or bugs needing systematic diagnosis.
when_not_to_use: Quick fixes, one-line changes, or exploratory coding ("vibe mode").
---

# Kiro Specs System

## What Are Specs?

Specs are Kiro's structured development workflow. They formalize the three phases of building a feature:

```
Phase 1: Requirements   →   Phase 2: Design   →   Phase 3: Tasks
"What do we need?"           "How do we build it?"    "What are the steps?"
```

Each spec creates a directory under `.kiro/specs/[spec-name]/` with three files.

## When to Use Specs vs. Vibe Mode

| Use Specs | Use Vibe (freeform chat) |
|-----------|------------------------|
| Complex features (5+ files) | Quick exploratory coding |
| Features needing design review | Prototyping without clear goals |
| Bug fixes where regressions are costly | Simple one-file changes |
| Team collaboration needed | Solo experimentation |

## Spec Types

### Feature Specs

Three files:
- `requirements.md` — User stories + acceptance criteria
- `design.md` — Technical architecture + sequence diagrams
- `tasks.md` — Discrete, executable implementation steps

Two workflow variants:
- **Requirements-First** (recommended): Write requirements → Kiro generates design → refine → generate tasks
- **Design-First**: Start with technical design when requirements are already clear

### Bugfix Specs

Two files:
- `bugfix.md` — Current behavior, expected behavior, unchanged behavior
- `tasks.md` — Diagnosis + fix steps

## Templates

### Feature Spec
```
.kiro/specs/[feature-name]/
  requirements.md     ← templates/kiro/specs/feature/requirements.md.template
  design.md           ← templates/kiro/specs/feature/design.md.template
  tasks.md            ← templates/kiro/specs/feature/tasks.md.template
```

### Bugfix Spec
```
.kiro/specs/[bug-name]/
  bugfix.md           ← templates/kiro/specs/bugfix/bugfix.md.template
  tasks.md            ← (generated from bugfix analysis)
```

## How Specs Constrain Agent Behavior

Specs act as a harness by:
1. **Forcing planning before coding** — agent must have a design before implementing
2. **Breaking work into discrete tasks** — each task is verifiable independently
3. **Requiring explicit requirements** — no coding without knowing what "done" looks like
4. **Tracking progress** — tasks show in-progress/completed status

This is Kiro's equivalent of Claude Code's Hooks — structural constraints that force disciplined execution.
