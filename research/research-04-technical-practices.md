# Research: Technical Implementation Details of Harness Engineering

## 1. Definition and Core Concept

**Harness engineering** refers to the practice of designing the infrastructure, rules, tools, and feedback loops that surround an AI coding agent -- turning a raw language model into a capable, reliable software engineering assistant. As Anthropic's official documentation states: "Claude Code serves as the **agentic harness** around Claude: it provides the tools, context management, and execution environment that turn a language model into a capable coding agent."

The term encompasses everything outside the model itself: rule files, hooks, permission systems, context management, verification loops, cost optimization, and CI/CD integration.

---

## 2. Rule Files Across AI Coding Agents

### 2.1 Claude Code: CLAUDE.md

**Locations and scope hierarchy (highest to lowest priority):**

| Scope | Location | Purpose |
|-------|----------|---------|
| Managed policy | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux: `/etc/claude-code/CLAUDE.md`; Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | Organization-wide, cannot be excluded |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared via source control |
| User | `~/.claude/CLAUDE.md` | Personal preferences across all projects |

**Key technical details:**
- Target under 200 lines per file; longer files reduce adherence
- Files support `@path/to/import` syntax for importing additional files (max 5 hops deep)
- Path-specific rules via `.claude/rules/` directory with YAML frontmatter glob patterns (e.g., `paths: ["src/api/**/*.ts"]`)
- CLAUDE.md is loaded as a **user message after the system prompt**, not as part of the system prompt
- Content survives `/compact` -- re-read from disk and re-injected fresh
- `claudeMdExcludes` setting to skip irrelevant files in monorepos
- Auto-memory system (`~/.claude/projects/<project>/memory/MEMORY.md`) -- first 200 lines loaded each session; Claude writes its own notes

### 2.2 GitHub Copilot: copilot-instructions.md

Three types of instruction files:
1. **Repository-wide**: `.github/copilot-instructions.md` -- applies to all requests
2. **Path-specific**: `.github/instructions/NAME.instructions.md` with YAML frontmatter `applyTo: "**/*.ts,**/*.tsx"` and optional `excludeAgent: "code-review"` or `"coding-agent"`
3. **Agent instructions**: `AGENTS.md` files (or `CLAUDE.md`/`GEMINI.md` at repo root) -- nearest file takes precedence

Priority: personal instructions (highest) > repository > organization (lowest).

### 2.3 Cursor: .cursorrules

Cursor originally used `.cursorrules` files at the project root. The system redirected to a more structured rules system at `docs.cursor.com/context/rules`, though the exact current schema was unavailable at fetch time.

### 2.4 OpenAI Codex: AGENTS.md

OpenAI's Codex agent uses `AGENTS.md` files for repository-level instructions, following a similar pattern to Claude's CLAUDE.md. GitHub Copilot also recognizes `AGENTS.md` as an agent instruction file.

---

## 3. Deterministic Guardrails: Hooks System

Claude Code's hooks system provides **deterministic enforcement** as opposed to advisory CLAUDE.md instructions. Hooks fire at 24+ lifecycle points:

```
SessionStart -> UserPromptSubmit -> PreToolUse -> PermissionRequest -> PostToolUse
-> SubagentStart/Stop -> Stop/StopFailure -> TaskCompleted -> SessionEnd
```

### Four hook handler types:

1. **Command hooks** (shell scripts): Receive JSON on stdin, output JSON to stdout. Exit code 0 = allow, exit code 2 = blocking error.
2. **HTTP hooks**: POST to endpoints with JSON payloads, support env var interpolation in headers.
3. **Prompt hooks**: Use Claude model for single-turn LLM-based evaluation (yes/no decisions).
4. **Agent hooks**: Spawn subagent with Read/Grep/Glob tools for complex validation.

### Guardrail patterns with concrete examples:

**Blocking dangerous commands (PreToolUse):**
```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "Destructive command blocked"}}'
else
  exit 0
fi
```

**PostToolUse lint enforcement:**
```bash
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  if ! npx eslint "$FILE" --fix 2>/dev/null; then
    jq -n '{decision: "block", reason: "File fails linting."}'
  fi
fi
```

**Stop hook requiring tests pass before stopping:**
```bash
if ! npm test >/dev/null 2>&1; then
  jq -n '{decision: "block", reason: "Tests failing. Fix test failures before stopping."}'
fi
```

**Key distinction**: "Settings rules are enforced by the client regardless of what Claude decides to do. CLAUDE.md instructions shape Claude's behavior but are not a hard enforcement layer."

---

## 4. KV Cache / Prompt Caching for Cost Reduction

### Pricing (per million tokens):

| Model | Base Input | Cache Write (5min) | Cache Write (1hr) | **Cache Hit** | Output |
|-------|-----------|-------------------|-------------------|---------------|--------|
| Claude Sonnet 4.6 | **$3** | $3.75 | $6 | **$0.30** | $15 |
| Claude Opus 4.6 | $5 | $6.25 | $10 | **$0.50** | $25 |
| Claude Haiku 4.5 | $1 | $1.25 | $2 | **$0.10** | $5 |

