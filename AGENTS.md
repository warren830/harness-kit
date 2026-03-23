# AGENTS.md — harness-kit

> This file is the universal entry point for any AI coding agent working on this project.
> Both Kiro (auto-detected) and Claude Code (via @AGENTS.md in CLAUDE.md) read this file.

## Project Overview

harness-kit is an open-source toolkit for Harness Engineering — helping teams build constraints, feedback loops, and control systems around AI coding agents. It provides reusable templates, tools, and guides for Claude Code and Kiro.

## Tech Stack

- Documentation: Markdown (all templates)
- Tools: Python 3.11+ (CLI tools, use `ruff` for linting, `mypy` for type checking)
- Template metadata: YAML frontmatter in Markdown files
- CI: GitHub Actions
- License: MIT

## Repository Structure

```
templates/
  universal/     — Cross-platform templates (AGENTS.md, knowledge-base, constraints, entropy)
  claude-code/   — Claude Code specific (hooks, skills, rules)
  kiro/          — Kiro specific (steering, specs, hooks)
  combo/         — Claude Code + Kiro dual-tool collaboration
  environments/  — Isolation scripts (worktree, docker)
tools/           — CLI tools (harness-init, harness-score, entropy-scanner)
guides/          — How-to guides and methodology docs
ci/              — CI/CD templates (GitHub Actions)
research/        — Research materials (read-only reference)
```

## Commands

- Run Python tools: `python tools/<tool-name>/<script>.py`
- Lint Python: `ruff check tools/`
- Type check Python: `mypy tools/`
- Lint Markdown: `npx markdownlint 'templates/**/*.md' 'guides/**/*.md'`

## Writing Conventions

- Every template file MUST include a "When to use" and "When NOT to use" section
- Every rule/constraint in a template MUST have a concrete example, not abstract advice
- AGENTS.md templates should be ~100 lines max (OpenAI principle: "table of contents, not encyclopedia")
- Keep English for code/technical terms, provide Chinese translations in separate `-zh.md` files
- Template files use `.md` extension with optional YAML frontmatter for metadata

## Known Agent Pitfalls (Error-Driven)

- Do NOT auto-generate AGENTS.md content with LLMs — ETH Zurich research shows this hurts performance by 20%+
- Do NOT write speculative rules ("the agent might do X") — only write rules based on observed failures
- Do NOT put research/ files content into templates — research is reference material, not template content
- The `research/` directory is read-only reference; do not modify those files when working on templates
- When creating example AGENTS.md files, always base them on real project scenarios, not hypothetical ones

## Verification

After modifying any template or guide:
1. Ensure Markdown renders correctly (no broken links, tables, code blocks)
2. If modifying Python tools: `ruff check tools/ && mypy tools/`
3. All templates must be self-contained — a user should understand them without reading other files
