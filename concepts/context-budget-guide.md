# Context Budget: Keeping Your Agent in the Smart Zone

> More context does not mean better results.
> Performance degrades at ~40% context utilization. Manage your budget or watch your agent get dumber.

---

## When to Use

- Your agent's output quality is declining mid-session
- You are designing HARNESS.md / CLAUDE.md and wondering how long it should be
- You are deciding whether to add more MCP tools or context files
- You are setting up sub-agent architectures

## When NOT to Use

- You are choosing what type of control to add -- see [fowler-framework-guide.md](fowler-framework-guide.md)
- You are just getting started and have minimal context -- this becomes relevant as your harness grows

---

## The 40% Ceiling

Multiple independent sources converge on the same number:

| Source | Finding |
|---|---|
| HumanLayer | "Performance degrades at ~40% context utilization -- this is a hard ceiling, not soft guidance" |
| Alex Lavaee (citing Horthy) | Optimal at ~40% context utilization; demonstrated on 300K-line Rust codebase |
| Anthropic | "Context rot: performance degrades as token count increases" |

**What 40% means**: If your model has a 200K token context window, performance starts degrading around 80K tokens of accumulated context (system prompt + conversation history + tool results + file contents).

This is not a soft guideline. It is a measured performance cliff.

---

## Smart Zone vs Dumb Zone

From Horthy's production experience (via Lavaee):

```
Context Utilization:

0%          20%         40%         60%         80%        100%
|-----------|-----------|-----------|-----------|-----------|
            [  SMART ZONE  ]
                        [ degradation begins ]
                                    [  DUMB ZONE  ]
```

**Smart Zone** (~20-40%): Agent has enough context to understand the task and enough headroom to reason effectively. This is where one-shot PRs and multi-hour feature work succeeds.

**Dumb Zone** (>60%): Agent's reasoning degrades. Symptoms and causes:

| Symptom | Likely Cause |
|---|---|
| Agent ignores rules from HARNESS.md | Rules pushed out of attention by conversation length |
| Same edit repeated 3+ times | Context too full to track what was already tried |
| Confidently wrong about file contents | "Lost in the middle" effect -- middle content gets least attention |
| Quality decline after 30+ minutes | Accumulated tool results flooding context |

**First response**: Compact the conversation (summarize and start fresh), do not add more instructions.

---

## Keeping Context Lean

### 1. HARNESS.md / CLAUDE.md Length

HumanLayer recommends under 60 lines. Augment Code says start under 150; 371 is the absolute upper bound. If over 150 lines, split into subdirectory-scoped files or knowledge-base docs.

**Critical**: Put the most important rules early. The "lost in the middle" effect means middle content gets the least attention.

### 2. MCP Tools as Context Tax

Each MCP tool description consumes context tokens. HumanLayer's observation:

> "Too many MCP tools creates a 'dumb zone' where context floods with tool descriptions."

**Rule**: Do not install MCP servers "just in case." Each tool is a context tax even when unused. Only add tools the agent actively needs for current work.

### 3. Verification Output

4,000 lines of passing test output floods context and destroys coherency. HumanLayer's principle:

> "Make verification context-efficient -- surface only errors, not verbose passing output."

**Practical implementation**: Configure test runners to output only failures. Use `--quiet` or `--reporter=min` flags. Your Stop hooks should parse output and surface only actionable information.

### 4. Progressive Disclosure

From Anthropic's context engineering framework:

> Agents incrementally discover relevant context through exploration rather than receiving everything upfront.

**Implementation**: Maintain lightweight identifiers (file paths, module names) in HARNESS.md. Let the agent read full files on demand rather than pre-loading everything into the prompt.

---

## Sub-Agents as Context Firewalls

From HumanLayer and Anthropic's production patterns:

```
Parent Agent (Opus - orchestration)
  |
  |-- Sub-agent A (Sonnet - research)     --> returns 1,000 token summary
  |-- Sub-agent B (Sonnet - code search)  --> returns filepath:line references
  |-- Sub-agent C (Haiku - lint check)    --> returns pass/fail + errors only
```

Each sub-agent gets a clean context window. The parent sees only condensed results. This structurally solves context rot by isolating intermediate noise.

**Best practices** (HumanLayer): return condensed responses with source citations (filepath:line), use Opus for orchestration and Sonnet/Haiku for discrete tasks. Good sub-agent tasks: locating definitions, analyzing patterns, tracing information flow.

---

## Compaction Strategy

From Anthropic: when approaching context limits, summarize while preserving architectural decisions, current task state, and file paths. Discard verbose tool output and intermediate reasoning. Clearing tool results is "the safest, lightest touch form" of compaction.

---

## Anti-Patterns

- **Loading everything upfront**: Dumping all project docs into the system prompt. The agent sees everything and understands nothing.
- **Never compacting**: Letting sessions run for hours. Context fills, agent enters the dumb zone.
- **Adding tools without removing**: Each MCP tool is a permanent context tax. Audit quarterly.

---

## Apply This --> harness/

| Concept | Relevant Templates |
|---|---|
| HARNESS.md structure | `harness/universal/harness-md/standard.md` (concise structure) |
| Knowledge base (on-demand context) | `harness/universal/knowledge-base/` |
| Verification output filtering | `harness/claude-code/hooks/stop/require-tests.sh` (parse for errors only) |
| Context-efficient skills | `harness/claude-code/skills/` (loaded on demand, not always) |

---

## Source

- HumanLayer, "Skill Issue: Harness Engineering for Coding Agents" (40% ceiling, dumb zone, sub-agents) -- see `research/research-06-2026-harness-md-context.md`
- Anthropic, "Effective context engineering for AI agents" (context rot, progressive disclosure, compaction) -- see `research/research-06-2026-harness-md-context.md`
- Alex Lavaee, "How to Harness Coding Agents with the Right Infrastructure" (Smart Zone / Dumb Zone, Horthy's data) -- see `research/research-07-2026-production-cases.md`
- GitHub Blog, "How to write a great agents.md" (structure and length recommendations) -- see `research/research-06-2026-harness-md-context.md`
