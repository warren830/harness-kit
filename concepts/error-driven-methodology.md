# Error-Driven Writing: How to Write Agent Rules That Actually Work

> The core methodology of Harness Engineering.
> This is the single most important guide in harness-kit.

---

## The One Rule

> "Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again."
> — Mitchell Hashimoto, Feb 2026

**Every line in your HARNESS.md should trace back to a specific, observed agent failure.** Not a best practice you read somewhere. Not a rule you think might be useful. A real mistake the agent actually made in your project.

---

## Why This Matters

ETH Zurich studied the effect of HARNESS.md files on agent performance:

| HARNESS.md type | Effect on performance |
|---|---|
| Human-written from observed failures | **+4% improvement** |
| LLM-generated "best practices" | **-20% degradation** |

The LLM-generated rules hurt performance because they add noise. The agent sees 200 lines of generic advice, and the 3 lines that actually matter get lost.

Mitchell Hashimoto's Ghostty project has an HARNESS.md with only 4 lines. Each line fixed a specific agent failure. Result: "almost completely resolved them all."

---

## The Four-Step Loop

```
         ┌─────────────┐
         │  1. OBSERVE  │ ← Let the agent work. Watch what goes wrong.
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │  2. DIAGNOSE  │ ← Why did it fail? Missing info? Wrong tool? No constraint?
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │  3. WRITE     │ ← Add ONE rule addressing that specific failure.
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │  4. VERIFY    │ ← Replay the same task. Did the failure disappear?
         └──────┬───────┘
                │
                └──────→ Back to step 1. Repeat forever.
```

### Step 1: Observe

Give the agent a real task. Don't intervene. Let it fail. Take notes:

- What command did it run that was wrong?
- What file did it look for that doesn't exist?
- What API did it hallucinate?
- What convention did it violate?
- What test did it try to run that isn't set up?

### Step 2: Diagnose

Every agent failure falls into one of four categories:

| Category | Symptom | Solution |
|----------|---------|----------|
| **Missing information** | Agent doesn't know your project's conventions | Add to HARNESS.md |
| **Missing constraint** | Agent violates architectural boundaries | Add linter rule or hook |
| **Missing tool** | Agent can't verify its own work | Create a script or hook |
| **Missing context** | Agent doesn't know about a related file/system | Add to knowledge base or create a Skill |

### Step 3: Write

Write the **minimum** that fixes the failure:

```markdown
<!-- BAD: vague, generic, adds noise -->
- Follow best practices for testing
- Write clean, maintainable code
- Use proper error handling

<!-- GOOD: specific, addresses observed failure -->
- Run tests with `npm test -- --watchAll=false` (not `npm test`, which enters watch mode)
- This project uses pnpm, not npm. All install commands use `pnpm install`
- There are no unit tests in src/inspector/. Do not try to run tests there.
```

### Step 4: Verify

Re-run the exact same task that caused the failure. The rule works if:
- The agent no longer makes that specific mistake
- The agent doesn't get confused by the new rule (no regression)

If verification fails, revise the rule. Maybe it's too vague, or conflicts with another rule.

---

## What TO Write

### 1. Commands the agent gets wrong

```markdown
## Commands
- Install: `pnpm install` (NOT npm or yarn)
- Test: `pnpm test -- --watchAll=false` (watch mode breaks in agent context)
- Build: `pnpm build` (must pass before committing)
- DB migrate: `pnpm prisma migrate dev` (NOT `prisma migrate`, needs pnpm prefix)
```

**Why**: Agents default to `npm` because it's most common in training data. If your project uses `pnpm`, the agent will fail on every install until you tell it.

### 2. Things that don't exist

```markdown
## What Does NOT Exist
- There are no unit tests in `src/legacy/`. Do not try to create or run them.
- There is no `docker-compose.yml`. The app runs directly on the host.
- The `config/` directory is auto-generated. Do not edit files in it.
```

**Why**: Agents hallucinate the existence of common patterns. Explicitly saying "this doesn't exist" prevents them from wasting time looking for something that's not there.

### 3. Project-specific paths and patterns

```markdown
## File Conventions
- React components go in `src/components/[ComponentName]/index.tsx` (not `ComponentName.tsx`)
- API routes follow `src/app/api/[resource]/route.ts` (Next.js App Router pattern)
- Database models are in `prisma/schema.prisma` (single file, not split)
- Environment variables are in `.env.local` (not `.env`)
```

**Why**: Every project has conventions that differ from the default. The agent will use its training data defaults unless you specify yours.

### 4. Verification methods

```markdown
## Verification
After changes, run in this order:
1. `pnpm lint` — must have zero errors
2. `pnpm test -- --watchAll=false` — all tests must pass
3. `pnpm build` — must compile without errors

If any step fails, fix and re-run from step 1.
```

**Why**: Without explicit verification instructions, agents often declare "done" before checking their work. Making verification mandatory (especially with Stop hooks) is the highest-leverage improvement you can make.

### 5. Architecture boundaries

```markdown
## Architecture Rules
- `src/core/` is the protected kernel. NEVER modify files here without explicit approval.
- UI components must NOT import from `src/server/` (client/server boundary)
- All database access goes through `src/repositories/`. Services must NOT use Prisma directly.
```

**Why**: Architectural violations are the most dangerous agent mistakes because they compile and pass tests but create long-term structural debt.

---

## What NOT to Write

### 1. Generic programming advice

