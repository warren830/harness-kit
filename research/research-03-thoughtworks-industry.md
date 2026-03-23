# Research: Thoughtworks, Stripe & Industry Adoption

## 1. Birgitta Bockeler (Thoughtworks) and Her Framework

**Source:** https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html (Published February 17, 2026)

Birgitta Bockeler, Distinguished Engineer at Thoughtworks, wrote the definitive article on harness engineering as part of Martin Fowler's "Exploring Generative AI" series. Her article analyzes OpenAI's approach to maintaining AI-generated code at scale, breaking it down into three components:

**Context Engineering** -- Continuously enhanced knowledge bases embedded in the codebase, plus dynamic context access including observability data and browser navigation. Bockeler emphasizes this requires significant design work beyond simply curating documentation.

**Architectural Constraints** -- Monitored through both LLM-based agents and deterministic custom linters, structural tests enforcing boundaries, standardized patterns, and module boundary definitions. Focus areas include keeping data structures stable and defining/enforcing module boundaries.

**Entropy Management ("Garbage Collection")** -- Periodic agents that identify documentation inconsistencies and detect architectural constraint violations, fighting codebase decay over time.

**Critical Analysis from Bockeler:**
- The original OpenAI write-up lacks verification of actual functionality and behavior -- a significant gap in the framework
- The OpenAI team invested five months in tooling development with three engineers, producing a million-line product with "no manually typed code at all"
- She raises questions about whether harnesses will evolve into standardized service templates for common application architectures
- She notes the counterintuitive finding that constraining runtime flexibility paradoxically enables greater AI autonomy through well-defined boundaries
- She predicts development may converge around fewer, "AI-friendly" tech stacks
- She questions whether retrofitting harnesses to legacy codebases justifies the effort, comparing it to running static analysis on unmaintained code and "drowning in alerts"

The OpenAI team's perspective as quoted: "When the agent struggles, we treat it as a signal: identify what is missing -- tools, guardrails, documentation" and "Our most difficult challenges now center on designing environments, feedback loops, and control systems."

Bockeler's related articles in the series include:
- "Context Engineering for Coding Agents" (Feb 5, 2026): https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html
- "I Still Care About the Code" (July 9, 2025): https://martinfowler.com/articles/exploring-gen-ai/i-still-care-about-the-code.html
- "The Role of Developer Skills in Agentic Coding" (March 25, 2025): https://martinfowler.com/articles/exploring-gen-ai/13-role-of-developer-skills.html

The context engineering article details specific tools: CLAUDE.md files (always loaded at session start), Rules (loaded when relevant files accessed), Skills (lazy-loaded context), Subagents (separate context windows), MCP Servers (exposing APIs via Model Context Protocol), Hooks (lifecycle-triggered scripts), and Plugins (distribution mechanism). She warns about the "Illusion of Control" -- despite the term "engineering," execution depends on LLM interpretation, and teams should think in probabilities rather than certainties.

---

## 2. Stripe's "Minions" System

**Sources:**
- https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents (Part 1, Feb 9, 2026, by Alistair Gray)
- https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2 (Part 2, Feb 19, 2026, by Alistair Gray)
- https://blog.bytebytego.com/p/how-stripes-minions-ship-1300-prs

**Key Metrics:** More than 1,300 pull requests merged per week, all containing zero human-written code. All PRs are human-reviewed before merging.

**Why Custom-Built:** Stripe's codebase spans hundreds of millions of lines, primarily Ruby with Sorbet typing (an uncommon stack), with extensive proprietary libraries not in standard LLM training data. The code "moves well over $1 trillion per year of payment volume" with complex financial, regulatory, and compliance requirements.

**Architecture Components:**

*Devboxes:* AWS EC2 instances providing standardized, isolated developer environments. They achieve "hot and ready" status within 10 seconds through proactive provisioning with pre-warmed caches and cloned repositories. The article emphasizes devboxes are "cattle, not pets." They operate in QA environments without access to production data or arbitrary network egress. These environments pre-existed for human engineers before agent deployment.

*Agent Harness:* Stripe forked Block's "Goose" coding agent in late 2024 and customized it for their internal LLM infrastructure. Unlike human-supervised tools (Cursor, Claude Code), minions operate fully unattended without interruption capabilities or confirmation prompts.

*Blueprints:* State machines intermixing deterministic nodes (linting, pushing changes) with agentic nodes ("Implement task," "Fix CI failures"). This hybrid orchestration saves tokens and reduces failure opportunities by ensuring critical tasks always execute identically.

*Rule Files:* Cursor-formatted rule files scoped to specific directories and patterns, avoiding context-window bloat from global rules.

