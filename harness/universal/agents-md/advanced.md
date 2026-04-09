---
name: "AGENTS.md Advanced"
description: For enterprise, high-risk, or compliance-sensitive projects. ~150 lines.
when_to_use: Projects requiring audit trails, strict boundaries, role-based agents, or regulatory compliance.
when_not_to_use: Early-stage projects or small teams (use standard.md) — this level of constraint adds overhead.
---

<!-- Copy to your project root as AGENTS.md.
     Replace ALL [brackets]. Delete agent roles you don't use.
     This template enforces role-based boundaries — each agent type
     has explicit scope. Target: ~120-150 lines after customization. -->

# AGENTS.md

[Project name]: [One sentence description].

Tech stack: [e.g., Java 21, Spring Boot 3.2, PostgreSQL 16, Flyway, React 18, TypeScript 5.4]

## Commands

```bash
# Backend
[./gradlew build]                  # build — includes compile + tests
[./gradlew test]                   # unit tests only
[./gradlew integrationTest]        # integration tests (needs DB)
[./gradlew spotlessApply]          # format code
[./gradlew spotlessCheck]          # lint — must pass in CI

# Frontend
[pnpm --filter web install]        # install frontend deps
[pnpm --filter web test]           # frontend tests
[pnpm --filter web build]          # frontend build

# Infrastructure
[./gradlew flywayMigrate]          # run DB migrations
[docker compose up -d postgres]    # start local DB
```

## Boundaries

Always:
- Run the full verification checklist before declaring work done
- Include unit tests for any new business logic
- Use existing error-handling patterns — check 2-3 similar files before writing new ones
- Log security-relevant actions (auth, data access, permission changes)

Ask first:
- Adding or upgrading dependencies
- Modifying database migrations or schema
- Changing API contracts (request/response shapes)
- Modifying CI/CD pipeline configuration
- Any change touching authentication or authorization logic

Never:
- Commit secrets, tokens, or credentials (even in tests — use fixtures)
- Modify files in [src/generated/] — these are code-generated
- Bypass or disable security checks, even temporarily
- Run `flyway clean` — destroys all data and migrations
- Delete or weaken existing tests to make new code pass

## Agent Roles

<!-- Define scoped agent types. Each role has clear boundaries.
     Agents should only operate within their declared scope.
     See GitHub data: specialized roles with constraints >> generic "helpful assistant". -->

### @dev-agent (default)
Scope: [src/main/, src/test/, web/src/]
Can: write code, write tests, run builds
Cannot: modify migrations, CI config, or infrastructure
Verify: `./gradlew build && pnpm --filter web build`

### @test-agent
Scope: [src/test/, web/src/**/*.test.*]
Can: create tests, update test fixtures, run test suites
Cannot: modify production code, remove failing tests
Verify: `./gradlew test && pnpm --filter web test`

### @docs-agent
Scope: [docs/, README.md, CHANGELOG.md]
Can: read all code, write documentation
Cannot: modify any source code or configuration
Verify: links resolve, code examples compile

### @migration-agent
Scope: [src/main/resources/db/migration/]
Can: create new migration files (never modify existing)
Cannot: edit existing migrations, run `flyway clean`
Verify: `./gradlew flywayMigrate` succeeds on clean DB

### @deploy-agent
Scope: [infra/, .github/workflows/]
Can: modify deployment configs for dev/staging only
Cannot: modify production deployment without explicit approval
Verify: `terraform plan` shows expected changes

## Code Style

<!-- Concrete examples for patterns agents get wrong. -->

```java
// Exception handling: use domain exceptions, not generic ones
// Good:
throw new OrderNotFoundException(orderId);

// Bad:
throw new RuntimeException("Order not found: " + orderId);  // WRONG
```

```java
// API responses: always wrap in ApiResponse, never return raw entities
// Good:
return ApiResponse.ok(OrderDto.from(order));

// Bad:
return ResponseEntity.ok(order);  // WRONG — leaks entity to client
```

```typescript
// Frontend: use server actions for mutations, not client-side fetch
// Good:
const result = await createOrder(formData);  // server action

// Bad:
const res = await fetch("/api/orders", { method: "POST" });  // WRONG
```

## Security Constraints

<!-- Non-negotiable security rules. -->

- All user input must be validated at the controller layer using [Jakarta Validation]
- SQL queries use parameterized statements only — no string concatenation
- API endpoints require authentication unless explicitly listed in [SecurityConfig.permitAll()]
- PII fields are logged as `[REDACTED]`, never in plaintext
- Test fixtures use synthetic data, never real customer data

## What Does NOT Exist

- [No microservices — this is a modular monolith]
- [No GraphQL — REST only with OpenAPI specs]
- [No ORM lazy loading — all queries are explicit in repositories]

## Pitfalls

<!-- Start empty. Add from observed failures only.
     This section is critical for enterprise projects — agent mistakes
     in auth/data/security code are expensive.

     Example entries (replace with real observations):
     - Flyway versions are V001__, V002__ etc. — never reuse a version number
     - The SecurityConfig allowlist is order-sensitive — add new paths BEFORE the catch-all
     - Test DB runs on port 5433, not 5432 — check application-test.yml -->

## Verification

After modifying code, run in order:
```bash
# Backend
[./gradlew spotlessCheck]          # 1. code format
[./gradlew test]                   # 2. unit tests
[./gradlew integrationTest]        # 3. integration tests
[./gradlew build]                  # 4. full build

# Frontend (if modified)
[pnpm --filter web test]           # 5. frontend tests
[pnpm --filter web build]          # 6. frontend build
```
If any step fails, fix it and re-run from step 1.
All steps must pass before creating a PR.
