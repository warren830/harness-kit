# Verification Pyramid: Layered Correctness for Agent-Generated Code

> When agents generate code faster than humans can review, automated verification becomes the primary correctness mechanism.
> Layer your verification from fast/cheap to slow/thorough.

---

## When to Use

- You are designing a verification strategy for an agent-assisted project
- You want to understand which verification tools provide the best return on investment
- You are evaluating whether to invest in formal methods for agent-generated code

## When NOT to Use

- You need to decide how much autonomy to grant -- see [autonomy-grading-guide.md](autonomy-grading-guide.md)
- You want to classify controls as guides vs sensors -- see [fowler-framework-guide.md](fowler-framework-guide.md)

---

## The Scalability Inversion

Traditional software development assumes:
- **Code review** = most scalable verification (every team does it)
- **Formal methods** = least scalable verification (few teams invest)

With AI agents, this **inverts**. Datadog's production experience:

> Agents generate code faster than teams can inspect. Formal methods become more scalable than human review because LLMs can generate TLA+ specs, deterministic simulation harnesses, and verification proofs as pipeline stages.

Code review becomes the bottleneck. Automated verification becomes the throughput enabler.

---

## The Pyramid

From Datadog's harness-first engineering approach, adapted for general use:

```
                    ┌───────────┐
                    │  Formal   │  Highest confidence
                    │  Methods  │  Slowest, most expensive
                  ┌─┴───────────┴─┐
                  │  Model Check  │  Bounded proofs
                  │  / Property   │  of correctness
                ┌─┴───────────────┴─┐
                │  Integration /    │  System-level
                │  Simulation Tests │  behavior validation
              ┌─┴───────────────────┴─┐
              │  Unit Tests            │  Function-level
              │                        │  correctness
            ┌─┴────────────────────────┴─┐
            │  Linters + Type Checkers    │  Fastest, cheapest
            │  + Formatters               │  catches most common issues
            └─────────────────────────────┘
```

Each layer catches a different class of errors. Lower layers run faster and cheaper; upper layers provide stronger guarantees.

---

## Layer Details

| Layer | Catches | Agent Impact |
|---|---|---|
| **L1: Lint + Types** (ms) | Syntax, style, type mismatches | Highest leverage. Run after every edit via PostToolUse hooks. Agents self-correct immediately. |
| **L2: Unit Tests** (sec) | Logic errors, regressions, edge cases | Run at Stop time, not after every edit. `require-tests.sh` blocks completion until tests pass. |
| **L3: Integration** (sec-min) | Cross-component failures, API contracts | Run in CI, not in agent loop. Datadog uses DST at ~5 sec for system-level validation. |
| **L4: Model Check** (30-60s) | Concurrency bugs, state machine violations | Scalability inversion is strongest here. Agents generate property tests humans would take hours to write. |
| **L5: Formal Methods** (min) | Logical correctness proofs | Agents generate TLA+ specs and Kani proofs as pipeline stages. Previously impractical; now accessible. |

---

## Practical Recommendations by Project Type

Not every project needs every layer:

| Project Type | Recommended Layers | Why |
|---|---|---|
| Web app (CRUD) | L1 + L2 + CI integration tests | Standard verification, most bang for buck |
| API service | L1 + L2 + L3 (contract tests) | API contracts are the critical boundary |
| Data pipeline | L1 + L2 + L3 (simulation) | Data correctness requires system-level checks |
| Infrastructure / systems | L1 + L2 + L3 + L4 | Concurrency and state bugs justify model checking |
| Safety-critical | All layers | If a bug has severe consequences, invest in formal methods |

---

## The Observability Feedback Loop

Verification does not end at merge. Datadog's complete loop:

```
Agent generates code
    --> Harness verifies correctness (layers 1-5)
        --> Code ships to production
            --> Telemetry validates behavior
                --> Mismatches refine harness invariants
                    --> Agent iterates with feedback
```

**"Without observability, the loop is not closed."** Production telemetry is the ultimate sensor -- it validates what tests could not predict.

Datadog's key concept: "Every invariant added catches an entire class of bugs across future iterations, not just the diff in front of us."

---

## Verification Timing

Match verification layer to development stage:

| When | What | Speed Target |
|---|---|---|
| After each edit (PostToolUse) | Lint + format | < 5 seconds |
| Before agent stops (Stop hook) | Unit tests | < 1 minute |
| Before merge (CI) | Integration tests, property tests | < 10 minutes |
| In production | Telemetry, SLO monitoring | Continuous |

**Anti-pattern**: Running full test suites (+5 min) after every change. This floods context with verbose output and destroys agent coherency. HumanLayer's advice: surface only errors, not verbose passing output.

---

## Apply This --> harness/

| Layer | Relevant Templates |
|---|---|
| L1: Lint + Type | `harness/claude-code/hooks/post-tool-use/auto-lint.sh`, `auto-format.sh` |
| L2: Unit Tests | `harness/claude-code/hooks/stop/require-tests.sh` |
| L3: Integration | `harness/ci/github-actions/ci.yml` |
| Observability | `harness/claude-code/skills/trace-analysis.md` (session-level) |

---

## Source

- Datadog, "Closing the verification loop: Observability-driven harnesses for AI agents" -- see `research/research-07-2026-production-cases.md`
- HumanLayer, "Skill Issue: Harness Engineering for Coding Agents" (context-efficient verification) -- see `research/research-06-2026-harness-md-context.md`
