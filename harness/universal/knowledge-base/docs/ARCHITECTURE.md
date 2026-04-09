---
name: Architecture Document Template
description: Describes your system's architecture so agents make structurally sound decisions.
when_to_use: Any project with more than one layer or module.
---

# Architecture

> Last updated: [YYYY-MM-DD]
> Owner: [team/person responsible for architecture decisions]

## Overview

<!-- 2-3 sentences: what the system does at the highest level -->

## System Diagram

<!-- ASCII or Mermaid diagram. Agents can read both. -->
<!-- Example:
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client   │────→│  API     │────→│  Database │
│  (React)  │     │ (Express)│     │ (Postgres)│
└──────────┘     └──────────┘     └──────────┘
                       │
                  ┌────▼─────┐
                  │  Queue    │
                  │  (SQS)   │
                  └──────────┘
```
-->

## Layers

<!-- List each layer/module, its responsibility, and what it can import from -->

| Layer | Responsibility | Can Import From |
|-------|---------------|-----------------|
| [UI / Pages] | [User interface, routing] | [Services, Types] |
| [Services] | [Business logic, orchestration] | [Repositories, Types] |
| [Repositories] | [Data access, caching] | [Types] |
| [Types] | [Shared type definitions] | [Nothing — leaf layer] |

**Import rule**: Dependencies flow downward only. A layer must NEVER import from a layer above it.

## Key Modules

<!-- For each significant module, describe its purpose and boundaries -->

### [Module Name]

- **Location**: `[src/module-name/]`
- **Purpose**: [What it does]
- **Public API**: [What other modules can use — exported functions/types]
- **Internal**: [What should NOT be accessed from outside]

## Data Flow

<!-- How data moves through the system for a typical request -->

```
[1. Client sends request
 2. API route validates input (zod schema)
 3. Service layer applies business logic
 4. Repository layer queries database
 5. Response flows back through the same layers]
```

## Key Design Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| [e.g., PostgreSQL over MongoDB] | [Team expertise + relational data model] | [2024-01] | Active |
| [e.g., Server components by default] | [Reduce client JS bundle] | [2024-03] | Active |
| [e.g., Monolith over microservices] | [Team size doesn't justify distributed complexity] | [2024-01] | Active |

## What NOT to Change Without Discussion

<!-- Protected areas that agents should not modify without explicit human approval -->

- [`src/core/`] — [Core business rules, changes need architecture review]
- [`prisma/schema.prisma`] — [Database schema, changes need migration plan]
- [`src/auth/`] — [Authentication, security-sensitive]