**The $3 to $0.30 reduction**: For Claude Sonnet 4.6, cached token reads cost $0.30/MTok vs. $3/MTok base input -- a **90% cost reduction** (exactly the 10x reduction from $3 to $0.3 per million tokens).

**Pricing multipliers:**
- Cache writes: 1.25x (5-min TTL) or 2x (1-hr TTL) of base input
- **Cache reads: 0.1x (10%) of base input** -- this is the key savings

**Real-world example**: Legal document analysis with 50k token document on Opus:
- First request (cache write): $0.325
- Subsequent requests (cache hit): $0.038 each -- **88% savings per request**
- 9 subsequent requests save $2.52

**Technical constraints:**
- Minimum cacheable tokens: 2,048 (Sonnet 4.6), 4,096 (Opus/Haiku 4.5)
- Maximum 4 cache breakpoints per request
- 20-block lookback window for cache matching
- Default 5-minute TTL (refreshed on each use); optional 1-hour TTL

---

## 5. Progressive Context Disclosure

### Skills System (On-Demand Loading)

Skills (`SKILL.md` files in `.claude/skills/`) implement progressive context disclosure:

- **Descriptions loaded at session start** (lightweight) -- Claude sees what's available
- **Full skill content only loads when invoked** -- saves context tokens
- Character budget: 2% of context window (fallback: 16,000 characters)
- `disable-model-invocation: true` removes skill from context entirely until manual invocation

### Path-Specific Rules

`.claude/rules/` files with `paths` frontmatter only load when Claude works with matching files:
```yaml
---
paths:
  - "src/api/**/*.ts"
---
# API Development Rules
```

### Subagent Context Isolation

Subagents run in separate context windows. Their verbose file reads, test outputs, and exploration don't bloat the main conversation. Only a summary returns.

### Context Management Strategies from Documentation:
- `/clear` between unrelated tasks
- Auto-compaction summarizes when approaching limits
- `/compact <instructions>` for targeted compaction (e.g., `/compact Focus on the API changes`)
- CLAUDE.md instructions for compaction behavior: `"When compacting, always preserve the full list of modified files"`
- MCP tool search: when tool descriptions exceed 10% of context, tools are deferred and loaded on-demand

---

## 6. Self-Verification Loops

The official best practices identify self-verification as **"the single highest-leverage thing you can do"**:

**Verification strategies:**

| Strategy | Before | After |
|----------|--------|-------|
| Provide verification criteria | "implement a function that validates email addresses" | "write validateEmail. Test cases: user@example.com true, invalid false. Run tests after implementing" |
| Visual verification | "make the dashboard look better" | "[paste screenshot] implement this design. Take screenshot and compare" |
| Root cause analysis | "the build is failing" | "the build fails with this error: [paste]. Fix it and verify build succeeds" |

**Stop hooks as verification gates**: A Stop hook can block Claude from completing until `npm test && npm run lint` passes.

**Writer/Reviewer pattern**: Two parallel sessions -- Session A implements, Session B reviews with fresh context (avoiding bias toward code it wrote).

---

## 7. Benchmarks and Quantitative Results

### SWE-bench Verified Scores:

| Agent/Model | Score | Cost | Date |
|-------------|-------|------|------|
| Claude 4.5 Opus (high reasoning) | **76.8%** | $376.95 total | Feb 2026 |
| Gemini 3 Flash (high reasoning) | 75.8% | $177.98 total | Feb 2026 |
| Claude 3.5 Sonnet (new, 2024) | 49% | -- | 2024 |
| Previous SOTA (2024) | 45% | -- | 2024 |
| Claude 3.5 Sonnet (old) | 33% | -- | 2024 |
| Claude 3 Opus | 22% | -- | 2024 |

**Key scaffolding insight from SWE-bench**: The developers "prioritized giving as much control as possible to the language model itself, and keep the scaffolding minimal." The system used only two primary tools (Bash and Edit), with the Edit tool requiring exact single-match string replacement for precision. Models sampled until completion or the 200k token budget.

### Claude Code Cost Metrics:
- **Average cost: $6/developer/day**
- 90% of users stay below $12/day
- Monthly average: ~$100-200/developer with Sonnet 4.6
- Agent teams use ~7x more tokens than standard sessions
- Background token usage: typically under $0.04 per session

### Code Review Costs:
- Average review cost: $15-25 per PR
- Multi-agent fleet with parallel analysis and deduplication
- Average completion time: 20 minutes per review

---

## 8. CI/CD Integration for AI Agents

### GitHub Actions Integration

Claude Code provides `anthropics/claude-code-action@v1` with:

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Modes**: Auto-detected (interactive for @claude mentions, automation for prompt-driven). Supports AWS Bedrock and Google Vertex AI backends.

