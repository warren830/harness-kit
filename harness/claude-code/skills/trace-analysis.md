---
description: Agent trace analysis for harness improvement. Use when reviewing agent sessions to identify recurring failure patterns and improve the harness.
---

# Trace Analysis Skill

## What Is Trace Analysis?

Reviewing agent session history to find patterns in failures, then feeding improvements back into the harness. This is the meta-feedback loop — the process that makes your harness compound over time.

Based on LangChain's automated trace analysis (their Step 1 improvement), adapted for human-driven review.

## When to Use

- After a session where the agent struggled or produced poor results
- During weekly harness maintenance reviews
- When you notice the same type of failure recurring across sessions

## When NOT to Use

- For a single one-off failure (use error-driven writing directly instead)
- When the failure is clearly a model limitation, not a harness gap

## Four-Step Process

### 1. Collect Traces

Gather evidence from recent agent sessions:

```bash
# Recent git history from agent commits
git log --oneline --since="1 week ago" --author="claude"

# Look for reverted or amended commits (signs of agent mistakes)
git log --oneline --all | grep -i "revert\|fix\|oops\|wrong"

# Check for unusually large diffs (possible thrashing)
git log --stat --since="1 week ago" | grep "changed"
```

Also review: CI failure logs, PR review comments, your own memory of "that was annoying" moments.

### 2. Categorize Failures

| Pattern | Symptom | Frequency |
|---------|---------|-----------|
| Missed requirements | Agent passes tests but doesn't do what was asked | ___ / week |
| File thrashing | Same file edited 10+ times in one session | ___ / week |
| Wrong command | Agent uses incorrect build/test/deploy commands | ___ / week |
| Architecture violation | Agent creates files in wrong directories or wrong patterns | ___ / week |
| Incomplete verification | Agent declares done without running tests | ___ / week |
| Context loss | Agent forgets earlier decisions mid-session | ___ / week |

Focus on patterns that appear 2+ times. One-off failures are noise.

### 3. Synthesize Improvements

Match the pattern to the right harness fix:

| Pattern | Fix Type | Where |
|---------|----------|-------|
| Missed requirements | Pre-completion checklist hook | `.claude/hooks/stop/` |
| File thrashing | Loop detection hook | `.claude/hooks/post-tool-use/` |
| Wrong command | HARNESS.md commands section | `HARNESS.md` |
| Architecture violation | Path restriction hook or layer rules | `.claude/rules/` |
| Incomplete verification | Stop hook (require-tests) | `.claude/hooks/stop/` |
| Context loss | Knowledge base docs or steering files | `docs/` or `.kiro/steering/` |

**Important**: Do NOT add multiple rules at once. Add one, verify it helps, then add the next. Rules that overfit to a single task hurt generalization (LangChain observed this).

### 4. Verify Improvement

After adding a fix:

1. Re-run a similar task that previously triggered the failure
2. Observe: does the agent avoid the failure now?
3. If yes — the fix works, move on
4. If no — the fix is wrong or incomplete, revise it

Do NOT skip this step. Unverified rules accumulate as noise.

## Anti-Patterns

- **Adding rules for every failure**: Not every failure needs a rule. Only add rules for patterns that recur
- **Overfitting to one task**: A rule that fixes Task A but breaks Task B is worse than no rule
- **Speculative rules**: Never add rules for failures you imagine might happen — only for ones you observed
- **Rule-and-forget**: Rules need maintenance too. Stale rules become noise (see entropy-cleanup skill)
