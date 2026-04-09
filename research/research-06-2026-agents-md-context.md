# Research: AGENTS.md & Context Engineering Updates (2026 Q1)

## Sources

1. **GitHub Blog**: "How to write a great agents.md: Lessons from over 2,500 repositories" by Matt Nigh
   URL: https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/

2. **Anthropic**: "Effective context engineering for AI agents"
   URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

3. **HumanLayer**: "Skill Issue: Harness Engineering for Coding Agents"
   URL: https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents

4. **Augment Code**: "How to Build Your AGENTS.md (2026)"
   URL: https://www.augmentcode.com/guides/how-to-build-agents-md

5. **Epsilla**: "Why Harness Engineering Replaced Prompting in 2026"
   URL: https://www.epsilla.com/blogs/harness-engineering-evolution-prompt-context-autonomous-agents

---

## 1. GitHub's 2,500 Repository Analysis

### Key Findings

**What works:**
- Put executable commands early — agents reference them frequently, this is the #1 differentiator
- Three-tier boundary system: ✅ Always do / ⚠️ Ask first / 🚫 Never do
- Real code examples showing expected style >> written descriptions of style
- Specific tech stack with versions (e.g., "React 18 with TypeScript, Vite, Tailwind CSS")
- Six core areas: commands, testing, project structure, code style, git workflow, boundaries

**What doesn't work:**
- Generic personas ("helpful coding assistant") — specialized roles with explicit constraints outperform
- Abstract descriptions instead of concrete examples
- Missing executable commands
- Architecture overviews — agents discover these independently

**Recommended agent types:**
1. @docs-agent — reads code, generates documentation; writes to `docs/` only
2. @test-agent — creates tests; never removes failing tests
3. @lint-agent — fixes style without modifying logic
4. @api-agent — builds endpoints; asks before schema modifications
5. @dev-deploy-agent — deploys to dev only, with user approval

**Core advice: "Effective agents grow through iteration, not upfront planning."**

---

## 2. Anthropic's Context Engineering Framework

### New Concepts

**Context Rot**: Performance degrades as token count increases. More context ≠ better results.

**Progressive Disclosure**: Agents incrementally discover relevant context through exploration rather than receiving everything upfront.

### Key Techniques

- **System prompts at the right altitude**: Specific enough to guide, flexible enough not to be brittle. Find the minimal information set that fully outlines expected behavior.
- **Tool design**: Token-efficient, unambiguous, minimal functional overlap.
- **Just-in-time retrieval**: Maintain lightweight identifiers (file paths, URLs), dynamically load at runtime.
- **Compaction**: Summarize approaching context limits, preserving architectural decisions, discarding redundant output. Clearing tool results is "the safest lightest touch form."
- **Structured note-taking**: Agents write persistent notes outside the context window.
- **Sub-agent architectures**: Specialized sub-agents with clean context windows return 1,000-2,000 token summaries.

**Core advice: "Do the simplest thing that works."**

---

## 3. HumanLayer's Updated Guidelines

### Critical Numbers

- **CLAUDE.md should be under 60 lines** (down from the commonly cited 100 lines)
- **Performance degrades at ~40% context utilization** — this is a hard ceiling, not soft guidance
- Too many MCP tools creates a **"dumb zone"** where context floods with tool descriptions

### Sub-Agents as "Context Firewalls"

Parent agents see only condensed results, maintaining coherency. Sub-agents isolate intermediate noise. This structurally solves the context rot problem.

**Best practices for sub-agents:**
- Return highly condensed responses with source citations (filepath:line)
- Use expensive models (Opus) for parent orchestration, cheaper (Sonnet/Haiku) for discrete tasks
- Use cases: locating definitions, analyzing patterns, tracing information flow, research tasks

### Back-Pressure Principle

Success correlates strongly with agents' ability to verify their own work:
- Typechecks and builds (strongly-typed languages recommended)
- Unit/integration tests
- Code coverage reporting

**Critical: Make verification context-efficient — surface only errors, not verbose passing output.** 4,000 lines of test logs flood context and destroy coherency.

### What Didn't Work (Negative Results)

- Designing ideal harness upfront before real failures
- Installing dozens of skills/MCP servers "just in case"
- Running full test suites (+5 min) after every change
- Micro-optimizing which sub-agents access which tools

---

## 4. Augment Code's AGENTS.md Guide

### Six Core Sections

1. **Tech Stack Definition** — exact versions and non-negotiable tools
2. **Executable Commands** — placed early, with all flags
3. **Coding Conventions** — counterintuitive patterns shown with real code
4. **Testing Rules** — specific commands and requirements
5. **Permission Boundaries** — three-tier (✅ Always, ⚠️ Ask, 🚫 Never)
6. **Non-Standard Tooling** — tools underrepresented in LLM training data

### Length Guidelines

- Start under **150 lines**
- 371 lines is an upper bound — beyond that, split into subdirectory-specific files
- Place critical rules early (combat "lost in the middle" effect)
- Version control the file like code
- **Never auto-generate** with `/init` commands
- Remove rules rarely used — files accumulate contradictory patches

---

## 5. Epsilla's Three-Generation Model

### Evolution

| Generation | Era | Focus |
|---|---|---|
| Prompt Engineering | 2022-2024 | Crafting single optimal instructions |
| Context Engineering | 2025 | Dynamically constructed context windows (RAG, tools, history) |
| Harness Engineering | 2026 | Complete operational environment (workflow, constraints, feedback loops, lifecycle) |

### Key Distinction

**"You don't ask the agent to follow a rule; you build a system that makes it impossible to break it."**

### Industry Performance Data

- Same model, same data, same prompt: success rate **42% → 78%** by changing only runtime environment
- Unstructured approach: broken product for $9
- Structured iterative approach: functional application for $200
- OpenAI Codex: 7 engineers, ~1M LOC, 1,500 PRs in 5 months
- Stripe Minions: 1,300+ PRs/week merged without human oversight

### Architectural Patterns Cited

**OpenAI's 5 Principles:**
1. Repository as single source of truth
2. Code must be agent-readable
3. Linter-enforced architectural constraints
4. Incrementally granted autonomy through gates
5. Harness redesign when PRs require excessive human intervention

**Stripe's Blueprint Pattern:**
- Separates deterministic nodes (linting, commits) from agentic nodes (implementation, CI fixes)
- Two-strike escalation rule: second fix failure → human handoff

**Anthropic's GAN-Inspired Architecture:**
- Separate Generator Agent and Evaluator Agent
- Evaluator uses Playwright for e2e verification
- Evaluators engineered for ruthless strictness

---

## Implications for harness-kit

1. AGENTS.md template max length should drop from 100 to ~60-80 lines
2. Three-tier permission boundary (✅/⚠️/🚫) should be the default template structure
3. "Commands first" should be enforced in template structure
4. Need to add "Context Budget" concept to guides — the 40% ceiling is a hard constraint
5. Sub-agent patterns deserve their own guide
6. "What doesn't work" section should be added to anti-patterns guide
7. The Epsilla evolution model (Prompt → Context → Harness) is a useful framing for the philosophy guide
