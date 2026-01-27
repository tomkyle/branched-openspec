# Repository Guidelines

## Project Structure & Module Organization
- `src/` contains the source YAML files (single source of truth for prompts).
- `prompts/` holds generated Codex/OpenCode prompt markdown files.
- `commands/` contains generated Gemini extension TOML files.
- `scripts/build.js` is the Node.js build script that generates distribution files from source.
- `Makefile` provides build and install/uninstall helpers for Codex, OpenCode, and Gemini CLIs.
- `gemini-extension.json` is the Gemini extension manifest.
- `package.json` manages Node.js dependencies and npm scripts.
- `.mdlrc` and `mdl_style.rb` configure the markdown linter for CI validation.

## Build, Test, and Development Commands
- `pnpm install` or `npm install` installs Node.js dependencies (js-yaml, chokidar-cli, etc.).
- `npm run build` or `make build` or `./scripts/build.js` generates prompts/*.md and commands/*.toml from src/*.yaml.
- `npm run watch` runs in watch mode, automatically rebuilding when src/*.yaml files change.
- `make help` shows available Makefile targets with descriptions.
- `make codex` symlinks prompt files into `~/.codex/prompts` (requires `codex` CLI).
- `make opencode` symlinks prompt files into `~/.config/opencode/commands/` (requires `opencode` CLI).
- `make gemini` installs the Gemini extension (requires `gemini` CLI).
- `make install` runs both codex and gemini installers.
- `make uninstall` removes Codex/OpenCode symlinks and uninstalls the Gemini extension.
- `act -W .github/workflows/ci.yml` runs the CI workflow locally (requires `act` and Docker).

## Coding Style & Naming Conventions
- Edit source files in `src/*.yaml` only; never edit generated files in `prompts/` or `commands/` directly.
- Use YAML formatting in `src/`, Markdown in generated `prompts/`, and TOML in generated `commands/`.
- Keep filenames descriptive and aligned with the prompt name (`branched-openspec`).
- Prefer concise, imperative wording in prompt instructions.
- Follow JSDoc conventions in `scripts/build.js` for function documentation.

## Testing Guidelines
- CI workflow validates TOML and Markdown files using `python3-tomli` and `markdownlint` (mdl).
- Markdown linting rules are configured in `mdl_style.rb` to handle YAML frontmatter and long lines.
- Run `npm run build` before committing to ensure generated files are up-to-date.
- Validate changes by running `make build` and `make install` to ensure CLIs accept the generated files.

## Commit & Pull Request Guidelines
- Commit history follows Conventional Commits format (`feat:`, `fix:`, `chore:`, `docs:`, etc.).
- When editing OpenSpec workflow instructions in `src/branched-openspec.yaml`, rebuild after changes.
- Keep the "OpenSpec phase: <phase>" footer pattern in commit message examples.
- PRs should include a brief summary of changes and mention if rebuild is required.
- Generated files (`prompts/*.md`, `commands/*.toml`) should be committed after building from source changes.

## Agent-Specific Notes
- The source YAML in `src/` is the single source of truth; all prompts are generated from it.
- The build script (`scripts/build.js`) handles validation, generation, and error reporting.
- Generated files must stay in sync—always run build after editing source files.
- If you add new source YAML files, the build script will automatically process them.
- If you modify the build script, update this guide and test with `npm run build`.
- The build script validates field types and required fields before generation.