*Model Context Protocol (MCP):* Stripe built "Toolshed," a centralized MCP server containing nearly 500 tools for internal systems and SaaS platforms. Minions receive intentionally curated tool subsets relevant to their tasks.

**Development Cycle:**
- Pre-push linting (~5 seconds)
- Selective CI testing from 3+ million total tests
- Automatic fixes for known failure patterns
- Maximum 2 rounds of CI before returning to human engineers
- This intentional cap prevents diminishing returns

**Entry Points:** Slack messages (most common), CLI, web interfaces, and internal applications (docs platform, feature flag system, ticketing UI).

**Key Insight:** The system's success stems less from the AI model itself and more from years of infrastructure investment in developer productivity -- devboxes, testing frameworks, and feedback mechanisms that benefit both humans and agents equally. The philosophy: "If it's good for humans, it's good for LLMs, too."

---

## 3. Thoughtworks Technology Radar Mentions

**Source:** https://www.thoughtworks.com/radar/techniques (Volume 33, November 2025)

"Harness engineering" does not appear as a named blip on the Technology Radar. However, multiple closely related techniques are featured:

**Adopt ring:**
- **Curated Shared Instructions for Software Teams** (https://www.thoughtworks.com/radar/techniques/curated-shared-instructions-for-software-teams) -- Teams using AI in software delivery should move beyond individual prompting to curated instructions committed to project repositories. Tools like Cursor, Windsurf, and Claude Code support sharing instructions. This enables continuous improvement as prompts are refined.
- **Pre-commit Hooks** -- Using Git hooks for early-stage validation, particularly for secret scanning with AI-assisted coding.
- **Using GenAI to Understand Legacy Codebases** -- Leveraging AI tools to accelerate comprehension of complex legacy systems.

**Trial ring:**
- **AGENTS.md** (https://www.thoughtworks.com/radar/techniques/agents-md) -- "A common format for providing instructions to AI coding agents working on a project." Markdown-based with no required fields. Typical uses include tips on using tools in the coding environment, testing instructions, and preferred practices for managing commits.

**Assess ring:**
- **Context Engineering** (https://www.thoughtworks.com/radar/techniques/context-engineering) -- "Systematically designing and optimizing information provided to large language models during inference." Three key areas: context setup, context management for long-horizon tasks, and dynamic information retrieval (JIT context).
- **Team of Coding Agents** (https://www.thoughtworks.com/radar/techniques/team-of-coding-agents) -- "A developer orchestrates multiple AI coding agents, each with a distinct role -- for example, architect, back-end specialist, tester -- to collaborate on a development task." Tools enabling this: Claude Code, Roo Code, Kilo Code.
- **Anchoring Coding Agents to a Reference Application** (https://www.thoughtworks.com/radar/techniques/anchoring-coding-agents-to-a-reference-application) -- Guides generative code agents by providing a live, compilable reference application instead of static prompt examples. Uses MCP servers to expose reference template code and commit diffs.

**Hold ring (cautionary):**
- **Complacency with AI-generated code** -- Quality decline risk.
- **Naive API-to-MCP conversion** -- Exposing security risks.

---

## 4. Other Companies Adopting Harness Engineering Practices

**OpenAI** -- The original practitioners. Their Codex team built a million-line internal product over five months with three engineers using zero hand-written code, averaging 3.5 PRs per engineer daily. They implemented layered domain architecture (Types -> Config -> Repo -> Service -> Runtime -> UI) with 88 AGENTS.md files per subsystem.

**Stripe** -- Minions system producing 1,300+ merged PRs per week (detailed above).

**Anthropic** -- Built a C compiler with 16 parallel Claude agents across ~2,000 sessions producing 100,000 lines of production-grade Rust. Breakthrough came from minimizing context pollution, implementing agent specialization, and using CI as a harness. Their Claude Agent SDK is described as a "general-purpose agent harness" with built-in context management.

**LangChain** -- Demonstrated significant improvements through harness optimization alone (52.8% to 66.5% on Terminal Bench 2.0, moving from Top 30 to Top 5 ranking) without model changes. Their DeepAgents product has "default prompts, tool handling, planning utilities, file system access, and more baked in."

**Peter Steinberger (OpenClaw)** -- Shipped 6,600+ commits monthly while running 5-10 agents simultaneously.

**Mitchell Hashimoto (Ghostty)** -- Documented his six-step AI adoption journey culminating in "Step 5: Engineer the Harness" (https://mitchellh.com/writing/my-ai-adoption-journey). His approach: "I'm making an earnest effort whenever I see an agent do a Bad Thing to prevent it from ever doing that bad thing again." Two mechanisms: better implicit prompting via AGENTS.md files and programmed tools (scripts for screenshots, filtered tests, etc.).

**Multiple tool vendors** have adopted the concept: Cursor (rule files), Claude Code (CLAUDE.md, hooks, skills, subagents), Windsurf, GitHub Copilot (.github/copilot-instructions), and the AGENTS.md standard (collaboratively emerged across OpenAI Codex, Amp, Jules, Cursor, and Factory).

---

## 5. The "Five Core Components" Framework

The exact "five core components" framework naming (context infrastructure, progressive disclosure, self-verification, long-running support architecture, feedback loop systems) does not appear as a single attributed framework in the sources found. However, these concepts appear individually and in various combinations across multiple sources:

**From alexlavaee.me** (https://alexlavaee.me/blog/harness-engineering-why-coding-agents-need-infrastructure/), the "Four Pillars of Harness Engineering":
1. Context Architecture -- Layered, progressive disclosure (Tier 1: auto-loaded project overview; Tier 2: specialized sub-agent context; Tier 3: filesystem knowledge base)
2. Agent Specialization -- Focused agents with restricted tools and scoped prompts
3. Persistent Memory -- Filesystem-backed research documents that survive sessions
4. Structured Execution -- Explicit phases (research -> plan -> execute -> verify) with human review gates

**From harness-engineering.ai** (https://harness-engineering.ai/blog/agent-harness-complete-guide/), six core components in two layers:
- Foundation Layer: Context Engineering, Tool Orchestration, State and Memory Management
- Safety Layer: Verification and Safety, Human-in-the-Loop Controls, Lifecycle Management

**From parallel.ai** (https://parallel.ai/articles/what-is-an-agent-harness), six major components:
1. Tool Integration Layer
2. Memory and State Management
3. Context Engineering & Prompt Management
4. Planning and Decomposition
5. Verification and Guardrails
6. Modularity and Extensibility

**From firecrawl.dev** (https://www.firecrawl.dev/blog/what-is-an-agent-harness), core components:
1. Tool Integration Layer
2. Memory and State Management
3. Context Engineering and Compression
4. Verification and Guardrails

**From nxcode.io** (https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026), three foundational pillars:
1. Context Engineering
2. Architectural Constraints
3. Entropy Management

Progressive disclosure appears prominently in the HumanLayer article (https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents) as a key concept for Skills -- "agents access knowledge only when needed." Self-verification appears as "back-pressure mechanisms" in the same article. Long-running support architecture is discussed in the parallel.ai article under "Long-Horizon Task Management." Feedback loop systems are central to the GTCode article's discussion of CI-as-harness and the iterative improvement cycle.

---

## 6. How Harness Engineering Changes the Role of Software Engineers

Multiple sources converge on a fundamental role transformation:

**From nxcode.io:** "Traditional engineering roles shift from code authorship toward architecture design, specification writing, observability implementation, and rapid iteration on harness configurations."

**From gtcode.com** (https://gtcode.com/articles/harness-engineering/): "Engineers shift from code authors to systems designers, building constraints, feedback loops, documentation structures, and lifecycle tooling." The article details a new investment hierarchy: documentation infrastructure first, then mechanical architectural rule encoding, then agent-observable application legibility, then automated technical debt management.

**From ignorance.ai** (https://www.ignorance.ai/p/the-emerging-harness-engineering): The engineer's job divides into two parts: (1) building the environment (harness engineering) and (2) managing the work (agent orchestration).

**From Kief Morris at martinfowler.com** (https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html): Three positioning models -- "Humans Outside the Loop" (vibe coding), "Humans In the Loop" (micromanagement bottleneck), and the recommended "Humans On the Loop" where humans design and manage the harness that guides agent behavior. This represents engineers as designers of control systems rather than direct code authors.

**From the HumanLayer article:** The core insight is "The model is probably fine. It's just a skill issue." -- suggesting the engineering challenge has moved from writing code to configuring agent environments.

**From Bockeler's "Role of Developer Skills" article:** Developer expertise remains essential for recognizing architectural patterns, understanding technical debt implications, and making pragmatic tradeoffs -- but the mechanism shifts from typing code to reviewing, guiding, and configuring.

---

## 7. Criticism and Limitations of Harness Engineering

**From Andrew Maynard at futureofbeinghuman.com** (https://www.futureofbeinghuman.com/p/what-we-miss-when-we-talk-about-ai-harnesses): Three fundamental criticisms:
1. **False separation of controller and controlled** -- The metaphor assumes humans direct while AI executes, ignoring how AI increasingly exercises operational judgment
2. **Capability without transformation** -- The framework assumes users emerge unchanged; Maynard argues transformation is intrinsic to advanced AI interaction
3. **Instrumental framing** -- The "just a tool" narrative persists despite AI's increasing autonomy. Philosopher Tobias Rees characterizes this as "nostalgia for human exceptionalism"

**From Bockeler (martinfowler.com):** The "Illusion of Control" -- despite the term "engineering," execution depends on LLM interpretation. Context engineering increases effectiveness probabilities but cannot guarantee outcomes. She also notes the missing verification of functionality and behavior in OpenAI's framework.

**From HumanLayer (humanlayer.dev):**
- An ETH Zurich study found LLM-generated AGENTS.md files *hurt* performance by 20%+ while human-written ones helped only ~4%
- Long-context models don't solve fundamental problems -- bigger context means bigger haystacks (needle-in-haystack problem remains)
- Performance starts declining around 40% context utilization in ~168K token windows
- Over-fitting to harnesses: Codex models are tightly coupled to their `apply_patch` tool
- What didn't work: designing ideal configurations preemptively, installing dozens of skills/servers "just in case," running full test suites at every session, micro-optimizing tool access

**From ignorance.ai:** Remaining challenges include preventing poorly-maintainable cruft accumulation, verification at scale, retrofitting brownfield codebases without architectural constraints, and cultural adoption requiring significant upfront investment.

**From Bockeler:** Retrofitting harnesses onto legacy codebases may not justify the effort, similar to running static analysis on unmaintained code and drowning in alerts. The five-month investment timeline demonstrates this is not a quick-start approach.

**From gtcode.com:** Unresolved questions include long-horizon architectural coherence under continuous agent operation, model capability curve and harness component obsolescence, where human judgment compounds most effectively, and generalizability beyond specific repository structures.

---

## 8. Tools and Frameworks That Support Harness Engineering

**Instruction/Configuration Files:**
- **CLAUDE.md** -- Claude Code's project convention file, always loaded at session start. Used for package manager preferences, environment setup, refactoring policies.
- **AGENTS.md** -- Emerging standard collaboratively developed across OpenAI Codex, Amp, Jules, Cursor, and Factory. GitHub analysis of 2,500+ repos identified best practices: commands early, code examples, clear boundaries, tech stack precision. OpenAI's implementation uses 88 AGENTS.md files per subsystem.
- **.github/copilot-instructions** -- GitHub Copilot's equivalent instruction mechanism.
- **Cursor Rule Files** -- Scoped to specific directories and file patterns; Stripe uses this format for Minions.
- **Windsurf** -- Supports sharing instructions through custom workflows.

**Agent Platforms:**
- **Claude Code** -- Full harness ecosystem: CLAUDE.md, Rules, Skills, Subagents, MCP Servers, Hooks, Plugins. Skills enable progressive disclosure. Hooks provide lifecycle-triggered scripts.
- **OpenAI Codex** -- Cloud-based execution with AGENTS.md, explicit permissions, PR-based feedback loops.
- **Cursor** -- IDE-integrated with rule files and agent capabilities.
- **Goose (Block/Square)** -- Open-source coding agent; Stripe forked this for their Minions system.
- **Roo Code, Kilo Code** -- Support subagents and multiple operating modes.
- **Amp** -- Deep mode supporting 30+ minute sessions; preferred by Mitchell Hashimoto.

**Infrastructure Tools:**
- **Model Context Protocol (MCP)** -- Standard for exposing tools and APIs to agents. Stripe's "Toolshed" hosts ~500 tools.
- **Devboxes** -- Isolated execution environments (Stripe's approach on AWS EC2).
- **Pre-commit hooks** -- Deterministic validation before agent commits.
- **Custom linters** -- Mechanical enforcement of architectural constraints.
- **ArchUnit** -- Structural testing framework referenced in Bockeler's work.
- **OpenRewrite** -- Deterministic codemod tool for cases where AI is overkill.

**Frameworks and SDKs:**
- **Anthropic Claude Agent SDK** -- General-purpose agent harness with automatic conversation compaction and tool-use capabilities.
- **LangChain DeepAgents** -- "Default prompts, tool handling, planning utilities, file system access, and more baked in."
- **Firecrawl** -- Web access layer providing search, scrape/crawl, and browser/agent extraction primitives.

**Observability and Verification:**
- **Chrome DevTools Protocol** -- Enables UI-driving, screenshots, DOM snapshots for agent validation.
- **Vector/Victoria Logs/Metrics** -- Ephemeral observability stacks for agent-driven validation.
- **Distributed tracing** -- Queryable traces for agent legibility.
- **CI-as-harness** -- Using existing CI/CD pipelines as the primary feedback mechanism.

**Key Metric:** The competitive advantage has shifted -- "the model is commodity. The harness is moat." Teams using identical models see 40-point differences in task completion rates based solely on harness quality (from harness-engineering.ai).
