# Repository Guidelines

## Project Structure & Module Organization
- `prompts/` holds the Codex prompt markdown (`prompts/branched-openspec.md`).
- `commands/` contains the Gemini extension definition (`commands/branched-openspec.toml`).
- `Makefile` provides install/uninstall helpers for Codex and Gemini CLIs.
- `gemini-extension.json` is the Gemini extension manifest.

## Build, Test, and Development Commands
- `make help` shows available targets and a short description.
- `make codex` symlinks prompt files into `~/.codex/prompts` (requires `codex` CLI).
- `make gemini` installs the Gemini extension (requires `gemini` CLI).
- `make install` runs both installers.
- `make uninstall` removes the Codex symlinks and uninstalls the Gemini extension.
- `act -W .github/workflows/ci.yml` runs the CI workflow locally (requires `act` and Docker).

## Coding Style & Naming Conventions
- Use standard Markdown formatting in `prompts/` and TOML formatting in `commands/`.
- Keep filenames descriptive and aligned with the prompt name (`branched-openspec`).
- Prefer concise, imperative wording in prompt instructions.

## Testing Guidelines
- No automated test suite is defined in this repo.
- Validate changes by running `make help` and, when available, `make install` to ensure the CLIs accept the prompt/extension.

## Commit & Pull Request Guidelines
- Commit history references Conventional Commits; follow that format (`feat:`, `fix:`, `chore:`).
- When editing OpenSpec workflow instructions, keep the “OpenSpec phase: <phase>” footer pattern shown in `commands/branched-openspec.toml`.
- PRs should include a brief summary of prompt/extension changes and mention any required CLI setup.

## Agent-Specific Notes
- The Codex prompt is the primary artifact; keep changes to `prompts/branched-openspec.md` and `commands/branched-openspec.toml` in sync where behavior overlaps.
- If you add new commands or files, update this guide and the `Makefile` if installation paths change.
