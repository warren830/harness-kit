---
name: Claude Code + Kiro Dual-Tool Collaboration
description: How to use both tools together with a shared AGENTS.md as the bridge.
---

# Claude Code + Kiro: Dual-Tool Setup

## Architecture

```
AGENTS.md (shared bridge)
  │
  ├── Kiro reads automatically (auto-detected at project root)
  │     + .kiro/steering/ (Kiro-specific enhancements)
  │     + .kiro/specs/ (structured feature development)
  │
  └── Claude Code reads via @import
        CLAUDE.md (@AGENTS.md)
        + .claude/hooks/ (deterministic enforcement)
        + .claude/skills/ (progressive disclosure)
        + .claude/rules/ (path-specific context)
```

## Why Use Both?

They complement each other — different strengths for different phases:

| Development Phase | Best Tool | Why |
|-------------------|-----------|-----|
| Requirements & planning | **Kiro** | Specs system (requirements → design → tasks) |
| Technical design | **Kiro** | Structured design docs with auto-generated outlines |
| Implementation (complex) | **Claude Code** | Hooks enforce verification, Skills provide deep knowledge |
| Implementation (simple) | Either | Both work well for straightforward coding |
| Code review | **Claude Code** | Multi-agent parallel review, code-review Skill |
| Debugging | **Claude Code** | /investigate pattern, debugging Skill, subagent isolation |
| Documentation | **Kiro** | Auto-steering matches docs context automatically |
| Entropy cleanup | **Claude Code** | Background agents, entropy-cleanup Skill |

## Quick Setup

```bash
# Generate dual-tool harness
harness-kit init --tools both --level 2

# Or copy the scaffold manually
cp -r harness-kit/harness/combo/scaffold/* ~/my-project/
```

## File Layout

See `scaffold/` directory for a ready-to-use example.
