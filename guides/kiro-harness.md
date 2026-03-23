# Kiro Harness: Complete Guide

> Everything you need to build a production-grade harness for Kiro.

---

## Kiro's Three Pillars

```
Steering (knowledge)    ← Persistent context with 4 loading modes
  ↓
Specs (structure)       ← Requirements → Design → Tasks workflow
  ↓
Hooks (automation)      ← Event-triggered actions (lint on save, test after task)
```

## Quick Setup

```bash
harness-kit init --tools kiro --level 2

# Or manually:
mkdir -p .kiro/steering
# Copy steering templates and customize
```

## Pillar 1: Steering

Steering files in `.kiro/steering/` provide persistent knowledge with four loading modes:

### Always-Loaded Foundation (start here)

| File | Content |
|------|---------|
| `product.md` | What the product does, users, business constraints |
| `tech.md` | Tech stack, commands, environment setup |
| `structure.md` | Directory layout, naming conventions, dependency rules |

These load in every interaction. Keep them factual and concise.

### Auto-Loading Domain Knowledge (add as needed)

```yaml
---
inclusion: auto
name: api-design
description: REST API patterns. Use when creating or modifying API endpoints.
---
```

Kiro reads the `description` and loads the file when the task matches. This is Kiro's equivalent of Claude Code Skills.

### Manual-Loading Reference (for rare workflows)

```yaml
---
inclusion: manual
---
```

Load with `#filename` in chat. Good for troubleshooting guides, deployment procedures.

### File-Match Loading (path-specific)

```yaml
---
inclusion: fileMatch
fileMatchPattern: "src/api/**/*"
---
```

Loads when working with matching files. Kiro's equivalent of Claude Code's `.claude/rules/`.

**Templates**: `templates/kiro/steering/`

## Pillar 2: Specs

Kiro's unique differentiator. Specs force structured development:

### Feature Spec Workflow

```
1. Describe the feature in chat
2. Kiro generates requirements.md (user stories + acceptance criteria)
3. You refine requirements
4. Kiro generates design.md (architecture + data flow + API design)
5. You review and approve design
6. Kiro generates tasks.md (discrete, executable steps)
7. Execute tasks one at a time, with verification at each step
```

### Bugfix Spec Workflow

```
1. Describe the bug
2. Kiro generates bugfix.md (current vs. expected vs. unchanged behavior)
3. You confirm the analysis
4. Kiro generates fix tasks with regression test first
```

**Key constraint**: The agent cannot skip phases. Requirements come before design, design before tasks. This prevents the "code first, think later" anti-pattern.

**Templates**: `templates/kiro/specs/`

## Pillar 3: Hooks

Kiro hooks automate repetitive actions:

| Hook | Event | Action |
|------|-------|--------|
| Lint on Save | File saved | Run linter on the saved file |
| Test After Task | Spec task completed | Run test suite to verify the step |

Set up via Command Palette → "Kiro: Open Kiro Hook UI".

**Templates**: `templates/kiro/hooks/`

## AGENTS.md Integration

Kiro auto-detects AGENTS.md at the project root. This means your universal rules are always available without duplication:

```
AGENTS.md                    ← auto-detected, always loaded
.kiro/steering/product.md    ← Kiro-specific product context
.kiro/steering/tech.md       ← Kiro-specific tech details
.kiro/steering/structure.md  ← Kiro-specific structure notes
```

**Don't duplicate AGENTS.md content in steering files.** Reference it instead.

## Full Project Layout

```
my-project/
├── AGENTS.md                          ← Universal rules (auto-detected)
├── .kiro/
│   ├── steering/
│   │   ├── product.md                 ← inclusion: always
│   │   ├── tech.md                    ← inclusion: always
│   │   ├── structure.md               ← inclusion: always
│   │   ├── api-design.md             ← inclusion: auto
│   │   ├── testing-patterns.md       ← inclusion: auto
│   │   └── debugging-guide.md        ← inclusion: manual
│   ├── specs/
│   │   ├── add-user-search/          ← Feature spec
│   │   │   ├── requirements.md
│   │   │   ├── design.md
│   │   │   └── tasks.md
│   │   └── fix-login-timeout/        ← Bugfix spec
│   │       └── bugfix.md
│   └── hooks/                         ← Configured via Hook UI
├── docs/
│   ├── ARCHITECTURE.md
│   └── ...
└── src/
    └── ...
```

## Maturity Progression

| Week | Add | Impact |
|------|-----|--------|
| 1 | AGENTS.md + steering 三件套 | Kiro knows your project basics |
| 2 | Auto-loading steering (api-design, testing) | Context-aware guidance |
| 2 | Lint-on-save hook | Immediate quality feedback |
| 3 | Feature Spec workflow for new features | Structured development |
| 3 | Test-after-task hook | Verified execution |
| 4+ | Grow AGENTS.md from observed failures | Harness improves every day |