```markdown
<!-- DON'T: The agent already knows this -->
- Write clean, readable code
- Use meaningful variable names
- Handle errors appropriately
- Follow SOLID principles
- Write comprehensive tests
```

These add noise without value. The agent's training already covers general programming practices.

### 2. Speculative rules

```markdown
<!-- DON'T: Based on what you imagine might happen -->
- The agent might try to use a deprecated API, so avoid module X
- In case the agent creates too many files, limit to 5 per task
- The agent could potentially introduce security vulnerabilities, so...
```

Only write rules for failures you've actually observed. Speculative rules add noise and may constrain the agent unnecessarily.

### 3. LLM-generated rules

Do not ask an AI to "write an HARNESS.md for my project." The research is clear: this hurts performance. The agent ends up reading generic advice it already knows, drowning out the project-specific rules that actually matter.

### 4. Duplicate information

```markdown
<!-- DON'T: Duplicating what's already in package.json, tsconfig, etc. -->
- Use TypeScript strict mode
- Target ES2022
- Use React 18 with Next.js 14
```

The agent can read your config files. Only document things that aren't discoverable from the codebase itself.

---

## Real-World Examples

### Example 1: Ghostty (Mitchell Hashimoto)

4 lines. Each one solves a specific problem.

```markdown
- The full C API is in `dcimgui.h` in the `.zig-cache` directory
- See the imgui demo source for widget examples
- Use `-Demit-macos-app=false` on macOS builds to verify API usage
- There are no unit tests in this package
```

Why each line exists:
1. Agent hallucinated C APIs → point it to the real header file
2. Agent didn't know where to find widget examples → point to demo source
3. Agent used wrong build flags → specify the correct flag
4. Agent tried to run nonexistent tests → explicitly say there are none

### Example 2: OpenAI Codex Internal Project

~100 lines structured as a "table of contents" pointing to deeper docs:

```markdown
# HARNESS.md

## Quick Start
- Clone and run: `make dev`
- This boots the full stack locally in the current git worktree

## Documentation Map
- Architecture: docs/architecture/overview.md
- API specs: docs/api/
- Design docs: docs/designs/
- Execution plans: docs/plans/

## Architecture (enforced by linters)
Types → Config → Repo → Service → Runtime → UI
Cross-cutting concerns enter through Providers interface only.

## Known Issues
- [specific list of things agents get wrong]
```

Key insight: HARNESS.md is a **table of contents**, not an encyclopedia. It points to detailed docs rather than containing everything.

### Example 3: Growing a Rule File Over Time

Week 1 (day 1 of using AI agent):
```markdown
# HARNESS.md
- Use pnpm, not npm
```

Week 2 (after 5 more observed failures):
```markdown
# HARNESS.md
## Commands
- Use pnpm, not npm
- Test: `pnpm test -- --watchAll=false`

## Conventions
- Components in src/components/[Name]/index.tsx
- Do NOT modify src/core/ without approval
```

Week 4 (after 10+ failures):
```markdown
# HARNESS.md
## Commands
- Use pnpm, not npm
- Test: `pnpm test -- --watchAll=false`
- DB: `pnpm prisma migrate dev`

## Conventions
- Components in src/components/[Name]/index.tsx
- API routes in src/app/api/[resource]/route.ts
- Do NOT modify src/core/ without approval

## Verification
1. pnpm lint
2. pnpm test -- --watchAll=false
3. pnpm build

## What Does NOT Exist
- No tests in src/legacy/
- No docker-compose.yml
```

This is how HARNESS.md should grow: **one line per observed failure, accumulated over time.**

---

## Common Mistakes

### Mistake 1: Writing it all upfront

"Let me write a comprehensive HARNESS.md before we start using the agent."

This always produces generic, low-value rules. You don't know what the agent will get wrong until you let it try.

**Fix**: Start with 0-3 lines. Grow it through observation.

### Mistake 2: Never updating it

You write it once and forget. The project evolves, the rules become stale, the agent starts making mistakes that the outdated rules don't cover.

**Fix**: Treat HARNESS.md like code — it needs maintenance. When you see a new failure, add a rule. When a rule becomes irrelevant, remove it.

### Mistake 3: Making it too long

Past 200 lines, the noise drowns out the signal. Key rules get lost in a sea of generic advice. Agent adherence measurably drops.

**Fix**: If approaching 200 lines, split into:
- HARNESS.md (top-level directory, ~100 lines)
- Subdirectory HARNESS.md files (scoped to specific modules)
- Knowledge base docs (detailed reference the agent can look up when needed)

### Mistake 4: Not verifying rules work

You add a rule, assume it works, move on. But the rule might be too vague, or the agent might interpret it differently than you intended.

**Fix**: Always replay the original failure after adding a rule. If it still fails, the rule needs revision.

---

## Checklist: Is My Rule Good?

Before adding a rule to HARNESS.md, check:

- [ ] Is this based on an observed failure? (not a guess or best practice)
- [ ] Is it specific enough? (mentions exact file paths, commands, or patterns)
- [ ] Is it minimal? (one rule for one problem, not a paragraph)
- [ ] Does it contain information the agent can't discover from the codebase?
- [ ] Have I verified it fixes the original failure?
- [ ] Does it NOT duplicate existing config files (package.json, tsconfig, etc.)?

If any check fails, revise the rule before adding it.

---

## Summary

```
The Golden Rule of Error-Driven Writing:

    Don't tell the agent what's right.
    Tell it what YOU know is wrong — from experience.

Everything else is noise.
```
