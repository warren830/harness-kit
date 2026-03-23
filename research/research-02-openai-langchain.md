# Research: OpenAI Report & LangChain Case Studies

## 1. OpenAI Official Report: "Harness Engineering: Leveraging Codex in an Agent-First World"

**URL:** https://openai.com/index/harness-engineering/
**Published:** February 11, 2026
**Author:** Ryan Lopopolo, Member of the Technical Staff
**Acknowledgements:** Victor Zhu and Zach Brock

### The Case Study: 3 Engineers, ~1 Million Lines of Code, 5 Months

Key facts and direct quotes:

- **"Over the past five months, our team has been running an experiment: building and shipping an internal beta of a software product with 0 lines of manually-written code."**
- First commit landed **late August 2025** to an empty repository
- **"Five months later, the repository contains on the order of a million lines of code across application logic, infrastructure, tooling, documentation, and internal developer utilities."**
- **"Over that period, roughly 1,500 pull requests have been opened and merged with a small team of just three engineers driving Codex."**
- **"This translates to an average throughput of 3.5 PRs per engineer per day, and surprisingly the throughput has increased as the team has grown to now seven engineers."**
- **"We estimate that we built this in about 1/10th the time it would have taken to write the code by hand."**
- Used **Codex CLI using GPT-5** for the initial scaffold
- **"Throughout the development process, humans never directly contributed any code. This became a core philosophy for the team: no manually-written code."**

### The Core Philosophy

**"Humans steer. Agents execute."**

**"We intentionally chose this constraint so we would build what was necessary to increase engineering velocity by orders of magnitude. We had weeks to ship what ended up being a million lines of code."**

### The "Never Make That Mistake Again" Concept

The article frames this as: **"When the agent struggles, we treat it as a signal: identify what is missing—tools, guardrails, documentation—and feed it back into the repository, always by having Codex itself write the fix."**

And: **"what capability is missing, and how do we make it both legible and enforceable for the agent?"**

### Framework for Harness Engineering Components

The article describes these interconnected components:

**A. Repository Knowledge as System of Record**
- AGENTS.md as **"the table of contents"** not an encyclopedia (~100 lines)
- Structured `docs/` directory with design-docs, exec-plans, product-specs, references
- **Progressive disclosure**: "agents start with a small, stable entry point and are taught where to look next, rather than being overwhelmed up front"
- Linters and CI jobs validate knowledge base is up to date

**B. Agent Legibility**
- **"From the agent's point of view, anything it can't access in-context while running effectively doesn't exist."**
- Knowledge in Google Docs, Slack, people's heads is invisible to agents
- Favored "boring" technologies for composability and training set representation
- Sometimes reimplemented library subsets rather than using opaque upstream behavior

**C. Architectural Constraints (Enforced Mechanically)**
- Rigid layered domain architecture: Types -> Config -> Repo -> Service -> Runtime -> UI
- Cross-cutting concerns enter through single explicit "Providers" interface
- Custom linters and structural tests enforce dependency directions
- **"In a human-first workflow, these rules might feel pedantic or constraining. With agents, they become multipliers: once encoded, they apply everywhere at once."**
- Linter error messages double as remediation instructions injected into agent context

**D. Increasing Application Legibility (Agent Environments)**
- App bootable per git worktree (one instance per change)
- Chrome DevTools Protocol wired into agent runtime with skills for DOM snapshots, screenshots, navigation
- Full local observability stack: Vector -> Victoria Logs/Metrics/Traces, queryable via LogQL/PromQL/TraceQL
- Ephemeral per-worktree, torn down after task completion
- **"We regularly see single Codex runs work on a single task for upwards of six hours (often while the humans are sleeping)."**

**E. Throughput Philosophy**
- **"corrections are cheap, and waiting is expensive"**
- Minimal blocking merge gates, short-lived PRs
- Agent-to-agent review (Ralph Wiggum Loop pattern)

**F. Entropy and Garbage Collection**
- **"Our team used to spend every Friday (20% of the week) cleaning up 'AI slop.' Unsurprisingly, that didn't scale."**
- "Golden principles" encoded into repo with recurring cleanup agents
- Background Codex tasks scan for deviations, update quality grades, open refactoring PRs
- **"Technical debt is like a high-interest loan"**

**G. Increasing Levels of Autonomy**
A single prompt can now trigger: validate codebase -> reproduce bug -> record video of failure -> implement fix -> validate fix by driving app -> record resolution video -> open PR -> respond to feedback -> detect/remediate build failures -> escalate only when judgment needed -> merge

### What They're Still Learning

**"Our most difficult challenges now center on designing environments, feedback loops, and control systems that help agents accomplish our goal: build and maintain complex, reliable software at scale."**

---

## 2. LangChain Case Study: Terminal Bench 2.0 Score Improvement

**Source:** Vivek Trivedy (LangChain), published as X article
**URL:** https://x.com/Vtrivedy10/status/2023805578561060992
**Also referenced in:** https://blog.langchain.com/the-anatomy-of-an-agent-harness/ (March 10, 2026)

### The Numbers

