# harness-kit

**Make your AI coding agent stop guessing and start following rules.**

harness-kit generates constraint files (HARNESS.md, hooks, skills) into your project so Claude Code, Kiro, and other AI agents know what to do — and what not to do.

```bash
pip install harness-kit
harness-kit init ~/my-project/
```

## Before / After

Without a harness, the agent guesses. With a harness, it follows your rules:

```
WITHOUT HARNESS                          WITH HARNESS
─────────────────                        ─────────────────
"Let me restructure your DB schema"      Checks HARNESS.md: "Never modify schema
                                          without a migration file" → writes migration

"I'll add this to the main file"         Checks layer rules: "UI cannot import
                                          from data layer" → creates proper module

"Done! (no tests)"                       Hook fires: "require-tests.sh" blocks
                                          completion until tests pass

"Let me refactor this whole thing"       Checks boundaries: "Ask First before
                                          deleting files" → asks for permission
```

> Same model. Same prompt. Different harness. **9% → 82% task completion** (LangChain, 2026).

## Pick Your Level

| | Starter | Standard | Advanced |
|---|---|---|---|
| **You are** | Solo dev, hacking | Team with shared codebase | Enterprise, compliance-aware |
| **Time to set up** | 30 seconds | 5 minutes | 15 minutes |
| **What you get** | HARNESS.md (~30 lines) | HARNESS.md + hooks + docs | Full harness + skills + isolation |
| **Start here** | [Starter Guide](#starter-30-seconds) | [Standard Guide](#standard-5-minutes) | [Advanced Guide](#advanced-15-minutes) |

---

## Starter (30 seconds)

Copy one file into your project. Done.

```bash
# Option A: Use the CLI
harness-kit init ~/my-project/ --level 1

# Option B: Copy manually
cp harness/universal/harness-md/starter.md ~/my-project/HARNESS.md
```

Edit the `[placeholders]` in HARNESS.md with your project's real info. That's it.

The starter template gives your agent:
- Your tech stack and commands (`npm test`, `ruff check`, etc.)
- Permission boundaries (what it can always do / must ask first / must never do)
- A "Pitfalls" section that starts empty — you fill it when the agent makes mistakes

**What to do next:** Use your agent normally. When it makes a mistake, add one line to the Pitfalls section. This is [error-driven writing](concepts/error-driven-methodology.md) — rules grow from real failures, not guesses.

---

## Standard (5 minutes)

For teams. Adds hooks (automated enforcement) and project docs.

```bash
harness-kit init ~/my-project/ --tools claude-code --level 2
```

You get:

```
HARNESS.md                    ← Agent rules (~80 lines, commands-first)
CLAUDE.md                    ← Claude Code adapter (imports HARNESS.md)
.claude/hooks/
  require-tests.sh           ← Blocks "done" until tests pass
  block-destructive.sh       ← Blocks rm -rf, DROP TABLE, force-push
  auto-lint.sh               ← Auto-formats after every edit
docs/ARCHITECTURE.md         ← Architecture doc skeleton
```

**Why hooks matter:** HARNESS.md is a suggestion — the agent *should* follow it but sometimes doesn't. Hooks are enforcement — the agent *cannot* bypass them.

```
HARNESS.md says "run tests before finishing"     → Agent might forget
require-tests.sh fires at stop phase            → Agent literally cannot skip tests
```

Using Kiro? Replace `--tools claude-code` with `--tools kiro` or `--tools both`.

---

## Advanced (15 minutes)

Full harness with skills (on-demand knowledge), verification layers, and isolation.

```bash
harness-kit init ~/my-project/ --tools both --level 3
```

Beyond Standard, you get:
- **Skills**: 13 on-demand guides the agent loads when needed (debugging, code-review, security-audit, etc.)
- **Rules**: Path-specific constraints (different rules for `/api/` vs `/ui/` vs `/tests/`)
- **Kiro steering**: Product context, tech context, structure docs for Kiro's always-on knowledge
- **Kiro specs**: Structured feature/bugfix templates for spec-driven development

Read the full setup guide: [concepts/claude-code-guide.md](concepts/claude-code-guide.md) | [concepts/kiro-guide.md](concepts/kiro-guide.md)

---

## Growing Your Harness

Your harness improves over time. Here's the progression:

```
Week 1    HARNESS.md + basic hooks              "Agent follows my rules"
Week 2    Add pitfalls as agent makes mistakes  "Agent stops repeating errors"
Week 3    Add skills for complex tasks          "Agent knows how I debug/review"
Month 2   Add constraints + entropy management  "Agent respects architecture"
Month 3   Full verification + isolation          "Agent can work autonomously"
```

Track your progress:

```bash
harness-kit score ~/my-project/
# Total: 35/70  Grade: C
# Recommendations:
#   > Add: Claude Code Skills (Level 5)
#   > Add: Pre-commit hooks (Level 2)

harness-kit scan ~/my-project/
# Checks: unfilled placeholders, stale rules, command mismatches
```

## Learn More

| Topic | Guide |
|---|---|
| **Why this works** | [Harness Philosophy](concepts/harness-philosophy.md) — three generations of AI engineering |
| **How to write rules** | [Error-Driven Writing](concepts/error-driven-methodology.md) — the core methodology |
| **Fowler's framework** | [Guides/Sensors](concepts/fowler-framework-guide.md) — the theory behind harness design |
| **What NOT to do** | [Anti-Patterns](concepts/anti-patterns.md) — common mistakes, research-backed |
| **Agent autonomy** | [Autonomy Grading](concepts/autonomy-grading-guide.md) — what tasks need human review |
| **Context limits** | [Context Budget](concepts/context-budget-guide.md) — 40% ceiling, dumb zone, sub-agent firewall |
| **Existing project** | [Retrofitting Guide](concepts/retrofitting-guide.md) — add harness without disrupting flow |
| **Dual-tool setup** | [Claude Code + Kiro](concepts/dual-tool-workflow.md) — collaboration patterns |

## Research

Built on data from real teams, not opinions:

| Source | Key Finding |
|---|---|
| [GitHub (2500 repos)](research/research-06-2026-harness-md-context.md) | Commands-first HARNESS.md, < 150 lines, no architecture overview |
| [Martin Fowler](research/research-05-fowler-harness-framework.md) | Guides/Sensors framework, Harnessability concept |
| [Datadog](research/research-07-2026-production-cases.md) | Verification pyramid, formal methods for agents |
| [Harvey AI](research/research-07-2026-production-cases.md) | 40.8% → 87.7% success with evaluator-optimizer loop |
| [OpenAI](research/research-02-openai-langchain.md) | 1M LOC, 3 engineers, zero hand-written code |
| [ETH Zurich](research/research-04-eth-zurich-risks.md) | LLM-generated HARNESS.md *hurts* performance by 20% |

## Supported Platforms

| Platform | What You Get |
|---|---|
| **Claude Code** | CLAUDE.md adapter, hooks (pre/post/stop), skills, path rules |
| **Kiro** | Steering docs (product/tech/structure), feature + bugfix specs, hooks |
| **Both** | All of the above + dual-tool workflow guide |

## Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
