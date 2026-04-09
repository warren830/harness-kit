# Requirements: harness-kit v0.2 Framework Upgrade

## Problem Statement

harness-kit v0.1 ships 60+ templates, 10 guides, and research materials, but they are organized by tool (claude-code/kiro/universal) rather than by function. Meanwhile, the harness engineering field has matured dramatically in Q1 2026: Martin Fowler published a formal framework, GitHub analyzed 2500 repos, Datadog/Harvey/Escape.tech shared production data. harness-kit's structure and content need to catch up with the industry.

## Chosen Approach

**Dual-Layer Restructure (Approach C)** — Split the repo into two layers:

1. **`concepts/`** — Theory and methodology guides (Fowler framework, autonomy grading, verification pyramid, context limits). For understanding "why" and "what".
2. **`harness/`** — Copy-paste-ready configuration templates organized by tool. For "how" and "do it now".

`concepts/` teaches. `harness/` ships. They cross-reference each other but each works standalone.

**Rationale:** Serves all user levels — beginners go straight to `harness/`, advanced users study `concepts/` first. Cleaner than mixing theory into template files.

## Scope

### In Scope

- New top-level structure: `concepts/` + `harness/` (replacing current `templates/` + `guides/`)
- 4 new concept guides:
  1. Fowler's Guides/Sensors dual-control framework (from research-05)
  2. Autonomy grading: what tasks are fully autonomous vs. human-required (from research-07, Escape.tech)
  3. Verification pyramid: linter → tests → formal verification (from research-07, Datadog)
  4. Context budget: 40% utilization ceiling, dumb zone warning, sub-agent as context firewall (from research-06)
- Reclassify all 60 existing templates into new `harness/` structure
- Update AGENTS.md templates based on GitHub 2500-repo findings:
  - Commands first (most referenced by agents)
  - Three-tier permission boundary: Always / Ask First / Never
  - No architecture overviews (agents discover these themselves)
  - Length guidance: start < 150 lines (GitHub), aspirational < 60 lines (HumanLayer)
  - Code examples >> text descriptions
  - Warning: LLM-generated AGENTS.md reduces performance 0.5-2%, increases cost 20-23%
- Layered user journey: Starter → Standard → Advanced paths through the material
- Updated README reflecting new structure and framework alignment
- Migration guide for v0.1 users

### Out of Scope

- CLI tools rewrite (`tools/` stays as-is)
- New tool-specific templates (no Cursor/Copilot/Windsurf)
- Fullstack Scenario Pack (deferred — separate initiative)
- Evaluator-Optimizer automation loop (too complex, v0.3)
- Persistent Memory pattern implementation (research noted it, but not actionable as template yet)
- Harnessability assessment tool (interesting concept from Fowler, but premature)

## Requirements

### Structure

1. Top-level directories: `concepts/`, `harness/`, `tools/`, `research/` (research stays read-only)
2. `concepts/` contains methodology guides with clear "Source" attribution to research files
3. `harness/` organized by tool: `harness/universal/`, `harness/claude-code/`, `harness/kiro/`, `harness/combo/`
4. Every concept guide links to relevant harness templates ("Now go apply this → ...")
5. Every harness template optionally links back to its concept ("Why this works → ...")

### Concept Guides

6. Fowler dual-control guide: explain Guides (feedforward) vs Sensors (feedback), Computational vs Reasoning, with a classification table mapping all harness-kit templates to the 4 quadrants
7. Autonomy grading guide: 4-level model (fully autonomous / light review / full review / human-led) with concrete task examples and a template users can customize
8. Verification pyramid guide: layered verification from linter to tests to formal methods, with practical recommendations per project type
9. Context budget guide: 40% ceiling rule, dumb zone symptoms, sub-agent firewall pattern, practical tips for keeping context lean

### Template Updates

10. AGENTS.md templates (standard, minimal, monorepo) updated per GitHub 2500-repo data:
    - Commands section moved to top
    - Three-tier permission boundary (Always / Ask First / Never) added
    - Architecture overview sections removed
    - Length reduced toward 60-150 line range
    - More code examples, fewer prose descriptions
11. All templates retain "When to use / When NOT to use" sections (proven pattern, keep it)
12. Templates that reference Fowler categories tag themselves: `[Guide: Reasoning]` or `[Sensor: Computational]`

### User Journey

13. README provides three entry paths: "Quick Start (5 min)" → "Standard Setup (30 min)" → "Advanced Harness (deep dive)"
14. Quick Start: minimal AGENTS.md + 1 hook → working harness in 5 minutes
15. Standard Setup: full AGENTS.md + hooks + rules + verification layer
16. Advanced: all of Standard + autonomy grading + verification pyramid + context budgeting

## Success Criteria

- Every existing template has a home in the new structure (nothing lost)
- A new user can go from zero to working harness in < 10 minutes following Quick Start
- The Fowler framework classification table covers all templates (no orphans)
- All 4 concept guides cite specific research files as sources (no unsourced claims)
- README clearly communicates the dual-layer mental model in the first 20 lines

## Assumptions

- Fowler's framework is stable and won't change significantly (published March 2026, by Martin Fowler — likely stable)
- The 40% context utilization ceiling applies broadly, not just to specific models
- GitHub's 2500-repo findings for AGENTS.md generalize to CLAUDE.md and other agent config files
- Users of harness-kit are comfortable with git clone / copy-paste workflow

## Open Questions

### Blocking (resolve before design)

~~1. **`guides/` directory name collision** — RESOLVED: Theory layer is `concepts/`. Old `guides/` content migrates into `concepts/`.~~
~~2. **`environments/` templates** — RESOLVED: Goes under `harness/environments/` (copy-paste-ready = harness layer).~~

### Deferrable (resolve during implementation)

3. Chinese translations — Do we maintain parallel `-zh.md` files in the new structure, or defer to v0.3?
4. CI templates — Current `ci/` directory: fold into `harness/ci/` or keep separate?
5. Exact Fowler quadrant classification for each of the 60 templates — can be done during implementation

## Research Context

All requirements trace to these research files in `research/`:

| Research File | Key Findings Used |
|---|---|
| research-05-fowler-harness-framework.md | Guides/Sensors taxonomy, Harnessability concept |
| research-06-2026-agents-md-context.md | GitHub 2500-repo AGENTS.md findings, 40% context ceiling, 60-line recommendation, dumb zone, sub-agent firewall |
| research-07-2026-production-cases.md | Datadog verification pyramid, Harvey evaluator-optimizer results, Escape.tech autonomy grading, Alex Lavaee 4-pillar framework |
| research-01 through 04 | Original harness-kit methodology (error-driven writing, deterministic > probabilistic, knowledge base patterns) |
