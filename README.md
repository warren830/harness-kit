# harness-kit

**Don't spend 5 months building your harness from scratch. Start with harness-kit.**

An open-source CLI toolkit for [Harness Engineering](guides/philosophy.md) -- build constraints, feedback loops, and control systems around AI coding agents.

```bash
pip install harness-kit

harness-kit init ~/my-project/        # Generate harness files (auto-detects tech stack)
harness-kit score ~/my-project/       # Assess harness maturity (Level 0-7, Grade F-S)
harness-kit scan ~/my-project/        # Detect entropy (stale rules, doc drift)
```

## Why?

Same model, different harness, dramatically different results:

| Experiment | Without Harness | With Harness | Source |
|---|---|---|---|
| Claude Code task completion | 9% | **82%** | LangChain Skills Test, 2026 |
| Terminal Bench 2.0 ranking | #30 | **#5** | LangChain, GPT-5.2-Codex (model unchanged) |
| OpenAI internal product | 0 lines shipped | **1M lines in 5 months** | OpenAI, 3 engineers, zero hand-written code |
| Stripe weekly output | -- | **1,300+ AI PRs merged/week** | Stripe Minions system |

**The model is commodity. The harness is moat.**

## How It Works

harness-kit is a **generator**, not a dependency. It produces files into your project, then you own them.

```
harness-kit (stays separate)        your-project/
┌──────────────────┐                ┌──────────────────────────┐
│                  │───init──────→  │ AGENTS.md                │
│  64 templates    │                │ CLAUDE.md                │
│  12 skills       │───score─────→  │ .kiro/steering/          │
│  6 hooks         │                │ .claude/hooks/           │
│  9 guides        │───scan──────→  │ .claude/skills/          │
│                  │                │ docs/ARCHITECTURE.md     │
└──────────────────┘                └──────────────────────────┘
```

### Three-Layer Architecture

```
Layer 1: AGENTS.md             Universal rules (Kiro auto-detects, Claude Code @imports)
Layer 2: CLAUDE.md / .kiro/    Platform adapters
Layer 3: Hooks / Skills / Specs  Platform-unique enforcement + knowledge
```

## Quick Start

### 1. Install

```bash
pip install harness-kit
```

### 2. Initialize

```bash
# Interactive (recommended first time)
harness-kit init ~/my-project/

# Non-interactive
harness-kit init ~/my-project/ --tools both --type web-app --level 2

# Auto-detects from pyproject.toml / package.json:
#   project name, tech stack, commands, directory structure
```

### 3. Customize

Edit the generated `AGENTS.md` -- replace `[placeholders]` with your project's real info. **Leave "Agent Pitfalls" empty** -- it grows from observed failures.

### 4. Use your agent, observe, iterate

Every time the agent makes a mistake, add one line to AGENTS.md. This is [error-driven writing](guides/error-driven-writing.md) -- the core methodology.

### 5. Track progress

```bash
harness-kit score ~/my-project/
# Total: 35/70  Grade: C
# Recommendations:
#   > Add: Claude Code Skills (Level 5)
#   > Add: Pre-commit hooks (Level 2)
```

## What's Inside

### Templates (64 files)

| Category | Count | Platforms | Key Files |
|---|---|---|---|
| [AGENTS.md](templates/universal/agents-md/) | 4 | All | minimal, standard, monorepo, writing-guide |
| [Knowledge Base](templates/universal/knowledge-base/) | 7 | All | ARCHITECTURE, QUALITY, BELIEFS, TECH-DEBT, PLANS |
| [Constraints](templates/universal/constraints/) | 2 | All | layer-rules, error-message-design |
| [Entropy](templates/universal/entropy/) | 3 | All | golden-principles, quality-grades, weekly-review |
| [Hooks](templates/claude-code/hooks/) | 8 | Claude Code | block-destructive, auto-lint, require-tests, ... |
| [Skills](templates/claude-code/skills/) | 13 | Claude Code | code-review, debugging, refactoring, test-writing, ... |
| [Rules](templates/claude-code/rules/) | 3 | Claude Code | api-rules, test-rules, ui-rules |
| [Steering](templates/kiro/steering/) | 7 | Kiro | product, tech, structure + auto/manual modes |
| [Specs](templates/kiro/specs/) | 5 | Kiro | feature (req/design/tasks), bugfix |
| [Combo](templates/combo/) | 6 | Both | Dual-tool scaffold + workflow guide |
| [Environments](templates/environments/) | 3 | All | worktree-setup, teardown, docker-compose |

