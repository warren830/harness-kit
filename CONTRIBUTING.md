# Contributing to harness-kit

## How to Contribute

### Templates

The most valuable contribution is **real-world examples** -- AGENTS.md files from actual projects (sanitized of secrets/proprietary info).

To add a template:
1. Place it in the appropriate `templates/` subdirectory
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

Guides are in `guides/`. Follow existing structure: problem statement, solution, examples, anti-patterns.

### Platform Support

To add a new platform (e.g., Cursor):
1. Add templates in `templates/<platform>/`
2. Add adapter in `templates/<platform>/`
3. Add guide in `guides/<platform>-harness.md`
4. Update `harness-kit init` to support the new platform

## Guidelines

- Every template rule must trace back to research or observed failure (no generic advice)
- Keep AGENTS.md templates under 100 lines
- Test CLI changes: `harness-kit init /tmp/test --tools both --type web-app --level 2 --skip-existing`
- Don't modify files under `research/` -- they are read-only reference

## Research

The `research/` directory contains our original research. It's read-only reference material -- don't modify it, but do cite it when adding new templates or guides.
