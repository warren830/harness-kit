# Getting Started with harness-kit

> Set up your first AI agent harness in 5 minutes.

---

## Prerequisites

- Python 3.11+
- An existing project you want to add a harness to
- One of: Claude Code, Kiro, or both

## Step 1: Install harness-kit

```bash
pip install harness-kit
# or
pipx install harness-kit
```

## Step 2: Initialize your project's harness

```bash
# Interactive mode (recommended for first time)
harness-kit init ~/my-project/

# Or non-interactive
harness-kit init ~/my-project/ --tools both --type web-app --level 2
```

The init wizard asks three questions:

| Question | Options | Recommendation |
|----------|---------|----------------|
| Which AI tools? | `claude-code`, `kiro`, `both` | Start with what you use daily |
| Project type? | `web-app`, `api-service`, `cli-tool`, `data-pipeline`, `ml-project` | Pick the closest match |
| Harness level? | 1 (rules only), 2 (+constraints), 3 (full) | Start with **2** |

### What gets generated

**Level 1** (rules only):
```
AGENTS.md           — Universal agent instructions
CLAUDE.md           — Claude Code config (if selected)
.kiro/steering/     — Kiro config (if selected)
docs/ARCHITECTURE.md — Architecture doc skeleton
```

**Level 2** (+constraints):
```
... everything from Level 1, plus:
.claude/hooks/require-tests.sh  — Stop hook: must pass tests
.claude/hooks/auto-lint.sh      — PostToolUse hook: auto-lint
```

**Level 3** (full):
```
... everything from Level 2, plus:
.claude/settings.json  — Hooks wiring config
```

## Step 3: Customize AGENTS.md

Open the generated `AGENTS.md`. You'll see placeholders in `[brackets]`:

```markdown
# AGENTS.md

A web application built with [framework].      ← Replace this
Tech stack: [Next.js/React], [TypeScript]...    ← Replace this
```

Replace all `[brackets]` with your project's real information. **But leave "Agent Pitfalls" empty** — that section grows from real observations.

## Step 4: Start using your AI agent

Use Claude Code or Kiro as you normally would. When the agent makes a mistake:

1. Note what went wrong
2. Add one line to the "Agent Pitfalls" section of AGENTS.md
3. Re-run the same task — verify the mistake doesn't happen again

This is **error-driven writing** — the core methodology. See [error-driven-writing.md](error-driven-writing.md) for the full guide.

## Step 5: Check your progress

```bash
# See how your harness scores
harness-kit score ~/my-project/

# Detect entropy (stale rules, unfilled placeholders)
harness-kit scan ~/my-project/
```

## What's Next?

After your basic harness is running:

| Your score | Next step | Guide |
|-----------|-----------|-------|
| Level 1-2 | Add Hooks (verification gates) | [claude-code-harness.md](claude-code-harness.md) |
| Level 2-3 | Add Skills (progressive context) | [claude-code-harness.md](claude-code-harness.md) |
| Level 3-4 | Add Kiro Specs (structured planning) | [kiro-harness.md](kiro-harness.md) |
| Level 4-5 | Set up entropy management | Templates in `templates/universal/entropy/` |
| Level 5+ | Multi-agent workflows | [dual-tool-workflow.md](dual-tool-workflow.md) |

## Common Questions

**Q: Do I need both Claude Code and Kiro?**
No. Start with whatever you use. Add the other later if needed. AGENTS.md works with both.

**Q: My project doesn't match any preset type. What do I do?**
Pick the closest one, then customize. The presets are starting points, not constraints.

**Q: How long until I see results?**
The first improvement comes from AGENTS.md alone — usually within the first few agent tasks. Hooks provide the next big jump. Most teams see measurable improvement within a week.

**Q: Can I use this with Cursor/Copilot?**
AGENTS.md is recognized by Cursor and Copilot. The hooks and skills templates are Claude Code-specific for now. Other platform support is planned.
