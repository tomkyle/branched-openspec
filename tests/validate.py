#!/usr/bin/env python3
"""Repository validation helpers for CI."""
import argparse
import glob
import os
import shutil
import subprocess
import sys


def load_tomllib():
    """Return a TOML parser module, exiting with guidance if unavailable."""
    try:
        import tomllib  # Python 3.11+
        return tomllib
    except ModuleNotFoundError:
        try:
            import tomli as tomllib
            return tomllib
        except ModuleNotFoundError:
            print("Missing tomllib/tomli. Install python3-tomli via apt-get.", file=sys.stderr)
            sys.exit(1)


def validate_toml():
    """Validate TOML files under commands/ for basic parseability."""
    toml_files = glob.glob("commands/*.toml")
    if not toml_files:
        print("No commands/*.toml files found", file=sys.stderr)
        sys.exit(1)

    tomllib = load_tomllib()
    for path in toml_files:
        with open(path, "rb") as handle:
            tomllib.load(handle)

    print(f"Validated {len(toml_files)} TOML files")


def validate_markdown():
    """Validate Markdown files under prompts/ for presence, content, and lint."""
    md_files = glob.glob("prompts/*.md")
    if not md_files:
        print("No prompts/*.md files found", file=sys.stderr)
        sys.exit(1)

    lint_targets = md_files

    for path in lint_targets:
        if os.path.getsize(path) == 0:
            print(f"Empty markdown file: {path}", file=sys.stderr)
            sys.exit(1)

    if not shutil.which("mdl"):
        print("Missing mdl. Install markdownlint via apt-get.", file=sys.stderr)
        sys.exit(1)

    subprocess.run(["mdl", *lint_targets], check=True)
    print(f"Validated {len(lint_targets)} Markdown files")


def main():
    """Parse CLI arguments and dispatch the requested validation checks."""
    parser = argparse.ArgumentParser(description="Validate repository inputs")
    parser.add_argument(
        "kind",
        choices=["toml", "markdown", "all"],
        nargs="?",
        default="all",
        help="Validation target",
    )
    args = parser.parse_args()

    if args.kind in ("toml", "all"):
        validate_toml()
    if args.kind in ("markdown", "all"):
        validate_markdown()


if __name__ == "__main__":
    main()
