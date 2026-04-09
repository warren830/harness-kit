# Research: Production Case Studies (2026 Q1)

## Sources

1. **Datadog**: "Closing the verification loop: Observability-driven harnesses for AI agents"
   URL: https://www.datadoghq.com/blog/ai/harness-first-agents/

2. **Harvey AI**: "Harvey Drives Legal Agent Learning Via Harness Engineering"
   URL: https://www.artificiallawyer.com/2026/04/07/harvey-drives-legal-agent-learning-via-harness-engineering/

3. **Escape.tech**: "Everything I Learned About Harness Engineering and AI Factories in San Francisco"
   URL: https://escape.tech/blog/everything-i-learned-about-harness-engineering-and-ai-factories-in-san-francisco-april-2026/

4. **Alex Lavaee**: "How to Harness Coding Agents with the Right Infrastructure"
   URL: https://alexlavaee.me/blog/harness-engineering-why-coding-agents-need-infrastructure/

---

## 1. Datadog: Verification Pyramid & Harness-First Engineering

### Core Thesis

**Harness-first engineering**: automated verification replaces manual code review as the primary correctness mechanism. Formal methods become more scalable than human review when agents generate code faster than teams can inspect.

### Verification Pyramid

| Layer | Tool | Time | Confidence |
|---|---|---|---|
| Symbolic | TLA+ specs | 2 min | Understanding |
| Primary | Deterministic Simulation Testing (DST) | ~5 sec | High |
| Exhaustive | Model checking (Stateright) | 30-60 sec | Proof |
| Bounded | Kani verification | ~60 sec | Bounded proof |
| Empirical | Telemetry + benchmarks | secs-mins | Ground truth |

### Scalability Inversion

Traditional: code review = most scalable, formal methods = least scalable.
**With agents this inverts**: LLMs generate TLA+ specs, DST harnesses, and Kani proofs as pipeline stages. Formal methods become automatable.

### Observability Closes the Loop

1. Agent generates code
2. Harness verifies correctness
3. Production telemetry validates behavior
4. Mismatches refine harness invariants
5. Agent iterates with feedback

**"Without observability, the loop is not closed."**

### Results

- **redis-rust**: 87% memory reduction after agent-optimized iterations
- **Helix** (Kafka-compatible): p50 produce latency 22.2ms vs 116ms baseline Kafka, 93% peak disk throughput

### Key Concept: "Every invariant added catches an entire class of bugs across future iterations, not just the diff in front of us."

---

## 2. Harvey AI: Evaluator-Optimizer Loop for Legal Tasks

### Method

1. Agent attempts legal task
2. LLM judge scores against detailed rubrics with written feedback
3. Coding agent analyzes failures, clusters problems, forms hypotheses
4. Components built or edited based on insights
5. Tasks rerun to test improvements

### Results

- **Baseline**: 40.8% average success across 12 legal tasks
- **Post-optimization**: 87.7% average success
- 7 of 12 tasks exceeded 90%; 1 reached 100%
- 5 tasks started at 2-7% before improvement

### Emergent Capabilities

Through iteration, agents autonomously developed: cross-document review playbooks, stop hooks that validate deliverables, structured fact sheets for drafting, file-conversion pipelines.

### Key Insight

The harness optimization was done by agents themselves in a closed loop — not by humans manually writing rules. This is a step beyond Mitchell Hashimoto's manual error-driven approach.

---

## 3. Escape.tech: San Francisco Field Report (April 2026)

### Industry State

- **"10x productivity since December 2025"** (directional, not audited)
- Overnight agent runs (7-25 hours uninterrupted) are **standard infrastructure**
- The IDE is declining as center of gravity; moving to agent console/orchestration
- Model choice becoming pragmatic: "use both" Claude and GPT-5.4
- OpenAI shipping Codex plugin for Claude Code proves **moat is harness, not model**

### 7-Layer Harness Architecture

1. Intent capture
2. Spec/issue framing
3. Context and instruction layer
4. Execution layer
5. Verification layer
6. Isolation and permission layer
7. Feedback loop

### Autonomy Tiers

| Tier | Task Type | Review |
|---|---|---|
| Full autonomy | Typos, tests, dependency bumps | CI + automated review |
| Light review | Feature work in established patterns | < 5 min human skim |
| Full review | New endpoints, data model changes, auth/payment | Full code review |
| Human-led | Schema migrations, infra, security-critical | Human operates |

### Emerging Tool Stack (March-April 2026)

