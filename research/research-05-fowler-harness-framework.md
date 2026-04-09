# Research: Martin Fowler's Harness Engineering Framework

## Source

**"Harness Engineering for Coding Agent Users"** by Martin Fowler (with Birgitta Böckeler)
URL: https://martinfowler.com/articles/harness-engineering.html
Published: March 2026

This is the first authoritative framework from a major thought leader, formalizing harness engineering as a discipline with precise terminology and taxonomy.

---

## Core Equation

**Agent = Model + Harness**

The harness is everything except the model itself: system prompts, code retrieval, user-built controls, verification tools, and environmental constraints.

---

## The Dual Control Model

Fowler identifies two complementary control mechanisms:

### Guides (Feedforward Controls)
Anticipate unwanted outputs before they occur, steering the agent toward quality on the first attempt.
- Examples: AGENTS.md rules, Skills, architectural constraints, type definitions

### Sensors (Feedback Controls)
Observe after execution, enabling self-correction.
- Examples: test results, linter output, build failures, code review

**Critical insight: "Feedforward-only systems encode rules without verification; feedback-only systems repeat mistakes. Both are necessary."**

---

## Computational vs. Inferential Dimension

Each control (guide or sensor) operates along a second axis:

| | Computational | Inferential |
|---|---|---|
| Speed | Milliseconds to seconds | Seconds to minutes |
| Reliability | Deterministic, 100% | Probabilistic, ~90% |
| Examples | Linters, type checkers, tests | AI code review, AGENTS.md rules |
| Cost | Low (CPU) | High (API calls) |

This creates a 2×2 matrix: {Guide, Sensor} × {Computational, Inferential}

---

## Three Regulation Categories

### 1. Maintainability Harness
Regulates internal code quality. Best-served area — established tooling (linters, formatters, type checkers) provides reliable computational sensors. Inferential sensors can address semantic issues (redundant tests, over-engineering) but less reliably.

### 2. Architecture Fitness Harness
Enforces architectural characteristics through fitness functions — performance requirements, observability standards, dependency rules. Uses ArchUnit-style structural tests and custom rules.

### 3. Behaviour Harness
Addresses functional correctness. **Currently the weakest area.** Most teams rely on AI-generated tests plus manual testing. Trust in auto-generated test quality remains low.

---

## Change Lifecycle Integration

Controls should be distributed across development stages by cost and speed:

- **Pre-integration** (fast, cheap): linters, basic tests, foundational code review
- **Post-integration pipeline** (slower, thorough): mutation testing, architecture reviews, expensive semantic checks
- **Continuous monitoring** (ongoing): drift detection (dead code, coverage decay), runtime feedback (SLO degradation), dependency scanning

---

## New Concepts

### Harnessability
Technology choices affect how effectively you can build harnesses:
- Strongly-typed languages enable type-checking sensors
- Clear module boundaries support architectural fitness functions
- Frameworks reduce agent decision space, making comprehensive harnessing achievable

**Implication for harness-kit:** Different tech stacks have different harnessability profiles. A Python project with no type hints is harder to harness than a TypeScript project with strict mode.

### Ambient Affordances
Environmental properties that influence harness feasibility:
- **Structural legibility**: Can the agent understand the codebase?
- **Navigability**: Can the agent find what it needs?
- **Tractability**: Can the agent make changes safely?

### Ashby's Law Applied
"Regulators need sufficient complexity to govern systems effectively." Committing to defined topologies (service templates, module patterns) reduces the variety agents can produce, making comprehensive harnessing achievable.

### Harness Templates
Bundled guides + sensors for common service topologies (CRUD services, event processors, dashboards). These could become selection criteria for tech stacks.

---

## Human Role Redefinition

Developers bring implicit harnesses through absorbed conventions, intuitive complexity assessment, and organizational alignment. Harnesses externalize this tacit knowledge but cannot fully replace it.

**Key quote: Effective harnesses redirect human effort toward decisions requiring judgment rather than eliminating human involvement.**

---

## Implications for harness-kit

1. The Guides/Sensors taxonomy is more precise than harness-kit's current "deterministic/probabilistic" framing — should consider adopting Fowler's terminology
2. The 2×2 matrix (Guide/Sensor × Computational/Inferential) provides a clearer mental model for organizing templates
3. The Behaviour Harness gap is an opportunity — tools that help teams test agent-generated code more effectively
4. Harnessability is a new concept harness-kit doesn't cover — could be a guide topic
5. Harness Templates align with harness-kit's scenario pack direction
