# Retrofitting: Adding a Harness to an Existing Project

> How to add harness engineering to a project that already has code.

---

## The Honest Warning

Birgitta Boeckeler (Thoughtworks) warns:

> Retrofitting harnesses onto legacy codebases may not justify the effort, similar to running static analysis on unmaintained code and "drowning in alerts."

**This doesn't mean "don't do it."** It means: **start small, be realistic, don't try to harness everything at once.**

## The Gradual Approach

```
Week 1:  AGENTS.md only                    ← 30 minutes
Week 2:  + Stop hook (require-tests)       ← 1 hour
Week 3:  + Grow AGENTS.md from failures    ← 5 min/day
Week 4:  + Knowledge base (ARCHITECTURE)   ← 2 hours
Month 2: + Skills for common tasks         ← 4 hours
Month 3: + Path-specific rules             ← 2 hours
Month 6: + Entropy management              ← ongoing
```

**Do NOT** try to go from Level 0 to Level 7 in one sprint.

## Step 1: Start with AGENTS.md (Week 1)

```bash
harness-kit init ~/existing-project/ --tools both --level 1
```

Then customize:
- Replace all placeholders with your project's real commands and paths
- **Leave "Agent Pitfalls" empty** — you'll fill it from experience
- Focus on what's unique about your project that an agent couldn't guess

This alone provides measurable improvement on day one.

## Step 2: Add the Stop Hook (Week 2)

If your project has tests (even partial), add the highest-impact hook:

```bash
mkdir -p .claude/hooks
cp harness-kit/templates/claude-code/hooks/stop/require-tests.sh .claude/hooks/
chmod +x .claude/hooks/require-tests.sh
# Edit the script: set TEST_CMD to your project's test command
```

If your project does NOT have tests:
- Skip this step for now
- Focus on adding tests to the most critical paths first
- Come back to the Stop hook once you have a basic test suite

## Step 3: Error-Driven Growth (Week 3+)

Start using AI agents for real work. Every time the agent makes a mistake:

1. Note the mistake
2. Add one line to AGENTS.md
3. Verify the fix

After 2-3 weeks, your AGENTS.md will have 10-20 lines of project-specific rules that dramatically improve agent behavior. These rules are worth more than any template because they're tailored to YOUR project's failure modes.

## Step 4: Document What You Have (Week 4)

Write docs/ARCHITECTURE.md. This isn't about creating perfect documentation — it's about giving the agent enough context to make good structural decisions.

Start with:
- Which directories exist and what they contain
- Which layers can import from which (dependency rules)
- What areas are fragile/protected

```bash
cp harness-kit/templates/universal/knowledge-base/docs/ARCHITECTURE.md docs/
# Fill in the basics — even a half-complete doc is better than nothing
```

## Step 5: Add Context Layers (Month 2-3)

Now that you have the foundation, add progressive disclosure:

**For Claude Code**:
```bash
# Add 2-3 most relevant skills
cp harness-kit/templates/claude-code/skills/debugging.md .claude/skills/
cp harness-kit/templates/claude-code/skills/code-review.md .claude/skills/

# Add path-specific rules for your most active areas
# Create .claude/rules/api-rules.md with your API conventions
```

**For Kiro**:
```bash
# Add auto-loading steering for domains you work on most
cp harness-kit/templates/kiro/steering/api-design.md .kiro/steering/
# Customize for your project's patterns
```

## What About Legacy Code?

For code modules rated "F" (no tests, fragile, nobody understands it):

1. **Don't try to harness legacy modules** — add them to QUALITY.md as Grade F
2. **Tell agents to avoid them** — add to AGENTS.md: "Do NOT modify src/legacy/ without approval"
3. **Protect them with hooks** — add path to restrict-paths.sh
4. **Gradually improve** — when you DO touch legacy code, add tests first

## Common Retrofitting Mistakes

### Mistake 1: Boiling the ocean

"Let me set up the complete harness infrastructure before we start."

**Fix**: AGENTS.md first. Everything else follows naturally from observed needs.

### Mistake 2: Generating rules from the codebase

"Let me have AI analyze the codebase and generate comprehensive rules."

**Fix**: Don't. ETH Zurich showed this hurts performance. Write rules from agent failures, not code analysis.

### Mistake 3: Adding every possible hook and skill

"Let me install all 12 skills and 6 hooks on day one."

**Fix**: Start with 1 hook (require-tests) and 0 skills. Add one at a time when you observe a specific need.

### Mistake 4: Not updating the harness

"We set up AGENTS.md three months ago, we're done."

**Fix**: The harness is alive. It grows with the project. Schedule weekly 30-minute reviews.

## Retrofitting Checklist

| Phase | Time | What | Validation |
|-------|------|------|-----------|
| Day 1 | 30 min | AGENTS.md + CLAUDE.md/.kiro/steering | `harness-kit score` shows Level 1 |
| Week 1 | 1 hour | Stop hook + block-destructive hook | `harness-kit score` shows Level 2+ |
| Week 2-4 | 5 min/day | Grow AGENTS.md from failures | 10-20 project-specific rules |
| Month 1 | 2 hours | ARCHITECTURE.md + QUALITY.md | `harness-kit score` shows Level 4 |
| Month 2 | 4 hours | 2-3 Skills or auto-steering files | `harness-kit score` shows Level 5 |
| Month 3+ | Ongoing | Entropy management + CI integration | `harness-kit score` shows Level 6+ |
