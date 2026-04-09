---
name: Execution Plan Template (ExecPlan)
description: Based on OpenAI's PLANS.md pattern. A living document for multi-step agent tasks.
when_to_use: Tasks that require 5+ steps, span multiple files, or take more than one agent session.
when_not_to_use: Simple, single-file changes.
---

# Execution Plan: [Feature/Task Name]

> Status: [PLANNING | IN_PROGRESS | BLOCKED | DONE]
> Owner: [who is driving this]
> Created: [YYYY-MM-DD]
> Updated: [YYYY-MM-DD]

## Goal

<!-- One sentence: what does "done" look like? -->

[When this plan is complete, the system will be able to [do X] so that [user benefit].]

## Context

<!-- Why are we doing this? What triggered it? -->

## Design Reference

<!-- Link to design doc if one exists -->
<!-- See docs/designs/[feature-name].md -->

## Tasks

<!-- Break into discrete, verifiable steps. Agent executes one at a time. -->
<!-- Mark status: [ ] todo, [x] done, [~] in progress, [!] blocked -->

### Phase 1: [Setup/Foundation]

- [ ] [Task 1 description — specific file and expected outcome]
- [ ] [Task 2 description]
- [ ] Verify: [how to confirm Phase 1 is correct]

### Phase 2: [Core Implementation]

- [ ] [Task 3 description]
- [ ] [Task 4 description]
- [ ] [Task 5 description]
- [ ] Verify: [how to confirm Phase 2 is correct]

### Phase 3: [Integration/Cleanup]

- [ ] [Task 6 description]
- [ ] [Task 7: Update tests]
- [ ] [Task 8: Update documentation]
- [ ] Verify: Full test suite passes, lint clean, build succeeds

## Open Questions

<!-- Things that need human input before agent can proceed -->

- [ ] [Question 1]
- [ ] [Question 2]

## Risks

| Risk | Mitigation |
|------|-----------|
| [e.g., Breaking change to API] | [e.g., Version the endpoint, keep old version working] |

## Definition of Done

- [ ] All tasks marked [x]
- [ ] All tests pass
- [ ] Lint + type check clean
- [ ] Documentation updated
- [ ] Plan status set to DONE
