"""harness-kit scan: Detect entropy in harness files."""

from pathlib import Path

from rich.console import Console
from rich.panel import Panel

console = Console()


def run_scan(target: str) -> None:
    """Run the entropy scan command."""
    target_path = Path(target).resolve()

    console.print(
        Panel.fit(
            f"[bold]Entropy Scanner[/bold]\nTarget: {target_path}",
            border_style="blue",
        )
    )

    issues: list[tuple[str, str, str]] = []  # (severity, file, description)

    # Check 1: Rule file size (>200 lines = noise risk)
    for rule_file in ["HARNESS.md", "CLAUDE.md"]:
        path = target_path / rule_file
        if path.exists():
            lines = len(path.read_text().splitlines())
            if lines > 200:
                issues.append((
                    "WARN",
                    rule_file,
                    f"{lines} lines — exceeds 200-line recommended max. Important rules may get lost in noise.",
                ))

    # Check 2: Placeholder content still present
    for rule_file in ["HARNESS.md", "CLAUDE.md"]:
        path = target_path / rule_file
        if path.exists():
            content = path.read_text()
            placeholders = ["[framework]", "[React/Vue", "[Node.js/Python", "[Python/Rust", "[Express/FastAPI", "your-project", "[tech stack]", "[one sentence"]
            found = [p for p in placeholders if p.lower() in content.lower()]
            if found:
                issues.append((
                    "WARN",
                    rule_file,
                    f"Contains unfilled placeholders: {', '.join(found[:3])}. Replace with project-specific content.",
                ))

    # Check 3: Kiro steering files exist but are minimal
    kiro_dir = target_path / ".kiro" / "steering"
    if kiro_dir.is_dir():
        for steering_file in kiro_dir.glob("*.md"):
            lines = len(steering_file.read_text().splitlines())
            if lines < 5:
                issues.append((
                    "INFO",
                    f".kiro/steering/{steering_file.name}",
                    "Nearly empty steering file. Consider adding project-specific guidance.",
                ))

    # Check 4: Hooks exist but are not executable
    hooks_dir = target_path / ".claude" / "hooks"
    if hooks_dir.is_dir():
        for hook_file in hooks_dir.glob("*.sh"):
            import os
            if not os.access(hook_file, os.X_OK):
                issues.append((
                    "ERROR",
                    f".claude/hooks/{hook_file.name}",
                    "Hook script is not executable. Run: chmod +x " + str(hook_file),
                ))

    # Check 5: HARNESS.md references commands that don't exist in package.json/pyproject.toml
    agents_path = target_path / "HARNESS.md"
    if agents_path.exists():
        content = agents_path.read_text()
        pkg_json = target_path / "package.json"
        if pkg_json.exists():
            pkg_content = pkg_json.read_text()
            if "npm test" in content and '"test"' not in pkg_content:
                issues.append((
                    "ERROR",
                    "HARNESS.md",
                    'References "npm test" but no "test" script found in package.json.',
                ))
            if "npm run lint" in content and '"lint"' not in pkg_content:
                issues.append((
                    "ERROR",
                    "HARNESS.md",
                    'References "npm run lint" but no "lint" script found in package.json.',
                ))

    # Output
    if not issues:
        console.print("[bold green]No entropy issues found.[/bold green]")
        return

    error_count = sum(1 for s, _, _ in issues if s == "ERROR")
    warn_count = sum(1 for s, _, _ in issues if s == "WARN")
    info_count = sum(1 for s, _, _ in issues if s == "INFO")

    for severity, file, desc in issues:
        style = {"ERROR": "red", "WARN": "yellow", "INFO": "blue"}[severity]
        console.print(f"  [{style}]{severity}[/{style}] [{style}]{file}[/{style}]: {desc}")

    console.print()
    console.print(
        f"Found: [red]{error_count} errors[/red], "
        f"[yellow]{warn_count} warnings[/yellow], "
        f"[blue]{info_count} info[/blue]"
    )
