---
name: Knowledge Base Structure
description: A docs/ directory structure that AI agents can navigate. Complements AGENTS.md with deeper reference material.
when_to_use: Any project where AGENTS.md would exceed 100 lines without a knowledge base to point to.
when_not_to_use: Tiny projects where everything fits in AGENTS.md.
---

# Knowledge Base — Usage Guide

## What Is This?

The knowledge base is a structured `docs/` directory that lives in your project. It holds information too detailed for AGENTS.md but essential for agent decision-making.

AGENTS.md acts as the **table of contents**; the knowledge base holds the **chapters**.

```
AGENTS.md                    ← "See docs/ARCHITECTURE.md for architecture details"
docs/
  ARCHITECTURE.md            ← Full architecture documentation
  QUALITY.md                 ← Per-module quality grades
  BELIEFS.md                 ← Non-negotiable principles ("golden rules")
  TECH-DEBT.md               ← Known debt + repayment plans
  designs/                   ← Feature design docs
    TEMPLATE.md
  plans/                     ← Execution plans (OpenAI ExecPlan style)
    PLANS.md
```

## How Agents Use It

1. Agent reads AGENTS.md → sees "For architecture details, see docs/ARCHITECTURE.md"
2. Agent navigates to docs/ARCHITECTURE.md when making architectural decisions
3. Agent checks QUALITY.md before modifying a module to understand its current state
4. Agent reads BELIEFS.md to know what rules are absolute and non-negotiable

## Setup

1. Copy this entire `knowledge-base/` directory to your project root as `docs/`
2. Fill in each template with your project's actual information
3. Add references to AGENTS.md: `For architecture details, see docs/ARCHITECTURE.md`
4. Delete templates you don't need

## Maintenance (Entropy Management)

Knowledge base files can drift from reality. Schedule a monthly review:
- Does ARCHITECTURE.md match the actual code structure?
- Are QUALITY.md grades still accurate?
- Are TECH-DEBT.md items still relevant?

Use `harness-kit scan` to detect drift automatically.
