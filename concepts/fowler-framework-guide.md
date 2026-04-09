# Fowler's Harness Engineering Framework

> The authoritative taxonomy for classifying harness controls.
> Based on Martin Fowler's "Harness Engineering for Coding Agent Users" (March 2026).

---

## When to Use

- You are designing a harness and need to decide which type of control to add
- You want to audit an existing harness for blind spots (e.g., all guides, no sensors)
- You need a shared vocabulary when discussing harness design with your team

## When NOT to Use

- You are just getting started -- read [getting-started.md](getting-started.md) first
- You need hands-on template setup -- go to `harness/` templates directly

---

## The Core Equation

```
Agent = Model + Harness
```

The model provides intelligence. The harness is everything else: system prompts, retrieval, constraints, verification tools, and environmental controls. Fowler's framework gives us precise language for the harness side.

---

## Two Axes, Four Quadrants

Every harness control is classified along two dimensions:

### Axis 1: Guides vs Sensors

| | Guides (Feedforward) | Sensors (Feedback) |
|---|---|---|
| Timing | Before the agent acts | After the agent acts |
| Purpose | Steer toward quality on the first attempt | Observe and enable self-correction |
| Examples | AGENTS.md rules, Skills, type definitions | Test results, linter output, build failures |

**Fowler's key insight**: "Feedforward-only systems encode rules without verification; feedback-only systems repeat mistakes. Both are necessary."

### Axis 2: Computational vs Reasoning

| | Computational | Reasoning |
|---|---|---|
| Speed | Milliseconds to seconds | Seconds to minutes |
| Reliability | Deterministic, ~100% | Probabilistic, ~90% |
| Cost | Low (CPU) | High (API calls) |
| Examples | Linters, type checkers, tests | AI code review, AGENTS.md rules |

### The 2x2 Matrix

```
                    Computational              Reasoning
                    (deterministic)            (probabilistic)
              ┌─────────────────────────┬─────────────────────────┐
   Guide      │ Linter configs          │ AGENTS.md rules         │
 (feedforward)│ Type definitions        │ Skills / steering docs  │
              │ Build configs           │ Architectural guidance  │
              │ Docker/worktree setup   │ Writing guides          │
              ├─────────────────────────┼─────────────────────────┤
   Sensor     │ Test runners            │ AI code review          │
  (feedback)  │ CI checks               │ Loop detection          │
              │ Auto-lint hooks         │ Pre-completion checklist│
              │ Path restriction hooks  │ Trace analysis          │
              └─────────────────────────┴─────────────────────────┘
```

---

## harness-kit Template Classification

All 70 harness-kit templates classified into the four quadrants:

| Quadrant | Count | Examples |
|---|---|---|
| Guide (Computational) | 18 | `settings-hooks.json`, rules (`api-rules.md`, `test-rules.md`), skills (`api-design.md`, `security-audit.md`), environment scripts (`docker-compose.yml`, `worktree-setup.sh`) |
| Guide (Reasoning) | 35 | AGENTS.md templates, knowledge-base docs, steering docs, specs templates, writing guides |
| Sensor (Computational) | 13 | `block-destructive.sh`, `restrict-paths.sh`, `auto-lint.sh`, `require-tests.sh`, CI workflows |
| Sensor (Reasoning) | 4 | `loop-detection.sh`, `pre-completion-checklist.sh`, `trace-analysis.md`, `weekly-review.md` |

**Observation**: Most templates are Guides (Reasoning) -- the probabilistic feedforward quadrant. The Sensor (Reasoning) quadrant has only 4 templates. This reflects the industry-wide gap Fowler identifies: behavioral verification is the weakest area.

The full classification table is in `aidlc-docs/fowler-classification.md`.

---

## Harnessability

Technology choices affect how effectively you can build harnesses:

| Factor | High Harnessability | Low Harnessability |
|---|---|---|
| Type system | TypeScript strict mode, Rust | Python without type hints, plain JS |
| Module boundaries | Clear service interfaces | Monolithic god classes |
| Framework conventions | Next.js App Router, Rails | Custom framework, no conventions |
| Test infrastructure | Established test suite | No tests, no test framework |

**Practical implication**: A TypeScript project with strict mode, ESLint, and Vitest is easier to harness than a Python project with no type hints and no tests. This is not a judgment on languages -- it is a statement about available computational sensors.

Fowler's related concept of **ambient affordances** describes three environmental properties:
- **Structural legibility**: Can the agent understand the codebase?
- **Navigability**: Can the agent find what it needs?
- **Tractability**: Can the agent make changes safely?

---

## Three Regulation Categories

Fowler identifies three domains where harnesses operate:

1. **Maintainability Harness** -- Internal code quality. Best-served area with established tooling (linters, formatters, type checkers).
2. **Architecture Fitness Harness** -- Structural correctness via fitness functions (dependency rules, performance requirements, ArchUnit-style tests).
3. **Behaviour Harness** -- Functional correctness. Currently the weakest area; most teams rely on AI-generated tests plus manual testing.

---

## Applying This Framework

When adding a new control to your harness, ask:

1. **Guide or Sensor?** Am I preventing a mistake or detecting one?
2. **Computational or Reasoning?** Can a deterministic tool handle this, or does it need LLM judgment?
3. **Which regulation category?** Maintainability, architecture, or behavior?

**Design principle**: Prefer computational controls when possible. They are faster, cheaper, and 100% reliable. Use reasoning controls for things that require judgment (semantic code review, completeness checks).

---

## Apply This --> harness/

| Quadrant | Relevant Templates |
|---|---|
| Guide (Computational) | `harness/claude-code/hooks/settings-hooks.json`, `harness/claude-code/rules/` |
| Guide (Reasoning) | `harness/universal/agents-md/`, `harness/claude-code/skills/` |
| Sensor (Computational) | `harness/claude-code/hooks/pre-tool-use/`, `harness/claude-code/hooks/stop/` |
| Sensor (Reasoning) | `harness/claude-code/hooks/post-tool-use/loop-detection.sh`, `harness/claude-code/skills/trace-analysis.md` |

---

## Source

- Martin Fowler, "Harness Engineering for Coding Agent Users" (March 2026) -- see `research/research-05-fowler-harness-framework.md`
- Classification table -- see `aidlc-docs/fowler-classification.md`
