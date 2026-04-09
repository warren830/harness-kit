---
inclusion: always
---
# Repository Structure — harness-kit v0.2

```
harness-kit/
├── HARNESS.md                    # Universal rules (read by both Claude Code and Kiro)
├── CLAUDE.md                    # Claude Code specific config (@imports HARNESS.md)
├── .kiro/steering/              # Kiro steering files (this directory)
│
├── concepts/                    # Theory & methodology (WHY and WHAT)
│   ├── getting-started.md       # Quick start guide
│   ├── harness-philosophy.md    # Three generations of AI engineering
│   ├── error-driven-methodology.md  # Core methodology
│   ├── fowler-framework-guide.md    # Guides/Sensors dual-control framework
│   ├── autonomy-grading-guide.md    # 4-level autonomy model
│   ├── verification-pyramid-guide.md # Verification layering
│   ├── context-budget-guide.md      # 40% context ceiling
│   ├── claude-code-guide.md     # Claude Code platform guide
│   ├── kiro-guide.md            # Kiro platform guide
│   └── ...                      # anti-patterns, feedback-loops, etc.
│
├── harness/                     # Copy-paste-ready templates (HOW and DO IT)
│   ├── universal/               # Cross-platform templates
│   │   ├── harness-md/           # HARNESS.md templates (starter/standard/advanced)
│   │   ├── knowledge-base/      # Docs structure (ARCHITECTURE, QUALITY, etc.)
│   │   ├── constraints/         # Architectural constraint templates
│   │   └── entropy/             # Entropy management templates
│   ├── claude-code/             # Claude Code specific
│   │   ├── hooks/               # PreToolUse, PostToolUse, Stop hooks
│   │   ├── skills/              # 13 progressive-disclosure skills
│   │   └── rules/               # Path-specific .claude/rules/ templates
│   ├── kiro/                    # Kiro specific
│   │   ├── steering/            # Steering templates (always/auto/manual modes)
│   │   ├── specs/               # Feature + Bugfix spec templates
│   │   └── hooks/               # Kiro hook templates
│   ├── combo/                   # Claude Code + Kiro dual-tool scaffold
│   ├── environments/            # Isolation scripts (worktree, docker)
│   └── ci/                      # CI/CD workflow templates
│
├── tools/
│   ├── harness-init/            # Interactive scaffolding tool
│   ├── harness-score/           # Maturity assessment tool
│   └── entropy-scanner/         # Documentation drift + rule conflict detector
│
└── research/                    # Read-only research materials
```

## Key Relationships
- `concepts/` teaches WHY; `harness/` provides HOW — they cross-reference each other
- `HARNESS.md` is imported by `CLAUDE.md` via `@HARNESS.md`
- `HARNESS.md` is auto-detected by Kiro when placed at project root
- `harness/universal/` content works with any AI coding tool
- `harness/claude-code/` and `harness/kiro/` extend universal with platform capabilities
- `tools/` reads templates from `harness/` via preset YAML files