| Layer | Tool | Notes |
|---|---|---|
| Spec | OpenSpec | ~250-line spec before coding, 27K+ stars |
| Review | Codex Plugin for Claude Code | `/codex:review`, open-sourced 3/30 |
| Review | CodeRabbit | 2-3M repos connected, 75M defects found |
| Review | Taskless | Converts review corrections into tree-sitter rules |
| Memory | Claude-Mem | Auto-captures session activity, 44K+ stars |
| Isolation | Superset | Worktree isolation per agent, launched 3/2026 |
| Isolation | Coasts | Containerized runtime per worktree |
| Terminal | cmux | GPU-accelerated, per-agent status indicators |
| Branching | GitButler | Virtual branching, guaranteed clean merge |
| Orchestration | Conductor (gstack) | 10-15 parallel agent sprints |

### Role Changes

- **"Builder" profile emerging**: owns problems end-to-end, uses agents to cover skill gaps
- PM role moving upstream (less ticket translation, more judgment)
- Work that remains human: architecture decisions, design direction, product judgment, priority tradeoffs

### Measurement Recommendations

- Weekly: review regressions, convert failures into rules
- Monthly: reclassify work tiers, audit velocity vs impact
- Quarterly: revisit stack, permissions, costs, staffing
- Key metrics: lead time, autonomy rate, reopen/rollback rate, wasted work rate, API cost per engineer

---

## 4. Alex Lavaee: Four Pillars Framework

### Finding: 5 Independent Teams Converged

OpenAI, Anthropic, Huntley, Horthy, and Vasilopoulos independently arrived at similar conclusions.

### Pillar 1: Context Architecture (Tiered)

- **Tier 1 (Hot Memory)**: Auto-loaded each session. Project conventions, quick reference.
- **Tier 2 (Specialized)**: Loaded when specific sub-agents activate.
- **Tier 3 (Cold Storage)**: Research docs, specs, session history. Queried on demand.

**Hard ceiling: performance degrades beyond ~40% context utilization.**

### Pillar 2: Agent Specialization

Deploy focused agents with constrained permissions:
- Research agents: read-only
- Planners: analyze without write access
- Workers: scoped to single tasks
- Reviewers: flag but don't modify

Anthropic's compiler: 16 parallel specialized agents, 2,000 sessions, ~$20K for 100K lines of production Rust.
Vasilopoulos: 19 domain-specific agents, 108K LOC C# system.

### Pillar 3: Persistent Memory (Filesystem > Conversation)

Progress lives on disk, not in context windows:
- OpenAI: AGENTS.md as living feedback loop
- Anthropic: git-tracked task files
- Huntley: `IMPLEMENTATION_PLAN.md` + `progress.txt`

Each session rebuilds from filesystem. This prevents context window degradation.

### Pillar 4: Structured Execution

Research → Plan → Execute → Verify, with human checkpoints.

Horthy's "Frequent Intentional Compaction": workflows designed to keep context utilization between 40-60%.

### Backpressure Principle (Huntley)

**"The more you capture the backpressure, the more autonomy you can grant."**

- Upstream constraints: deterministic setup, consistent context, established patterns
- Downstream constraints: tests, type checks, linters, builds, security scanners
- More downstream constraints → safer to grant upstream autonomy

### Smart Zone / Dumb Zone (Horthy)

- Optimal: ~40% context utilization
- Demonstrated on 300K-line Rust codebase: bug fix as one-shot PR, 35K-line feature in 7 hours

### Key Insight

**"Better models demand better infrastructure."** Opus 4.5 needed one harness design; Opus 4.6 required redesign. Capability increases amplify importance of scaffolding.

---

## Cross-Cutting Themes

### What All Sources Agree On

1. **Model is commodity, harness is moat** — OpenAI shipping Codex plugin for Claude Code proves this
2. **Verification > advice** — deterministic checks prevent errors better than refined prompts
3. **Context has a hard ceiling** — ~40% utilization, not soft guidance
4. **Iteration > planning** — start simple, add rules when agent fails
5. **Filesystem > conversation** — persistent memory beats context window
6. **Backpressure enables autonomy** — more constraints = more freedom to delegate

### What's New Since harness-kit v0.1.0 (March 2026)

| Concept | Source | Status in harness-kit |
|---|---|---|
| Guides/Sensors taxonomy | Fowler | Not covered |
| 40% context ceiling | Lavaee, HumanLayer | Not covered |
| Autonomy tiers | Escape.tech | Not covered |
| Verification pyramid | Datadog | Not covered |
| Evaluator-Optimizer loop | Harvey | Not covered |
| Three-tier permissions (✅/⚠️/🚫) | GitHub, Augment | Partially covered |
| Sub-agents as context firewalls | HumanLayer, Anthropic | Not covered |
| Harnessability | Fowler | Not covered |
| Smart Zone / Dumb Zone | Horthy via Lavaee | Not covered |
| Backpressure principle | Huntley via Lavaee | Partially covered (hooks) |