**Non-interactive mode** for CI:
```bash
claude -p "Analyze this log file" --output-format stream-json
```

**Fan-out pattern** for batch operations:
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

### Automated Code Review

Multi-agent fleet with specialized agents examining code for:
- Logic errors, security vulnerabilities, broken edge cases, subtle regressions
- Severity levels: Normal (bugs), Nit (minor), Pre-existing (not from this PR)
- Customizable via `REVIEW.md` for review-specific rules

---

## 9. Test-Driven Development with AI

The documentation promotes explicit TDD patterns:

1. **Provide test cases upfront**: "write validateEmail. Test cases: 'user@example.com' true, 'invalid' false, 'user@.com' false. Run tests after implementing"
2. **Cross-session TDD**: "Have one Claude write tests, then another write code to pass them"
3. **Stop hooks enforcing tests**: Block the agent from completing until all tests pass
4. **PostToolUse hooks**: Auto-run linting after every file edit
5. **Plan mode**: Research first, plan second, implement third, verify fourth

---

## 10. Entropy Management / Garbage Collection

### Context Entropy

The central insight from Anthropic's best practices: "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."

**Entropy accumulation patterns:**
- "The kitchen sink session" -- mixing unrelated tasks pollutes context
- "Correcting over and over" -- failed approaches clutter context with noise
- "The infinite exploration" -- unscoped investigation reads hundreds of files
- "The over-specified CLAUDE.md" -- important rules get lost in noise

**Garbage collection strategies:**
- `/clear` between unrelated tasks (hard reset)
- `/compact` with instructions to preserve specific content (selective compaction)
- `/rewind` to restore conversation and code to checkpoints
- Subagent delegation isolates verbose operations
- Auto-compaction triggers when approaching context limits

### Documentation Drift

Code Review addresses documentation drift bidirectionally: "If your PR changes code in a way that makes a CLAUDE.md statement outdated, Claude flags that the docs need updating too."

### Pattern Violations

- `.claude/rules/` with path-specific patterns enforce conventions per directory
- PostToolUse hooks run linters after every edit
- Stop hooks block completion until tests/lint pass
- REVIEW.md encodes "Things Claude should always flag" and "Things Claude should skip"

### Cleanup Agent Pattern

The `/simplify` bundled skill: "Review your recently changed files for code reuse, quality, and efficiency issues, then fix them. Spawns three review agents in parallel, aggregates findings, and applies fixes."

The `/batch` skill for large-scale cleanup: "Researches the codebase, decomposes work into 5-30 independent units, spawns one background agent per unit in isolated git worktrees."

---

## 11. Cost Optimization Techniques Beyond Caching

1. **MCP tool search**: When tools exceed 10% of context, automatically defer them. Configure with `ENABLE_TOOL_SEARCH=auto:<N>` (e.g., `auto:5` for 5% threshold)
2. **Prefer CLI tools over MCP servers**: `gh`, `aws`, `gcloud` don't add persistent tool definitions
3. **Move CLAUDE.md content to skills**: Skills load on-demand; CLAUDE.md loads every session
4. **Code intelligence plugins**: Single "go to definition" call replaces grep + reading multiple files
5. **Preprocessing hooks**: Filter 10,000-line log to only ERROR lines before Claude sees it
6. **Extended thinking control**: `MAX_THINKING_TOKENS=8000` or `/effort low` for simple tasks
7. **Model selection**: Sonnet for most tasks, Opus for complex architecture, Haiku for simple subagent tasks

**Rate limit recommendations by team size:**

| Team Size | TPM per User | RPM per User |
|-----------|-------------|-------------|
| 1-5 | 200k-300k | 5-7 |
| 5-20 | 100k-150k | 2.5-3.5 |
| 100-500 | 15k-20k | 0.37-0.47 |
| 500+ | 10k-15k | 0.25-0.35 |

---

## 12. Summary: The Harness Engineering Stack

The complete harness engineering stack for AI-assisted development consists of:

1. **Rule layer**: CLAUDE.md / copilot-instructions.md / AGENTS.md / .cursorrules -- advisory behavioral guidance
2. **Deterministic layer**: Hooks (PreToolUse, PostToolUse, Stop) -- enforced shell-script guardrails
3. **Permission layer**: Allowlists, denylists, sandboxing -- security boundaries
4. **Context layer**: Skills, path-specific rules, subagents, auto-compaction -- progressive disclosure and entropy management
5. **Verification layer**: Test suites, linters, screenshots, Stop hooks -- self-checking loops
6. **Cost layer**: KV cache (90% savings), model selection, tool search thresholds -- economic optimization
7. **CI/CD layer**: GitHub Actions, GitLab CI/CD, non-interactive mode -- automation at scale
8. **Review layer**: Multi-agent code review, REVIEW.md, severity tagging -- quality assurance
