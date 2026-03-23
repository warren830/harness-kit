"""harness-kit score: Assess harness maturity of a project."""

import json
from pathlib import Path

from rich.console import Console
from rich.table import Table
from rich.panel import Panel

console = Console()

# 8-level maturity model
CHECKS: list[dict[str, object]] = [
    # Level 1: Rules
    {
        "level": 1,
        "name": "Rules",
        "checks": [
            ("AGENTS.md or equivalent", lambda p: _has_any(p, ["AGENTS.md", "CLAUDE.md", ".cursorrules"])),
            ("Project-specific content (not empty template)", lambda p: _file_over_lines(p / "AGENTS.md", 5) or _file_over_lines(p / "CLAUDE.md", 5)),
        ],
    },
    # Level 2: Constraints
    {
        "level": 2,
        "name": "Constraints",
        "checks": [
            ("Linter configured", lambda p: _has_any(p, [".eslintrc.js", ".eslintrc.json", ".eslintrc.yml", "eslint.config.js", "eslint.config.mjs", "ruff.toml", "pyproject.toml"])),
            ("Type checking configured", lambda p: _has_any(p, ["tsconfig.json", "mypy.ini", "pyproject.toml", "pyrightconfig.json"])),
            ("Pre-commit hooks", lambda p: _has_any(p, [".pre-commit-config.yaml", ".husky"])),
        ],
    },
    # Level 3: Verification
    {
        "level": 3,
        "name": "Verification",
        "checks": [
            ("Test suite exists", lambda p: _has_any_dir(p, ["__tests__", "tests", "test", "spec"])),
            ("Test command documented", lambda p: _file_contains(p / "AGENTS.md", "test") or _file_contains(p / "CLAUDE.md", "test")),
        ],
    },
    # Level 4: Feedback loops
    {
        "level": 4,
        "name": "Feedback",
        "checks": [
            ("Architecture doc exists", lambda p: _has_any(p, ["docs/ARCHITECTURE.md", "ARCHITECTURE.md"])),
            ("Error-driven rules (Agent Pitfalls section)", lambda p: _file_contains(p / "AGENTS.md", "Pitfall") or _file_contains(p / "AGENTS.md", "pitfall") or _file_contains(p / "AGENTS.md", "Do NOT")),
        ],
    },
    # Level 5: Context management
    {
        "level": 5,
        "name": "Context",
        "checks": [
            ("Claude Code Skills", lambda p: (p / ".claude" / "skills").is_dir()),
            ("Kiro Steering files", lambda p: (p / ".kiro" / "steering").is_dir()),
            ("Path-specific rules", lambda p: (p / ".claude" / "rules").is_dir() or _has_any(p, [".github/instructions"])),
        ],
    },
    # Level 6: Isolation
    {
        "level": 6,
        "name": "Isolation",
        "checks": [
            ("Docker/devbox config", lambda p: _has_any(p, ["docker-compose.yml", "docker-compose.yaml", "Dockerfile", "devbox.json"])),
            ("Worktree/isolation scripts", lambda p: _has_any(p, [".claude/hooks", ".kiro/hooks"])),
        ],
    },
    # Level 7: Autonomous
    {
        "level": 7,
        "name": "Autonomous",
        "checks": [
            ("Entropy management docs", lambda p: _file_contains(p / "AGENTS.md", "entropy") or _has_any(p, ["docs/QUALITY.md"])),
            ("CI harness checks", lambda p: _has_any(p, [".github/workflows"])),
            ("Kiro Specs", lambda p: (p / ".kiro" / "specs").is_dir()),
        ],
    },
]

GRADE_THRESHOLDS = [
    (71, "S", "bold magenta", "Full autonomous — OpenAI/Stripe level"),
    (61, "A", "bold green", "Isolation + entropy management"),
    (46, "B", "green", "Complete feedback loops + context management"),
    (31, "C", "yellow", "Constraints and verification, feedback incomplete"),
    (16, "D", "red", "Basic rules, lacks enforcement"),
    (0, "F", "bold red", "No harness — agent running blind"),
]


def run_score(target: str, output_format: str) -> None:
    """Run the score command."""
    target_path = Path(target).resolve()

    results: list[dict[str, object]] = []
    total_score = 0
    max_score = 0

    for level_def in CHECKS:
        level_results: list[tuple[str, bool]] = []
        for check_name, check_fn in level_def["checks"]:  # type: ignore[union-attr]
            passed = check_fn(target_path)  # type: ignore[operator]
            level_results.append((check_name, passed))

        passed_count = sum(1 for _, p in level_results if p)
        total_checks = len(level_results)
        level_score = round((passed_count / total_checks) * 10) if total_checks > 0 else 0
        total_score += level_score
        max_score += 10

        results.append({
            "level": level_def["level"],
            "name": level_def["name"],
            "checks": level_results,
            "score": level_score,
        })

    if output_format == "json":
        console.print(json.dumps({"score": total_score, "max": max_score, "levels": results}, indent=2, default=str))
        return

    # Rich table output
    console.print(Panel.fit(f"[bold]Harness Maturity Score[/bold]\nProject: {target_path}", border_style="blue"))

    table = Table(show_header=True)
    table.add_column("Level", style="bold", width=8)
    table.add_column("Name", width=14)
    table.add_column("Checks", width=50)
    table.add_column("Score", justify="right", width=8)

    for r in results:
        checks_str = ""
        for check_name, passed in r["checks"]:  # type: ignore[union-attr]
            icon = "[green]PASS[/green]" if passed else "[red]FAIL[/red]"
            checks_str += f"{icon} {check_name}\n"
        table.add_row(
            str(r["level"]),
            str(r["name"]),
            checks_str.strip(),
            f"{r['score']}/10",
        )

    console.print(table)

    # Grade
    grade_name, grade_letter, grade_style, grade_desc = "F", "F", "bold red", ""
    for threshold, letter, style, desc in GRADE_THRESHOLDS:
        if total_score >= threshold:
            grade_name, grade_letter, grade_style, grade_desc = letter, letter, style, desc
            break

    console.print()
    console.print(f"[bold]Total: {total_score}/{max_score}[/bold]  Grade: [{grade_style}]{grade_letter}[/{grade_style}]  ({grade_desc})")

    # Recommendations
    console.print()
    console.print("[bold]Recommendations:[/bold]")
    for r in results:
        for check_name, passed in r["checks"]:  # type: ignore[union-attr]
            if not passed:
                console.print(f"  [yellow]>[/yellow] Add: {check_name} (Level {r['level']})")


# --- Helper functions -----------------------------------------------------------


def _has_any(project: Path, files: list[str]) -> bool:
    """Check if any of the listed files/dirs exist."""
    return any((project / f).exists() for f in files)


def _has_any_dir(project: Path, dirs: list[str]) -> bool:
    """Check if any of the listed directories exist (also search one level deep)."""
    for d in dirs:
        if (project / d).is_dir():
            return True
        # Check one level deep (e.g., src/tests)
        for child in project.iterdir():
            if child.is_dir() and (child / d).is_dir():
                return True
    return False


def _file_over_lines(path: Path, min_lines: int) -> bool:
    """Check if a file exists and has more than min_lines lines."""
    if not path.exists():
        return False
    return len(path.read_text().splitlines()) > min_lines


def _file_contains(path: Path, keyword: str) -> bool:
    """Check if a file exists and contains a keyword."""
    if not path.exists():
        return False
    return keyword.lower() in path.read_text().lower()
