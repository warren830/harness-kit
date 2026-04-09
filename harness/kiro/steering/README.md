---
name: Kiro Steering Template Guide
description: Persistent knowledge files that guide Kiro's behavior. Four inclusion modes for progressive disclosure.
when_to_use: Any project using Kiro.
when_not_to_use: If you only use Claude Code, see harness/claude-code/ instead.
---

# Kiro Steering System

## What Is Steering?

Steering files are Markdown files in `.kiro/steering/` that provide persistent knowledge to Kiro. They shape every interaction without you repeating instructions.

Think of them as Kiro's equivalent of CLAUDE.md + Skills combined — but with a more granular loading system.

## Four Inclusion Modes

| Mode | YAML Frontmatter | When It Loads | Use For |
|------|-----------------|---------------|---------|
| **always** | `inclusion: always` | Every interaction | Core conventions, tech stack, structure |
| **fileMatch** | `inclusion: fileMatch` + `fileMatchPattern` | When working with matching files | Module-specific rules (API, tests, UI) |
| **auto** | `inclusion: auto` + `name` + `description` | When Kiro judges it's relevant | Domain knowledge (design patterns, debugging) |
| **manual** | `inclusion: manual` | Only when you type `#filename` | Troubleshooting guides, rare workflows |

## Comparison with Claude Code

| Concept | Kiro | Claude Code |
|---------|------|-------------|
| Always-loaded rules | `inclusion: always` | CLAUDE.md |
| Path-specific rules | `inclusion: fileMatch` | `.claude/rules/` with `paths:` |
| On-demand knowledge | `inclusion: auto` | Skills |
| Manual invocation | `inclusion: manual` (#reference) | Skills (`/skill-name`) |
| File references | `#[[file:path]]` | `@path` |

## Foundation: The Three-File Starter

Kiro auto-generates three core files. We provide enhanced templates:

| File | Purpose | Mode |
|------|---------|------|
| `product.md` | What the product does, who it's for, key features | always |
| `tech.md` | Tech stack, dev setup, commands | always |
| `structure.md` | Directory layout, naming conventions, architecture | always |

These three files give Kiro baseline context for every interaction.

## Installation

```bash
# Copy templates to your project
mkdir -p .kiro/steering
cp harness-kit/harness/kiro/steering/product.md.template .kiro/steering/product.md
cp harness-kit/harness/kiro/steering/tech.md.template .kiro/steering/tech.md
cp harness-kit/harness/kiro/steering/structure.md.template .kiro/steering/structure.md

# Add optional domain-specific steering
cp harness-kit/harness/kiro/steering/api-design.md .kiro/steering/
cp harness-kit/harness/kiro/steering/testing-patterns.md .kiro/steering/
cp harness-kit/harness/kiro/steering/debugging-guide.md .kiro/steering/
```

Or use `harness-kit init --tools kiro` to generate automatically.

## AGENTS.md Integration

Kiro auto-detects AGENTS.md at the project root. This means:
- Your AGENTS.md universal rules are always available to Kiro
- Steering files provide Kiro-specific enhancements on top
- No need to duplicate AGENTS.md content in steering files

```
AGENTS.md               ← auto-detected, always loaded (no inclusion modes)
.kiro/steering/
  product.md             ← inclusion: always
  tech.md                ← inclusion: always
  structure.md           ← inclusion: always
  api-design.md          ← inclusion: auto (loaded when working on APIs)
  testing-patterns.md    ← inclusion: auto (loaded when writing tests)
  debugging-guide.md     ← inclusion: manual (loaded when you type #debugging-guide)
```

## Best Practices

- **One domain per file** — don't mix API rules with testing patterns
- **Descriptive filenames** — `api-rest-conventions.md` not `rules1.md`
- **Explain WHY** — Kiro follows rules better when it understands the rationale
- **Include code examples** — before/after comparisons are especially effective
- **Link live files** — use `#[[file:path]]` to reference real code
- **Maintain regularly** — outdated steering causes agent confusion
