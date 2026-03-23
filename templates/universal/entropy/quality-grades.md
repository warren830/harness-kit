---
name: Quality Grade Definitions
description: Standard grading scale for module quality. Used by QUALITY.md and cleanup agents.
---

# Quality Grade Definitions

## Scale

| Grade | Criteria | Agent Permission Level |
|-------|----------|----------------------|
| **A** | >85% test coverage, clean architecture, documented, no known debt | Agent can modify freely |
| **B** | >60% test coverage, mostly clean, minor debt tracked | Agent can modify, should maintain or improve quality |
| **C** | >30% test coverage, some architectural issues, debt accumulating | Agent should add tests for any changes, avoid refactors |
| **D** | <30% test coverage, significant debt, fragile | Agent should make minimal changes, add regression tests |
| **F** | No tests, legacy code, no one understands it | Agent must NOT modify without explicit human approval |

## Grading Process

Monthly review per module:

1. Check test coverage numbers
2. Review recent bug reports in that module
3. Check if architecture docs match implementation
4. Check for TODO/FIXME accumulation
5. Assign grade based on overall assessment

## How Agents Use Grades

Include grades in `docs/QUALITY.md`. Agents read this before modifying code:

- **Grade A-B module**: Proceed normally
- **Grade C module**: Be careful, add tests for changes
- **Grade D module**: Minimal changes only, add regression test
- **Grade F module**: Stop and ask human for guidance

## Grade Transition Rules

- Grades can go **down** at any time (automatic, based on metrics)
- Grades can only go **up** through deliberate improvement effort + review
- A module dropping from B→C triggers an alert for the team
