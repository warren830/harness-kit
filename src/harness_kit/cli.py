"""Main CLI entry point for harness-kit."""

import click

from harness_kit import __version__


@click.group()
@click.version_option(version=__version__, prog_name="harness-kit")
def main() -> None:
    """harness-kit: Build constraints, feedback loops, and control systems around AI coding agents."""


@main.command()
@click.argument("target", default=".", type=click.Path(exists=True, file_okay=False))
@click.option(
    "--tools",
    type=click.Choice(["claude-code", "kiro", "both"], case_sensitive=False),
    default=None,
    help="Target AI tools (default: interactive prompt)",
)
@click.option(
    "--type",
    "project_type",
    type=click.Choice(["web-app", "api-service", "cli-tool", "data-pipeline", "ml-project"]),
    default=None,
    help="Project type (default: interactive prompt)",
)
@click.option(
    "--level",
    type=click.IntRange(1, 3),
    default=None,
    help="Harness level: 1=rules only, 2=+constraints+verification, 3=full harness",
)
@click.option(
    "--skip-existing",
    is_flag=True,
    default=False,
    help="Skip files that already exist (no prompts)",
)
def init(target: str, tools: str | None, project_type: str | None, level: int | None, skip_existing: bool) -> None:
    """Initialize a harness in your project.

    TARGET is the project directory (default: current directory).

    \b
    Examples:
        harness-kit init                     # Interactive mode in current dir
        harness-kit init ~/my-project        # Interactive mode in target dir
        harness-kit init --tools both --level 2   # Non-interactive
        harness-kit init --tools both --skip-existing  # Skip existing files
    """
    from harness_kit.commands.init import run_init

    run_init(target=target, tools=tools, project_type=project_type, level=level, skip_existing=skip_existing)


@main.command()
@click.argument("target", default=".", type=click.Path(exists=True, file_okay=False))
@click.option("--format", "output_format", type=click.Choice(["text", "json"]), default="text")
def score(target: str, output_format: str) -> None:
    """Assess your project's harness maturity.

    Scans TARGET directory and scores it on the 8-level Harness Maturity Model.

    \b
    Examples:
        harness-kit score                    # Score current directory
        harness-kit score ~/my-project       # Score specific project
        harness-kit score --format json      # Machine-readable output
    """
    from harness_kit.commands.score import run_score

    run_score(target=target, output_format=output_format)


@main.command()
@click.argument("target", default=".", type=click.Path(exists=True, file_okay=False))
def scan(target: str) -> None:
    """Scan for entropy: documentation drift, rule conflicts, dead rules.

    \b
    Examples:
        harness-kit scan                     # Scan current directory
        harness-kit scan ~/my-project        # Scan specific project
    """
    from harness_kit.commands.scan import run_scan

    run_scan(target=target)


if __name__ == "__main__":
    main()
