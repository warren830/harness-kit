# Contributing to harness-kit

## How to Contribute

### Templates

The most valuable contribution is **real-world examples** -- HARNESS.md files from actual projects (sanitized of secrets/proprietary info).

To add a template:
1. Place it in the appropriate `harness/` subdirectory (e.g., `harness/claude-code/skills/`)
2. Add YAML frontmatter with `name`, `description`, `when_to_use`, `when_not_to_use`
3. Every rule in the template must have a concrete example

### CLI Tools

Tools are in `src/harness_kit/`. Python 3.11+, formatted with ruff, type-checked with mypy.

```bash
# Setup
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"

# Run
harness-kit --help

# Lint + type check
ruff check src/
mypy src/
```

### Guides

Guides are in `concepts/`. Follow existing structure: problem statement, solution, examples, anti-patterns. All claims must cite `research/` sources.

### Platform Support

Currently supporting Claude Code and Kiro. To improve an existing platform:
1. Templates in `harness/claude-code/` or `harness/kiro/`
2. Platform guide in `concepts/claude-code-guide.md` or `concepts/kiro-guide.md`
3. Update `harness-kit init` if adding new template types

## Guidelines

- Every template rule must trace back to research or observed failure (no generic advice)
- Keep HARNESS.md templates within tier limits: starter ~30, standard ~80, advanced ~150 lines
- Test CLI changes: `harness-kit init /tmp/test --tools both --type web-app --level 2 --skip-existing`
- Don't modify files under `research/` -- they are read-only reference

## Research

The `research/` directory contains our original research. It's read-only reference material -- don't modify it, but do cite it when adding new templates or guides.
