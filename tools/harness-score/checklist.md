# Harness Maturity Checklist (Manual Version)

> Print this and check off items. Or use `harness-kit score` for automatic assessment.

## How to Score

- Check each item: PASS or FAIL
- Each level is scored 0-10 based on pass rate
- Total: sum of all level scores (max 70)
- Grade: F(0-15) / D(16-30) / C(31-45) / B(46-60) / A(61-70) / S(71+)

---

## Level 1: Rules (0-10)

- [ ] Has HARNESS.md, CLAUDE.md, or equivalent rule file at project root
- [ ] Rule file contains project-specific content (not empty/placeholder-only)

Score: ___ / 10

## Level 2: Constraints (0-10)

- [ ] Linter configured (ESLint, Ruff, or equivalent)
- [ ] Type checking configured (TypeScript strict, mypy, or equivalent)
- [ ] Pre-commit hooks set up (.pre-commit-config.yaml, husky, or equivalent)

Score: ___ / 10

## Level 3: Verification (0-10)

- [ ] Test suite exists (tests/, __tests__/, spec/ directory with actual tests)
- [ ] Test command documented in HARNESS.md / CLAUDE.md

Score: ___ / 10

## Level 4: Feedback Loops (0-10)

- [ ] Architecture document exists (docs/ARCHITECTURE.md or equivalent)
- [ ] Error-driven rules present (Agent Pitfalls section with real observed failures)

Score: ___ / 10

## Level 5: Context Management (0-10)

- [ ] Claude Code Skills directory exists (.claude/skills/) OR Kiro auto-steering files exist
- [ ] Kiro Steering files exist (.kiro/steering/) OR Claude Code Skills exist
- [ ] Path-specific rules exist (.claude/rules/ with path frontmatter OR .github/instructions/)

Score: ___ / 10

## Level 6: Isolation (0-10)

- [ ] Container/isolation config exists (Docker, devbox, or equivalent)
- [ ] Hooks enforce boundaries (.claude/hooks/ or .kiro/hooks/ configured)

Score: ___ / 10

## Level 7: Autonomous (0-10)

- [ ] Entropy management documented (quality grades, golden principles, or cleanup process)
- [ ] CI/CD workflows exist (.github/workflows/ with harness checks)
- [ ] Kiro Specs directory exists (.kiro/specs/) OR execution plans exist (docs/plans/)

Score: ___ / 10

---

## Total

| Level | Score |
|-------|-------|
| 1. Rules | ___ / 10 |
| 2. Constraints | ___ / 10 |
| 3. Verification | ___ / 10 |
| 4. Feedback | ___ / 10 |
| 5. Context | ___ / 10 |
| 6. Isolation | ___ / 10 |
| 7. Autonomous | ___ / 10 |
| **Total** | **___ / 70** |

**Grade**: ___

## What to Improve First

Look at the lowest-scoring levels. Prioritize:
1. Level 3 (Verification) — biggest single-item impact is a Stop hook
2. Level 1 (Rules) — if you don't have HARNESS.md, nothing else matters
3. Level 4 (Feedback) — error-driven rules compound over time
