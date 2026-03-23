---
inclusion: always
---
# Repository Structure — harness-kit

```
harness-kit/
├── AGENTS.md                    # Universal rules (read by both Claude Code and Kiro)
├── CLAUDE.md                    # Claude Code specific config (@imports AGENTS.md)
├── .kiro/steering/              # Kiro steering files (this directory)
│
├── templates/
│   ├── universal/               # Cross-platform templates
│   │   ├── agents-md/           # AGENTS.md templates + writing guide
│   │   ├── knowledge-base/      # Docs structure (ARCHITECTURE, QUALITY, PLANS, etc.)
│   │   ├── constraints/         # Architectural constraint templates + linter examples
│   │   └── entropy/             # Entropy management templates
│   ├── claude-code/             # Claude Code specific
│   │   ├── hooks/               # PreToolUse, PostToolUse, Stop hooks
│   │   ├── skills/              # 12 progressive-disclosure skills
│   │   └── rules/               # Path-specific .claude/rules/ templates
│   ├── kiro/                    # Kiro specific
│   │   ├── steering/            # Steering templates (always/auto/manual modes)
│   │   ├── specs/               # Feature + Bugfix spec templates
│   │   └── hooks/               # Kiro hook templates
│   ├── combo/                   # Claude Code + Kiro dual-tool collaboration
│   └── environments/            # Isolation scripts (worktree, docker)
│
├── tools/
│   ├── harness-init/            # Interactive scaffolding tool
│   ├── harness-score/           # Maturity assessment tool
│   └── entropy-scanner/         # Documentation drift + rule conflict detector
│
├── guides/                      # How-to guides and methodology
├── ci/github-actions/           # CI/CD workflow templates
└── research/                    # Read-only research materials
```

## Key Relationships
- `AGENTS.md` is imported by `CLAUDE.md` via `@AGENTS.md`
- `AGENTS.md` is auto-detected by Kiro when placed at project root
- `templates/universal/` content works with any AI coding tool
- `templates/claude-code/` and `templates/kiro/` extend universal content with platform capabilities
- `templates/combo/` provides ready-to-use scaffolds for dual-tool setups
