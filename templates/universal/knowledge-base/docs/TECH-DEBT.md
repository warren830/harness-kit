---
name: Technical Debt Register Template
description: Tracks known debt so agents know what's intentionally imperfect vs. what's a bug.
when_to_use: Projects with accumulated technical debt (most projects after 3+ months).
when_not_to_use: Brand new projects with no debt yet.
---

# Technical Debt Register

> Last reviewed: [YYYY-MM-DD]
> Review frequency: Monthly

## Why This File Exists

Agents often "discover" existing issues and try to fix them mid-task. This wastes time and introduces risk. This register tells agents: "Yes, we know. Don't fix it now."

## Active Debt

| ID | Module | Description | Impact | Priority | Created |
|----|--------|-------------|--------|----------|---------|
| TD-001 | [src/legacy/] | [No test coverage, manual QA only] | [High — risky to modify] | [P2] | [2024-06] |
| TD-002 | [src/utils/] | [~200 lines of dead code] | [Low — clutters codebase] | [P3] | [2024-08] |
| TD-003 | [src/api/] | [N+1 query in user listing endpoint] | [Medium — slow for large datasets] | [P2] | [2025-01] |

## Agent Instructions

- **If you encounter debt during a task**: Note it, but do NOT fix it unless the task specifically asks for it.
- **If debt blocks your task**: Flag it to the human and suggest a minimal workaround.
- **If asked to fix debt**: Check this register first. Follow any notes in the "Approach" column.

## Resolved Debt

| ID | Description | Resolved By | Date |
|----|-------------|-------------|------|
| [TD-000] | [Example: migrated from JavaScript to TypeScript] | [PR #123] | [2024-03] |