- **Starting score: 52.8%** with default prompt and standard tools+middleware using GPT-5.2-Codex (just outside Top 30)
- **Final score: 66.5%** - an improvement of **13.7 percentage points**
- **Moved from Top 30 to Top 5** on Terminal Bench 2.0
- **Only the harness was changed; the model (GPT-5.2-Codex) was kept fixed**

### Terminal Bench 2.0 Leaderboard Context (from tbench.ai)

- ForgeCode agent with Opus 4.6: 81.8% +/- 1.7 (Rank 1)
- Anthropic's Claude Code with Opus 4.6: 58.0% +/- 2.9 (Rank 39)
- Claude Code with Opus 4.5: 52.1% +/- 2.5 (Rank 48)
- Deep Agents (LangChain) with GPT-5.2-Codex: 66.5% +/- 3.1 (Rank 21)
- Terminal Bench has 89 tasks across ML, debugging, biology domains

### Their Improvement Recipe

Three optimization knobs: **System Prompt, Tools, and Middleware** (hooks around model and tool calls)

**Step 1 - Automated Trace Analysis Skill:**
1. Fetch experiment traces from LangSmith
2. Spawn parallel error analysis agents; main agent synthesizes findings + suggestions
3. Aggregate feedback and make targeted changes to the harness
- Human helpful but not required in step 3
- Changes that overfit to a task are bad for generalization

**Step 2 - Self-Verification:**
Added structured problem-solving guidance:
1. Planning & Discovery: Read task, scan codebase, build initial plan
2. Build: Implement with verification in mind, build tests
3. Verify: Run tests, compare against spec (not own code)
4. Fix: Analyze errors, revisit original spec

Used **PreCompletionChecklistMiddleware** that intercepts agent before exit and forces verification pass (similar to Ralph Loop).

**Step 3 - Context Engineering:**
- **LocalContextMiddleware**: maps cwd and directories on agent start, discovers available tools
- Teaching agents their code will be measured against programmatic tests
- **Time budgeting**: inject time budget warnings to nudge shift to verification

**Step 4 - Loop Detection:**
**LoopDetectionMiddleware** tracks per-file edit counts via tool call hooks, adds context like "consider reconsidering your approach" after N edits to same file.

**Step 5 - Reasoning Compute Optimization:**
- GPT-5.2-Codex has 4 reasoning modes: low, medium, high, xhigh
- Running only xhigh scored **53.9%** due to timeouts vs **63.6%** at high
- Used **"xhigh-high-xhigh reasoning sandwich"** (more compute for planning and verification, less for implementation)
- Final score: **66.5%**

**Cross-model note:** A test run with Claude Opus 4.6 scored **59.6%** with an earlier harness version, competitive but worse than Codex because they hadn't run the same improvement loop with Claude.

### Key Principles from Vivek Trivedy

1. Context Engineering on behalf of agents reduces error surface
2. Help agents self-verify aggressively
3. Tracing as feedback signal for self-evaluation
4. Detect and fix bad patterns (guardrails that will dissolve as models improve)
5. Tailor harnesses to models - principles generalize but iterations help per-model

### From the Anatomy Blog Post

**"Agent = Model + Harness. If you're not the model, you're the harness."**

Vivek Trivedy is credited with coining the term "harness engineering" in the HumanLayer article, described as **"leveraging configuration points to customize and improve your coding agent's output quality and reliability."**

---

## 3. Additional Key Sources

### Martin Fowler / Thoughtworks Analysis (Feb 17, 2026)
**URL:** https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html
**Author:** Birgitta Boeckeler

Identified OpenAI's three harness categories:
1. **Context engineering** - continuously enhanced knowledge base; dynamic context like observability data and browser navigation
2. **Architectural constraints** - monitored by LLM-based agents plus deterministic custom linters and structural tests
3. **"Garbage collection"** - periodic agents finding documentation inconsistencies and architectural constraint violations

### The Emerging Harness Engineering Playbook (Feb 24, 2026)
**URL:** https://www.ignorance.ai/p/the-emerging-harness-engineering

Additional case studies:
- **Stripe's Minions**: 1,000+ merged PRs/week, 400+ internal tools via MCP "Toolshed", agents in pre-warmed devboxes
- **Peter Steinberger (OpenClaw)**: 6,600+ commits/month, runs 5-10 agents simultaneously

### AgentsMesh Case Study (March 14, 2026)
**URL:** https://agentsmesh.ai/blog/building-agentsmesh-with-agentsmesh

One person, 52 days, **965,687 lines** of code throughput (356,220 lines still standing), 600 commits. Hit cognitive bandwidth ceiling around day 5 at ~50,000 lines/day with 3 concurrent worktrees.

---

## 4. Mitchell Hashimoto's Original Framing

Referenced across multiple sources. The HumanLayer article (March 12, 2026, https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents) attributes this exact quote to Hashimoto:

**"anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again."**

The OpenAI article's version of this same concept: **"When the agent struggles, we treat it as a signal: identify what is missing—tools, guardrails, documentation—and feed it back into the repository."**
