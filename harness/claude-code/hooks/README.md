---
name: Claude Code Hooks Template Guide
description: Deterministic enforcement layer for Claude Code. Hooks run shell scripts at lifecycle events — they cannot be ignored by the model.
when_to_use: Any project using Claude Code where you need guaranteed enforcement (not just suggestions).
when_not_to_use: If you only need soft guidance, CLAUDE.md is sufficient.
---

# Claude Code Hooks

## Why Hooks?

CLAUDE.md rules are **probabilistic** — the model usually follows them (~90%), but can ignore them. Hooks are **deterministic** — they run as shell scripts every time, regardless of what the model decides.

```
CLAUDE.md:  "Please run tests before stopping"     → agent usually does
Stop Hook:  require-tests.sh                        → agent CANNOT stop without passing tests
```

**Rule of thumb**: If a rule must NEVER be violated, make it a hook. If it should usually be followed, put it in CLAUDE.md.

## How Hooks Work

Hooks fire at specific lifecycle events. Each hook receives JSON on stdin and outputs JSON to stdout.

```
Agent lifecycle:
  SessionStart ─→ UserPromptSubmit ─→ PreToolUse ─→ PostToolUse ─→ ... ─→ Stop
       │                │                  │              │                  │
    setup-env      validate-input    block-dangerous   auto-lint     require-tests
```

### Event Types We Provide Templates For

| Event | When It Fires | Template Purpose |
|-------|--------------|------------------|
| **PreToolUse** | Before agent uses a tool (Bash, Write, Edit) | Block dangerous commands, restrict paths |
| **PostToolUse** | After agent uses a tool | Auto-lint, auto-format after edits |
| **Stop** | When agent tries to finish | Verification gate: must pass tests/lint |
| **SessionStart** | When a session begins | Environment setup |

### Handler Types

| Type | How It Works | Use For |
|------|-------------|---------|
| `command` | Runs a shell script. Exit 0 = allow, exit 2 = block. | Most hooks |
| `prompt` | Single-turn LLM evaluation (yes/no). | Complex judgment calls |

## Installation

### Quick Setup (copy and configure)

1. Copy hook scripts to your project:
```bash
mkdir -p .claude/hooks
cp harness-kit/harness/claude-code/hooks/pre-tool-use/*.sh .claude/hooks/
cp harness-kit/harness/claude-code/hooks/post-tool-use/*.sh .claude/hooks/
cp harness-kit/harness/claude-code/hooks/stop/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

2. Add hooks configuration to your Claude Code settings. In your project's `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "bash .claude/hooks/block-destructive.sh"
      }
    ],
    "PostToolUse": [
      {
        "type": "command",
        "command": "bash .claude/hooks/auto-lint.sh"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "bash .claude/hooks/require-tests.sh"
      }
    ]
  }
}
```

Or use `harness-kit init --level 3` to generate this automatically.

## Available Hook Templates

### PreToolUse (before agent acts)
- **block-destructive.sh** — Prevents `rm -rf`, `git push --force`, `DROP TABLE`, etc.
- **restrict-paths.sh** — Blocks edits to protected directories (e.g., `src/core/`)

### PostToolUse (after agent acts)
- **auto-lint.sh** — Runs linter on every file the agent edits
- **auto-format.sh** — Runs formatter on every file the agent edits
- **loop-detection.sh** — Warns agent when it edits the same file 5+ times (thrashing prevention)

### Stop (verification gate)
- **require-tests.sh** — Agent cannot stop until tests pass
- **require-lint.sh** — Agent cannot stop until lint is clean
- **pre-completion-checklist.sh** — Verifies work against a project checklist before stopping

### Prompt Hooks (LLM judgment)

For verification that requires judgment (not just pass/fail), use a `prompt` type hook:

```json
{
  "type": "prompt",
  "prompt": "Before finishing, verify: 1) Every requirement from the original request is addressed. 2) No requirements were skipped. 3) You verified your work."
}
```

Prompt hooks are probabilistic (~90% effective) but catch semantic gaps that command hooks cannot. Best practice: use both command and prompt hooks together. See the [feedback loops guide](../../../concepts/feedback-loops.md).

## Recommended Stack

**Minimum viable hooks** (start here):
```
Stop: require-tests.sh          ← Biggest impact. Agent must verify its own work.
```

**Standard hooks** (most projects):
```
PreToolUse:  block-destructive.sh
PostToolUse: auto-lint.sh
Stop:        require-tests.sh
```

**Full hooks** (strict environments):
```
PreToolUse:  block-destructive.sh + restrict-paths.sh
PostToolUse: auto-lint.sh + auto-format.sh + loop-detection.sh
Stop:        require-tests.sh + require-lint.sh + pre-completion-checklist.sh
```
