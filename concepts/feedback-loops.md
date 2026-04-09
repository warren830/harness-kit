# Feedback Loops: Building Self-Correcting Agent Systems

> Gates check pass/fail. Loops create continuous improvement.

---

## The Problem: Gates Are Not Enough

Most harness setups stop at verification gates:

```
Agent works → Stop hook: tests pass? → Yes → Done
                                      → No  → Fix and retry
```

This answers **"does the code compile?"** but not:
- **"Did the agent do what was actually asked?"** (it may pass tests while missing requirements)
- **"Is the agent stuck in a loop?"** (it may edit the same file 20 times without progress)
- **"Is the harness itself improving?"** (the same failure patterns may repeat across sessions)

Gates are one-shot checkpoints. Loops are continuous improvement cycles.

---

## Three Levels of Feedback

### Level 1: Mechanical Verification (gates)

**What it checks**: Does the code compile, pass tests, pass lint?

**Tools**: Stop hooks — `require-tests.sh`, `require-lint.sh`

These are table stakes. If you don't have them, start here. See the [hooks README](../harness/claude-code/hooks/README.md).

**Limitation**: An agent can produce code that passes all tests while completely ignoring the user's actual request. Tests verify correctness of what exists, not completeness of what was asked.

### Level 2: Behavioral Feedback (loops)

**What it checks**: Is the agent working effectively? Did it do what was asked?

**Tools**:
- **Pre-completion checklist** (`pre-completion-checklist.sh`) — Forces the agent to review its work against a project-specific checklist before declaring done. Based on LangChain's PreCompletionChecklistMiddleware.
- **Loop detection** (`loop-detection.sh`) — Detects when the agent edits the same file too many times, nudging it to reconsider its approach. Based on LangChain's LoopDetectionMiddleware.

These transform the agent from "code that passes tests" to "code that fulfills the request."

#### Setting Up the Pre-Completion Checklist

1. Create `.claude/completion-checklist.md` in your project:

```markdown
- [ ] All new functions have tests
- [ ] API changes are reflected in docs
- [ ] No console.log / print statements left in production code
- [ ] Database migrations are reversible
```

2. Add the hook to `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "bash .claude/hooks/pre-completion-checklist.sh"
      }
    ]
  }
}
```

3. (Optional) Add a prompt-type hook for LLM-judgment verification:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "prompt",
        "prompt": "Before finishing, verify: 1) Every requirement from the original request is addressed. 2) No requirements were skipped. 3) You verified your work. List anything incomplete."
      }
    ]
  }
}
```

Best practice: use **both** — the command hook for mechanical checks, the prompt hook for semantic verification.

#### Setting Up Loop Detection

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "bash .claude/hooks/loop-detection.sh"
      }
    ]
  }
}
```

The default threshold is 5 edits per file. Tune this for your project — UI-heavy work may need a higher threshold.

### Level 3: Meta Feedback (harness improvement)

**What it checks**: Is the harness itself getting better over time?

**Tools**:
- **Trace analysis** (`trace-analysis.md` skill) — Review agent session patterns, identify recurring failures, improve the harness
- **Error-driven writing** ([guide](error-driven-methodology.md)) — The methodology for turning observed failures into rules

This is the loop that makes everything else compound:

```
Agent fails at X → You notice the pattern → You add a rule/hook/constraint
→ Agent never fails at X again → You notice pattern Y → ...
```

LangChain's trace analysis process:
1. Collect traces from agent sessions (logs, diffs, PR history)
2. Spawn parallel analysis to categorize failure patterns
3. Synthesize targeted harness improvements
4. Verify the improvement actually helps

See the [trace-analysis skill](../harness/claude-code/skills/trace-analysis.md) for the step-by-step process.

---

## The Complete Feedback Stack

```
Level 3: Meta Feedback (harness improves over time)
  ┌─ Trace analysis skill (on-demand, human-initiated)
  └─ Error-driven writing (methodology)
         │
         ▼ improvements feed back into ▼
Level 2: Behavioral Feedback (agent self-corrects during work)
  ┌─ Pre-completion checklist (Stop hook: "did I fulfill the spec?")
  └─ Loop detection (PostToolUse hook: "am I stuck?")
         │
         ▼ builds on top of ▼
Level 1: Mechanical Verification (code quality gates)
  ┌─ require-tests.sh (Stop hook: "do tests pass?")
  ├─ require-lint.sh (Stop hook: "is lint clean?")
  ├─ auto-lint.sh (PostToolUse: lint after each edit)
  └─ auto-format.sh (PostToolUse: format after each edit)
```

---

## Anti-Patterns

### Over-Verification

Running the full test suite after every single edit (via PostToolUse) is wasteful. The right layering:

| When | What | Speed |
|------|------|-------|
| After each edit | Lint + format (PostToolUse) | < 5 seconds |
| After each edit | Loop detection (PostToolUse) | < 1 second |
| Before agent stops | Tests + checklist (Stop) | < 1 minute |
| Before merge | Full CI suite | Minutes |

### Ignoring the Meta Loop

Having Level 1 and 2 but never doing Level 3 means the same types of failures keep recurring across sessions. Budget 30 minutes per week for trace analysis — it compounds.

### Checklist Bloat

A 50-item completion checklist defeats the purpose. Keep it to 3-7 items that represent your project's most common agent failure modes. Each item should trace back to a real observed failure (error-driven, not speculative).

---

## Advanced: Agent-to-Agent Review

OpenAI's "Ralph Wiggum Loop" uses one agent to review another's output before completion. This is powerful but requires multi-agent orchestration that varies by team. If you're ready for this pattern:

1. Use Claude Code's subagent capabilities to spawn a review agent
2. The review agent reads the diff and checks against requirements
3. Failures feed back to the original agent

This is not yet templated in harness-kit — it's an emerging pattern to watch.

---

## References

- LangChain Terminal Bench improvement recipe: PreCompletionChecklistMiddleware, LoopDetectionMiddleware
- OpenAI report: "When the agent struggles, we treat it as a signal"
- Mitchell Hashimoto: "Anytime you find an agent makes a mistake, engineer a solution"
- Related: [Error-Driven Writing](error-driven-methodology.md) | [Philosophy](harness-philosophy.md) | [Hooks README](../harness/claude-code/hooks/README.md)
