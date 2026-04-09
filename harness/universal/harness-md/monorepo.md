---
name: "HARNESS.md Monorepo"
description: Root-level HARNESS.md for monorepos, plus a package-level template. ~100 lines.
when_to_use: Monorepos (Nx, Turborepo, Lerna, pnpm workspaces) with 3+ packages.
when_not_to_use: Single-package repos (use standard.md).
---

<!-- STRATEGY:
     - Root HARNESS.md = project map + global rules (~60-80 lines)
     - Each package gets its own HARNESS.md (~20-40 lines)
     - Agent reads root first, then the relevant package's file
     OpenAI uses 88 HARNESS.md files across subsystems.
     Replace [brackets], delete comments when done. -->

# HARNESS.md (Root)

[Project name]: monorepo with [N] packages for [purpose].

## Commands

<!-- Global commands go here. Package-specific commands go in package HARNESS.md files. -->

```bash
[pnpm install]                     # install all — run from root
[pnpm build]                       # build all packages
[pnpm test]                        # test all packages
[pnpm lint]                        # lint all packages
[pnpm --filter <pkg> build]        # build one package
[pnpm --filter <pkg> test]         # test one package
[pnpm --filter <pkg> dev]          # dev server for one package
```

## Boundaries

Always:
- Read the target package's HARNESS.md before working in that package
- Run only that package's tests, not the full monorepo suite
- If you modify [shared/], also test all dependent packages

Ask first:
- Adding cross-package dependencies
- Modifying the root package.json or workspace config
- Changing [shared/] types that affect multiple consumers

Never:
- Import directly between [web/] and [api/] — use [shared/] types
- Add application dependencies to root package.json (tooling only)
- Run `pnpm install` from inside a package directory

## Package Map

```
[packages/
  web/              — Next.js frontend        → packages/web/HARNESS.md
  api/              — Express API server       → packages/api/HARNESS.md
  shared/           — Shared types & utils     → packages/shared/HARNESS.md
  mobile/           — React Native app         → packages/mobile/HARNESS.md
  infra/            — Terraform infrastructure → packages/infra/HARNESS.md]
```

## Dependency Graph

```
[web ──→ shared
 api ──→ shared
 mobile ──→ shared
 infra ──→ (standalone, no internal deps)]
```

Cross-package rules:
- [shared/] is the ONLY package importable by others
- All shared types must be exported from [shared/src/index.ts]
- Version bumps in [shared/] require rebuilding all consumers

## Pitfalls

<!-- Global monorepo pitfalls only. Package-specific ones go in package HARNESS.md.

     Example entries (replace with real observations):
     - Use `pnpm --filter web dev`, NOT `cd packages/web && pnpm dev`
     - The root tsconfig.json is for editor support only — each package has its own
     - Shared package must be built before consumers: `pnpm --filter shared build` -->

## Verification

After modifying code in package `<pkg>`:
```bash
[pnpm --filter <pkg> lint]         # 1. lint the package
[pnpm --filter <pkg> test]         # 2. test the package
[pnpm --filter <pkg> build]        # 3. build the package
```
If you modified [shared/], also run:
```bash
[pnpm --filter "...^shared" test]  # test all packages that depend on shared
```

---

# Package-Level HARNESS.md Template

<!-- Copy this to each package directory as packages/<pkg>/HARNESS.md -->

## [Package Name]

[One sentence: what this package does.]

## Commands

```bash
[pnpm --filter <pkg> dev]          # dev server
[pnpm --filter <pkg> test]         # run tests
[pnpm --filter <pkg> build]        # build
[pnpm --filter <pkg> lint]         # lint
```

## Boundaries

Always: [run tests before committing changes to this package]
Ask first: [changing this package's public API used by other packages]
Never: [importing from sibling packages other than shared/]

## Conventions

- [Entry point: src/index.ts]
- [Components: src/components/[Name]/index.tsx]
- [Tests: colocated in __tests__/ directories]

## Pitfalls

<!-- Package-specific observed failures only. -->
