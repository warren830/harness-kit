# Dual-Tool Workflow: Claude Code + Kiro

> How to use both tools together for maximum effectiveness.

---

## The Principle

**Kiro plans. Claude Code executes.**

Not always — both can do both. But their strengths align with this division:

- **Kiro** excels at structured planning (Specs), context-aware guidance (auto-steering), and requirements-driven development
- **Claude Code** excels at deterministic enforcement (Hooks), deep expertise (Skills), multi-file operations (subagents), and long-running tasks

## The Shared Bridge: AGENTS.md

Both tools read the same AGENTS.md:

```
AGENTS.md ──→ Kiro (auto-detected)
          └──→ Claude Code (via CLAUDE.md @import)
```

When you add a line to AGENTS.md based on an observed failure, both tools benefit immediately.

## Recommended Workflow by Task Type

### Building a New Feature

```
Phase 1 (Kiro):
  1. Describe the feature to Kiro
  2. Kiro generates Spec → requirements.md → design.md → tasks.md
  3. Review and refine with Kiro

Phase 2 (Claude Code or Kiro):
  4. Execute tasks one at a time
  5. Claude Code's Stop hook ensures tests pass after each step
  6. Claude Code's Skills provide deep knowledge (API design, security, etc.)

Phase 3 (Claude Code):
  7. Code review using code-review Skill
  8. Run full verification: lint + test + build
```

### Fixing a Bug

```
Option A (Kiro): Use Bugfix Spec
  1. Describe bug → Kiro generates bugfix.md
  2. Review current/expected/unchanged behavior analysis
  3. Execute fix tasks

Option B (Claude Code): Direct debugging
  1. Use debugging Skill → systematic root cause analysis
  2. Stop hook prevents declaring "done" without passing tests
```

### Refactoring

```
Claude Code (recommended):
  1. refactoring Skill guides safe restructuring
  2. Stop hook ensures tests pass after every change
  3. Subagents handle parallel exploration if needed
```

### Documentation

```
Kiro (recommended):
  1. Auto-steering loads relevant context based on what you're documenting
  2. doc-writing steering pattern for consistency
  3. Manual steering (#debugging-guide) for specialized docs
```

### Code Review

```
Claude Code (recommended):
  1. code-review Skill provides systematic checklist
  2. Can spawn parallel review subagents for large PRs
```

### Entropy Cleanup

```
Claude Code (recommended):
  1. entropy-cleanup Skill guides the process
  2. Can run as background agent
  3. harness-kit scan provides the issue list
```

## Daily Workflow Pattern

```
Morning:
  ├── Check harness-kit scan results (if scheduled)
  ├── Review overnight agent work (if background agents ran)
  └── Plan today's work

Feature work:
  ├── Open Kiro → Create Spec for new feature
  ├── Review generated requirements + design
  ├── Switch to Claude Code → Execute implementation tasks
  ├── Claude Code hooks enforce quality automatically
  └── Return to Kiro for next feature

Bug reports:
  ├── Quick bugs → Claude Code + debugging Skill
  └── Complex bugs → Kiro Bugfix Spec → systematic analysis

End of day:
  ├── Update AGENTS.md with any new observed failures
  └── Kick off background agents if applicable (Claude Code)
```

## What NOT to Do

- **Don't duplicate rules** — AGENTS.md is the single source; don't copy content into both CLAUDE.md and .kiro/steering/
- **Don't use Kiro Specs for trivial changes** — one-line fixes don't need requirements → design → tasks
- **Don't ignore the Stop hook** — if Claude Code can't stop because tests fail, fix the tests, don't disable the hook
- **Don't context-switch constantly** — pick one tool per task, don't switch mid-task

## Scaffold

Copy the ready-to-use dual-tool scaffold:

```bash
cp -r harness-kit/templates/combo/scaffold/* ~/my-project/
```

This gives you: AGENTS.md + CLAUDE.md + .kiro/steering/ — the minimum viable dual-tool setup.
