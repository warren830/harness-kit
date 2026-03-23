---
name: Design Document Template
description: For documenting feature designs before implementation. Includes verification status field.
when_to_use: New features that affect architecture or span multiple modules.
when_not_to_use: Bug fixes or small changes contained within a single file.
---

# Design: [Feature Name]

> Status: [DRAFT | REVIEW | APPROVED | IMPLEMENTED | DEPRECATED]
> Author: [name]
> Date: [YYYY-MM-DD]
> Reviewers: [names]

## Problem

<!-- What problem does this solve? Why now? -->

## Proposed Solution

<!-- How will we solve it? Be specific about approach. -->

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| [Option A] | | | |
| [Option B] | | | |

## Technical Design

### Data Model Changes

<!-- New tables, columns, types? -->

### API Changes

<!-- New endpoints? Changed signatures? -->

### Architecture Impact

<!-- Which modules are affected? Any new dependencies between layers? -->

## Verification Plan

<!-- How will we know it works? -->

- [ ] Unit tests for [specific logic]
- [ ] Integration tests for [specific flow]
- [ ] Manual verification of [specific behavior]

## Rollout Plan

<!-- How will we ship this safely? -->

1. [Feature flag: off by default]
2. [Deploy to staging]
3. [Enable for internal users]
4. [Gradual rollout to 10% → 50% → 100%]