### CLI Tools

| Command | What It Does |
|---|---|
| `harness-kit init` | Generates harness files. Auto-detects tech stack from pyproject.toml/package.json. Supports `--tools`, `--type`, `--level`, `--skip-existing`. |
| `harness-kit score` | Scores your project 0-70 across 7 maturity levels. Outputs grade (F-S) + specific recommendations. JSON output with `--format json`. |
| `harness-kit scan` | Finds unfilled placeholders, oversized rule files, non-executable hooks, command mismatches. |

### Guides (9 files)

| Guide | What You'll Learn |
|---|---|
| [Getting Started](guides/getting-started.md) | 5-minute setup path |
| [Error-Driven Writing](guides/error-driven-writing.md) | **Core methodology** -- how to write rules that work |
| [Philosophy](guides/philosophy.md) | Three generations of AI engineering, the constraint paradox, 7 principles |
| [Claude Code Harness](guides/claude-code-harness.md) | Complete Hooks + Skills + Rules guide |
| [Kiro Harness](guides/kiro-harness.md) | Complete Steering + Specs + Hooks guide |
| [Dual-Tool Workflow](guides/dual-tool-workflow.md) | Claude Code + Kiro collaboration patterns |
| [Anti-Patterns](guides/anti-patterns.md) | 9 things NOT to do (research-backed) |
| [Retrofitting](guides/retrofitting.md) | Adding harness to existing projects |

### CI Templates

| Workflow | Trigger | What It Does |
|---|---|---|
| [harness-check.yml](ci/github-actions/harness-check.yml) | Every PR | Validates rule files, hooks, placeholders |
| [entropy-scan.yml](ci/github-actions/entropy-scan.yml) | Weekly + manual | Runs scan + score, opens issue if problems found |

## Harness Maturity Model

```
Level 0: None          Agent runs blind
Level 1: Rules         AGENTS.md exists
Level 2: Constraints   + Linter + type checker + hooks
Level 3: Verification  + Agent can run tests and self-check
Level 4: Feedback      + Error messages include fix suggestions
Level 5: Context       + Skills / progressive disclosure
Level 6: Isolation     + Isolated environments (worktree/devbox)
Level 7: Autonomous    + Entropy management + multi-agent coordination
```

Grade: **F**(0-15) / **D**(16-30) / **C**(31-45) / **B**(46-60) / **A**(61-70) / **S**(71+)

## The Core Methodology: Error-Driven Writing

> "Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again." -- Mitchell Hashimoto

Every line in your AGENTS.md should trace back to a real, observed agent failure. Not a best practice you read somewhere. Not a rule you think might be useful.

ETH Zurich found: LLM-generated AGENTS.md files **hurt** performance by 20%. Human-written, error-driven rules **help** by 4%.

Read the full methodology: [Error-Driven Writing Guide](guides/error-driven-writing.md)

## Supported Platforms

| Platform | Status | What's Included |
|---|---|---|
| **Claude Code** | v0.1.0 | CLAUDE.md adapter, 6 hooks, 12 skills, 3 path rules |
| **Kiro** | v0.1.0 | Steering templates (4 modes), feature + bugfix specs, 2 hooks |
| Cursor | Planned | .cursor/rules/ templates |
| GitHub Copilot | Planned | copilot-instructions.md templates |

## Based on Research

Encodes practices from leading teams:

- [Mitchell Hashimoto](research/research-01-mitchell-hashimoto.md) -- Coined "Harness Engineering" (Feb 2026)
- [OpenAI](research/research-02-openai-langchain.md) -- 1M LOC case study, A-G framework
- [Stripe](research/research-03-thoughtworks-industry.md) -- Minions system, Blueprints, Toolshed
- [LangChain](research/research-02-openai-langchain.md) -- Terminal Bench optimization, harness anatomy
- [Boeckeler / Thoughtworks](research/research-03-thoughtworks-industry.md) -- Three pillars, four hypotheses

Full research: [research/harness-engineering-research.md](research/harness-engineering-research.md)

## Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

Priority areas:
- Real-world AGENTS.md examples from your projects
- Platform support (Cursor, Copilot)
- harness-score detection improvements
- Translations

## License

[MIT](LICENSE)
