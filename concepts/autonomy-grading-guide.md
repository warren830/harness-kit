# Autonomy Grading: How Much Freedom Should Your Agent Have?

> Not all tasks deserve the same level of agent independence.
> Classify work into tiers, then match controls to risk.

---

## When to Use

- You are deciding which tasks to delegate fully vs which need human review
- You want a repeatable framework for expanding agent autonomy over time
- You are setting up permission boundaries in HARNESS.md or hooks

## When NOT to Use

- You have no harness yet -- build basic verification first (see [getting-started.md](getting-started.md))
- You want to grade the quality of agent output -- see [verification-pyramid-guide.md](verification-pyramid-guide.md) instead

---

## The Four-Tier Model

From Escape.tech's field research across San Francisco engineering teams (April 2026):

| Tier | Task Type | Review Required | Examples |
|---|---|---|---|
| **Fully Autonomous** | Trivial, low-risk | CI + automated review only | Typo fixes, test additions, dependency bumps, formatting |
| **Light Review** | Established patterns | < 5 min human skim | Feature work following existing patterns, bug fixes with tests |
| **Full Review** | New patterns, sensitive areas | Full code review | New API endpoints, data model changes, auth/payment logic |
| **Human-Led** | High-risk, irreversible | Human operates, agent assists | Schema migrations, infrastructure changes, security-critical code |

**The key insight**: Autonomy is not binary. "Can the agent do this?" is the wrong question. The right question is "How much oversight does this task need?"

---

## Permission Boundaries

Each tier maps to a three-tier permission system found across GitHub's 2,500-repo analysis and Augment Code's guidelines:

```
Always do   -- Agent proceeds without asking
Ask first   -- Agent proposes, human approves
Never do    -- Agent must not attempt this
```

### Example Permission Table (customize for your project)

```markdown
### Always (agent proceeds autonomously)
- Run tests and linters
- Fix lint errors in files being edited
- Create unit tests for new functions

### Ask First (agent proposes, waits for approval)
- Create new files outside existing module structure
- Modify database schema or migrations
- Add new dependencies

### Never (agent must not attempt)
- Delete or modify applied migration files
- Push directly to main/production branches
- Modify auth logic without review
```

---

## Matching Tiers to Controls

Each tier requires different harness controls:

| Tier | Guide Controls | Sensor Controls |
|---|---|---|
| Fully Autonomous | HARNESS.md conventions | Auto-lint, auto-format, CI pipeline |
| Light Review | HARNESS.md + relevant skills | Tests + lint + brief human skim |
| Full Review | Architecture constraints, design doc | Full test suite + human code review |
| Human-Led | Step-by-step instructions | Human verifies each step |

---

## The Backpressure Principle

From Huntley's production experience (cited in Lavaee's four-pillar analysis):

> "The more you capture the backpressure, the more autonomy you can grant."

Backpressure means downstream verification constraints:

```
More downstream constraints    -->    Safer to grant upstream autonomy
(tests, type checks, linters)        (less human review needed)

Fewer downstream constraints   -->    More human oversight required
(no tests, no types, no lint)         (agent operates in the dark)
```

**Practical example**: A TypeScript project with 80% test coverage, strict ESLint, and CI enforcement can safely grant Fully Autonomous status to many tasks. A Python script with no tests and no linting needs Full Review for almost everything.

---

## Growing Autonomy Over Time

Autonomy is not static. Reclassify monthly as your harness improves:

**Week 1**: Most tasks are Full Review or Human-Led
- You are still learning what the agent gets wrong
- Harness has minimal controls

**Month 1**: Some tasks move to Light Review
- Error-driven rules cover common failure modes
- Basic hooks enforce verification

**Month 3**: Routine tasks become Fully Autonomous
- Comprehensive test coverage provides backpressure
- Permission boundaries are well-established
- CI catches what hooks miss

Escape.tech recommends: weekly regression review, monthly tier reclassification, quarterly permission and cost audits. Track lead time, autonomy rate, reopen/rollback rate, and wasted work rate.

---

## Anti-Patterns

### Granting full autonomy on day one
Without sufficient backpressure (tests, lint, type checks), autonomous agents accumulate technical debt faster than humans can detect. Start conservative.

### Never promoting tasks to higher autonomy
If your agent handles Light Review tasks without issues for a month, promote them. Unnecessary human review is wasted engineering time.

### One-size-fits-all permissions
Different parts of the codebase have different risk profiles. `src/utils/` may be Fully Autonomous while `src/auth/` stays Human-Led. Use subdirectory-scoped HARNESS.md files or path-restriction hooks.

---

## Apply This --> harness/

| Concept | Relevant Templates |
|---|---|
| Permission boundaries | `harness/universal/harness-md/standard.md` (three-tier section) |
| Path restrictions | `harness/claude-code/hooks/pre-tool-use/restrict-paths.sh` |
| Destructive command blocking | `harness/claude-code/hooks/pre-tool-use/block-destructive.sh` |
| Verification gates | `harness/claude-code/hooks/stop/require-tests.sh`, `require-lint.sh` |

---

## Source

- Escape.tech, "Everything I Learned About Harness Engineering and AI Factories in San Francisco" (April 2026) -- see `research/research-07-2026-production-cases.md`
- Alex Lavaee, "How to Harness Coding Agents with the Right Infrastructure" (Huntley's backpressure principle) -- see `research/research-07-2026-production-cases.md`
- GitHub Blog, "How to write a great agents.md" (three-tier permissions) -- see `research/research-06-2026-harness-md-context.md`
