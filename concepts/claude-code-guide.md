# Claude Code Harness: Complete Guide

> Everything you need to build a production-grade harness for Claude Code.

---

## Overview

Claude Code's harness has three layers, from most to least deterministic:

```
Hooks (deterministic)     ← Shell scripts, run every time, cannot be bypassed
  ↓
Rules (path-specific)     ← Loaded when working with matching files
  ↓
Skills (on-demand)        ← Loaded when the task matches the skill's domain
  ↓
CLAUDE.md (always loaded) ← Probabilistic guidelines (~90% followed)
  ↓
HARNESS.md (imported)      ← Universal rules, shared with other tools
```

## Quick Setup

```bash
# Generate all Claude Code harness files
harness-kit init --tools claude-code --level 3

# Or manually:
# 1. Copy CLAUDE.md template
# 2. Copy hooks to .claude/hooks/
# 3. Copy skills to .claude/skills/
# 4. Copy rules to .claude/rules/
```

## Layer 1: CLAUDE.md + HARNESS.md

CLAUDE.md is loaded at every session start. It imports HARNESS.md for universal rules and adds Claude-specific config.

```markdown
# CLAUDE.md
@HARNESS.md                    ← imports universal rules

## Claude Code Configuration
- Don't auto-commit without confirmation
- Use Sonnet for routine tasks, Opus for architecture
- When compacting, preserve modified file list
```

**Template**: `harness/claude-code/CLAUDE.md.template`

**Key points**:
- Keep CLAUDE.md under 200 lines (longer = lower adherence)
- Move detailed instructions to Skills (loaded on-demand, saves context)
- Use `@path/to/file` to import other instruction files (max 5 hops)

## Layer 2: Hooks (Deterministic Enforcement)

Hooks are shell scripts that fire at lifecycle events. They CANNOT be bypassed by the model.

### The Most Important Hook: Stop Gate

```bash
# .claude/hooks/require-tests.sh
# Forces agent to pass tests before it can stop
if ! npm test -- --watchAll=false >/dev/null 2>&1; then
  echo '{"decision":"block","reason":"Tests failing. Fix before stopping."}'
else
  exit 0
fi
```

This single hook transforms agent behavior from "maybe verify" to "always verify."

### Recommended Hook Stack

| Priority | Hook | What It Does |
|----------|------|-------------|
| **Must have** | `stop/require-tests.sh` | Agent can't stop without passing tests |
| Should have | `pre-tool-use/block-destructive.sh` | Blocks rm -rf, force push, DROP TABLE |
| Should have | `post-tool-use/auto-lint.sh` | Lints every file after edit |
| Nice to have | `pre-tool-use/restrict-paths.sh` | Protects sensitive directories |
| Nice to have | `post-tool-use/auto-format.sh` | Formats every file after edit |
| Nice to have | `stop/require-lint.sh` | Agent can't stop with lint errors |

### Configuration

Wire hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {"type": "command", "command": "bash .claude/hooks/block-destructive.sh"}
    ],
    "PostToolUse": [
      {"type": "command", "command": "bash .claude/hooks/auto-lint.sh"}
    ],
    "Stop": [
      {"type": "command", "command": "bash .claude/hooks/require-tests.sh"}
    ]
  }
}
```

**Templates**: `harness/claude-code/hooks/`

## Layer 3: Path-Specific Rules

Rules in `.claude/rules/` load only when Claude works with matching files. This is progressive disclosure — don't load API rules when editing UI code.

```yaml
# .claude/rules/api-rules.md
---
paths:
  - "src/api/**"
  - "src/routes/**"
---
# API Development Rules
- All endpoints must validate input with a schema
- All endpoints must check auth
- Error responses must follow project format
```

**Available templates**:
- `rules/api-rules.md` — API endpoint conventions
- `rules/test-rules.md` — Test writing patterns
- `rules/ui-rules.md` — UI component guidelines

**Templates**: `harness/claude-code/rules/`

## Layer 4: Skills (Progressive Disclosure)

Skills are loaded on-demand when the task matches. They keep specialized knowledge available without bloating every session.

```
.claude/skills/
  code-review.md          ← loaded when reviewing code
  debugging.md            ← loaded when investigating bugs
  refactoring.md          ← loaded when restructuring code
  test-writing.md         ← loaded when creating tests
  api-design.md           ← loaded when working on APIs
  ci-fix.md               ← loaded when fixing CI failures
  security-audit.md       ← loaded when reviewing security
  performance-opt.md      ← loaded when optimizing
  database-migration.md   ← loaded when changing schema
  doc-writing.md          ← loaded when writing docs
  ui-implementation.md    ← loaded when building UI
  entropy-cleanup.md      ← loaded when cleaning up drift
```

### Design Principle: 12 Consolidated > 20 Fragmented

LangChain tested this: fewer, broader skills outperform many narrow ones. Each skill should cover a cohesive domain.

**Templates**: `harness/claude-code/skills/`

## Putting It All Together

A fully harnessed Claude Code project:

```
my-project/
├── HARNESS.md                          ← Universal rules (shared with Kiro)
├── CLAUDE.md                          ← Claude config (@imports HARNESS.md)
├── .claude/
│   ├── settings.json                  ← Hooks wiring
│   ├── hooks/
│   │   ├── block-destructive.sh       ← PreToolUse: safety
│   │   ├── restrict-paths.sh          ← PreToolUse: boundaries
│   │   ├── auto-lint.sh              ← PostToolUse: quality
│   │   ├── auto-format.sh            ← PostToolUse: consistency
│   │   ├── require-tests.sh          ← Stop: verification gate
│   │   └── require-lint.sh           ← Stop: quality gate
│   ├── rules/
│   │   ├── api-rules.md              ← Loaded for src/api/**
│   │   ├── test-rules.md             ← Loaded for **/*.test.*
│   │   └── ui-rules.md               ← Loaded for src/components/**
│   └── skills/
│       ├── code-review.md
│       ├── debugging.md
│       ├── refactoring.md
│       ├── test-writing.md
│       └── ... (12 total)
├── docs/
│   ├── ARCHITECTURE.md
│   ├── QUALITY.md
│   ├── BELIEFS.md
│   └── TECH-DEBT.md
└── src/
    └── ... your code ...
```

## Maturity Progression

| Week | Add | Impact |
|------|-----|--------|
| 1 | HARNESS.md + CLAUDE.md | Agent knows your project basics |
| 2 | Stop hook (require-tests) | Agent verifies its own work |
| 2 | PreToolUse hook (block-destructive) | Agent can't break things |
| 3 | PostToolUse hook (auto-lint) | Code quality maintained automatically |
| 3 | 3-4 Skills (review, debug, test, refactor) | Agent has specialized knowledge |
| 4 | Path-specific rules (API, test, UI) | Context-appropriate guidance |
| 4+ | Grow HARNESS.md from observed failures | Harness improves every day |
