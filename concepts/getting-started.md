# Getting Started with harness-kit

> Pick a level. Set up your harness. Start seeing results immediately.

## Prerequisites

- Python 3.11+ (for CLI tools)
- An existing project
- One of: Claude Code, Kiro, or both

```bash
pip install harness-kit
```

---

## Path 1: Starter (30 seconds)

**For:** Solo devs, side projects, hackathons.

```bash
harness-kit init ~/my-project/ --level 1
```

Or manually copy:

```bash
cp harness/universal/harness-md/starter.md ~/my-project/HARNESS.md
```

**What you get:** A single HARNESS.md file (~30 lines) with:
- Your commands (`npm test`, `ruff check`, etc.)
- Three-tier boundaries (Always / Ask First / Never)
- Empty Pitfalls section (grows from real failures)

**What to do after:** Edit the `[placeholders]`, then use your agent normally. When it makes a mistake, add one line to Pitfalls. That's [error-driven writing](error-driven-methodology.md).

---

## Path 2: Standard (5 minutes)

**For:** Teams, shared codebases, production projects.

```bash
# Claude Code
harness-kit init ~/my-project/ --tools claude-code --level 2

# Kiro
harness-kit init ~/my-project/ --tools kiro --level 2

# Both
harness-kit init ~/my-project/ --tools both --level 2
```

**What you get:**

| File | Purpose |
|---|---|
| `HARNESS.md` | Agent rules (~80 lines, commands-first) |
| `CLAUDE.md` | Claude Code adapter (imports HARNESS.md) |
| `.claude/hooks/require-tests.sh` | Blocks completion until tests pass |
| `.claude/hooks/block-destructive.sh` | Blocks dangerous commands |
| `.claude/hooks/auto-lint.sh` | Auto-formats after edits |
| `docs/ARCHITECTURE.md` | Architecture doc skeleton |

For Kiro, you get `.kiro/steering/` files (product, tech, structure) instead of hooks.

**What to do after:**

1. Edit `HARNESS.md` — replace `[placeholders]` with your real info
2. Edit `docs/ARCHITECTURE.md` — describe your actual architecture (the agent reads this)
3. Run your agent on a real task
4. When it breaks a rule, check: did the hook catch it? If not, add a hook. If the hook can't catch it, add it to HARNESS.md.

**The key insight:** HARNESS.md is a suggestion (agent *should* follow). Hooks are enforcement (agent *cannot* bypass). Use both.

---

## Path 3: Advanced (15 minutes)

**For:** Enterprise, high-risk systems, compliance requirements.

```bash
harness-kit init ~/my-project/ --tools both --level 3
```

**Beyond Standard, you get:**
- **13 Skills** — on-demand knowledge for code-review, debugging, security-audit, database-migration, etc.
- **Path rules** — different constraints for `/api/` vs `/ui/` vs `/tests/`
- **Kiro specs** — structured feature/bugfix templates
- **Full hooks suite** — loop detection, pre-completion checklist

**What to do after:**

1. Complete the Standard setup steps first
2. Review the skills in `.claude/skills/` — disable any that don't apply
3. Customize path rules in `.claude/rules/` for your architecture
4. Set up [autonomy grading](autonomy-grading-guide.md) — decide what the agent can do alone vs. with review
5. Read [context budget](context-budget-guide.md) — keep total context under 40% for best performance

**Deep guides:** [Claude Code Guide](claude-code-guide.md) | [Kiro Guide](kiro-guide.md) | [Dual-Tool Workflow](dual-tool-workflow.md)

---

## The Error-Driven Loop

Regardless of which path you pick, the improvement loop is the same:

```
 ┌─────────────────────────────────────┐
 │  1. Use your agent on a real task   │
 └──────────────┬──────────────────────┘
                │
                ▼
 ┌─────────────────────────────────────┐
 │  2. Agent makes a mistake?          │
 │     YES → Add one rule to HARNESS.md │
 │     NO  → Keep going               │
 └──────────────┬──────────────────────┘
                │
                ▼
 ┌─────────────────────────────────────┐
 │  3. Mistake is systematic?          │
 │     YES → Add a hook (enforcement)  │
 │     NO  → HARNESS.md rule is enough  │
 └──────────────┬──────────────────────┘
                │
                ▼
 ┌─────────────────────────────────────┐
 │  4. Check progress                  │
 │     harness-kit score ~/my-project/ │
 │     harness-kit scan ~/my-project/  │
 └─────────────────────────────────────┘
```

> "Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again." — Mitchell Hashimoto

## Common Questions

**Q: Do I need both Claude Code and Kiro?**
No. Start with whatever you use daily. HARNESS.md works with both. Add the other later if needed.

**Q: How long until I see results?**
First improvement comes from HARNESS.md alone — usually the first agent task. Hooks provide the next big jump. Most devs see measurable improvement within a week.

**Q: My project doesn't match any preset type.**
Pick the closest one, then customize. Presets are starting points.

**Q: What if I have an existing project with lots of code?**
See [Retrofitting Guide](retrofitting-guide.md) — it covers adding a harness incrementally without disrupting your workflow.
