# Harness Anti-Patterns

> What NOT to do. Every anti-pattern here is backed by research or observed failure.

---

## Anti-Pattern 1: AI Writing Its Own Rules

**What**: Using an LLM to generate AGENTS.md or steering content.

**Evidence**: ETH Zurich study found LLM-generated AGENTS.md files **hurt performance by 20%+**, while human-written ones improved it by ~4%.

**Why it fails**: The LLM generates generic best practices it already knows. This adds noise, drowning out the project-specific rules that actually matter.

**Fix**: Write rules from observed agent failures only. See [error-driven-writing.md](error-driven-writing.md).

---

## Anti-Pattern 2: The 500-Line Rule File

**What**: Putting everything into one massive AGENTS.md or CLAUDE.md.

**Evidence**: Claude Code documentation recommends < 200 lines. LangChain found 12 consolidated skills outperform 20 fragmented ones — but a single giant file is worse than either.

**Why it fails**: Important rules get lost in noise. Agent adherence measurably drops as files grow.

**Fix**:
- AGENTS.md: ~100 lines max (table of contents, not encyclopedia)
- Split into: AGENTS.md (core) + .claude/rules/ (path-specific) + .claude/skills/ (on-demand)
- Or: AGENTS.md + .kiro/steering/ with different inclusion modes

---

## Anti-Pattern 3: Preemptive Configuration

**What**: Setting up 20 skills, 10 MCP servers, and complex hooks before using the agent once.

**Evidence**: HumanLayer research: "installing dozens of skills/servers 'just in case'" doesn't work. Performance starts declining around 40% context utilization.

**Why it fails**: More loaded context = more noise = worse performance. The agent spends tokens processing irrelevant instructions.

**Fix**: Start with AGENTS.md only. Add one tool/skill/hook at a time, when you observe a specific need.

---

## Anti-Pattern 4: Infinite CI Retry

**What**: Letting the agent attempt unlimited CI fix rounds.

**Evidence**: Stripe intentionally caps at 2 rounds of CI fixes. OpenAI noted "corrections are cheap, and waiting is expensive" — but this has limits.

**Why it fails**: After 2-3 attempts, the agent often enters a fix-break-fix loop where each "fix" introduces a new problem. Returns diminish rapidly.

**Fix**: Maximum 2 CI fix rounds, then escalate to human. Configure this in your workflow, not just as guidance.

---

## Anti-Pattern 5: No Verification Gate

**What**: Relying on the agent to "remember" to run tests before stopping.

**Evidence**: Anthropic best practices: "Self-verification is the single highest-leverage thing you can do." Without enforcement, agents frequently skip verification.

**Why it fails**: AGENTS.md verification instructions are probabilistic (~90% followed). That 10% miss rate compounds over many tasks.

**Fix**: Use a Stop hook (Claude Code) or after-task-test hook (Kiro) to make verification mandatory and deterministic.

---

## Anti-Pattern 6: Ignoring Entropy

**What**: Writing the harness once and never updating it.

**Evidence**: OpenAI: "Our team used to spend every Friday (20% of the week) cleaning up 'AI slop.'" Rule files accumulate contradictions, docs drift from implementation.

**Why it fails**: Stale rules confuse agents. Contradictory rules cause unpredictable behavior. Documentation drift means agents make decisions based on outdated information.

**Fix**: Schedule monthly harness review. Run `harness-kit scan` weekly. Treat harness maintenance like code maintenance.

---

## Anti-Pattern 7: Duplicating Rules Across Tools

**What**: Writing the same rules in AGENTS.md, CLAUDE.md, and .kiro/steering/.

**Why it fails**: When you update one, you forget the others. Now the tools get contradictory instructions. The agent doesn't know which to follow.

**Fix**: AGENTS.md is the single source of truth. CLAUDE.md imports it with `@AGENTS.md`. Kiro auto-detects it. Platform files only add platform-specific config, never duplicate content.

---

## Anti-Pattern 8: Testing Every Time

**What**: Running the entire test suite at every agent interaction or file save.

**Evidence**: HumanLayer: "running full test suites at every session" is unworkable for large projects.

**Why it fails**: If your test suite takes 10+ minutes, the agent stalls. Feedback loops must be fast to be useful.

**Fix**:
- Fast feedback: Linter on each edit (< 5 seconds via PostToolUse hook)
- Medium feedback: Affected tests on task completion (< 1 minute)
- Full feedback: Complete suite in CI (before merge)

---

## Anti-Pattern 9: Speculative Rules

**What**: Writing rules for problems that haven't happened yet.

```markdown
<!-- DON'T -->
- The agent might try to use a deprecated API, so avoid module X
- In case the agent creates too many files, limit to 5 per task
```

**Why it fails**: You're guessing at failure modes. Your guesses are usually wrong, and they add noise.

**Fix**: Wait for the agent to actually make the mistake. Then write the rule. Error-driven, not speculation-driven.

---

## Quick Reference

| Anti-Pattern | Fix |
|-------------|-----|
| AI writes its own rules | Human writes from observed failures |
| 500-line rule file | < 100 lines + skills/steering for depth |
| Preemptive configuration | Start minimal, add on demand |
| Infinite CI retry | Max 2 rounds, then escalate |
| No verification gate | Stop hook / after-task hook |
| Ignoring entropy | Monthly review + harness-kit scan |
| Duplicating rules | AGENTS.md = single source of truth |
| Testing every time | Fast lint → medium test → full CI |
| Speculative rules | Only write what you've observed |
