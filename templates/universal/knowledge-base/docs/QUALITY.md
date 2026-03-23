---
name: Quality Grades Template
description: Per-module quality assessment. Helps agents understand which areas need care vs. which are stable.
when_to_use: Projects with multiple modules of varying quality. Especially useful for brownfield projects.
when_not_to_use: Brand new projects where everything is equally fresh.
---

# Quality Grades

> Last reviewed: [YYYY-MM-DD]
> Review frequency: Monthly

## Grading Scale

| Grade | Meaning | Agent Behavior |
|-------|---------|----------------|
| A | Excellent — well-tested, clean, documented | Agent can modify freely |
| B | Good — mostly tested, minor debt | Agent can modify, should add tests for changes |
| C | Fair — some tests, some debt | Agent should be careful, add tests, avoid large refactors |
| D | Poor — few tests, significant debt | Agent should make minimal changes, don't make it worse |
| F | Legacy — no tests, fragile | Agent should NOT modify without explicit approval |

## Module Grades

| Module | Grade | Test Coverage | Notes |
|--------|-------|---------------|-------|
| [src/components/] | [B] | [~70%] | [Missing tests for form components] |
| [src/services/] | [A] | [~90%] | [Well-structured, good error handling] |
| [src/repositories/] | [B] | [~75%] | [Some queries need optimization] |
| [src/legacy/] | [F] | [~5%] | [Do NOT modify without approval] |
| [src/auth/] | [A] | [~95%] | [Security-critical, heavily tested] |
| [src/utils/] | [C] | [~40%] | [Mixed quality, some dead code] |

## Improvement Priorities

<!-- Which modules should be improved first? -->

1. [src/legacy/ — needs test coverage before any changes]
2. [src/utils/ — dead code removal + add missing tests]
3. [src/components/ — form component test coverage]
