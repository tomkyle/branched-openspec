#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// ANSI color codes
const colors = {
  blue: '\x1b[0;34m',
  green: '\x1b[0;32m',
  yellow: '\x1b[0;33m',
  reset: '\x1b[0m'
};

/**
 * Ensures a directory exists, creating it if necessary.
 * Uses recursive creation to handle nested paths.
 * Logs directory creation with colorized output.
 *
 * @param {string} dir - Directory path to ensure exists
 */
const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) {
    console.log(`${colors.blue}Creating directory: ${dir}${colors.reset}`);
    fs.mkdirSync(dir, { recursive: true });
  }
};

/**
 * Generates a Markdown file with YAML frontmatter for Codex/OpenCode.
 *
 * Structure:
 * - YAML frontmatter block with description and argument-hint
 * - Main prompt content
 * - $ARGUMENTS placeholder for user input
 *
 * @param {Object} data - Parsed YAML source data
 * @param {string} data.description - Prompt description
 * @param {string} data['argument-hint'] or data.argumentHint - Hint for arguments
 * @param {string} data.prompt - Main prompt content
 * @returns {string} Complete markdown file content
 * @throws {Error} If required fields are missing or invalid types
 */
const generateMarkdown = (data) => {
  // Validate required fields
  if (!data.description) {
    throw new Error('description field is required');
  }
  if (!data.prompt) {
    throw new Error('prompt field is required');
  }

  if (!data.argumentHint) {
    throw new Error('argumentHint field is required');
  }

  // Validate field types
  if (typeof data.description !== 'string') {
    throw new Error('description must be a string');
  }
  if (typeof data.prompt !== 'string') {
    throw new Error('prompt must be a string');
  }
  if (typeof data.argumentHint !== 'string') {
    throw new Error('argumentHint must be a string');
  }

  // Trim prompt to avoid extra blank lines that cause MD012 linting errors
  const prompt = data.prompt.trim();
  // Handle both kebab-case and camelCase field names
  const argumentHint = data.argumentHint;

  return `---
description: ${data.description}
argument-hint: ${argumentHint}
---

${prompt}

$ARGUMENTS
`;
};

/**
 * Generates a TOML configuration file for Gemini CLI.
 *
 * Structure:
 * - description field (JSON-encoded for safety)
 * - prompt field as TOML multiline string with {{args}} placeholder
 *
 * The {{args}} placeholder gets replaced by Gemini CLI with user input.
 *
 * @param {Object} data - Parsed YAML source data
 * @param {string} data.description - Prompt description
 * @param {string} data.prompt - Main prompt content
 * @returns {string} Complete TOML file content
 * @throws {Error} If required fields are missing or invalid types
 */
const generateTOML = (data) => {
  // Validate required fields
  if (!data.description) {
    throw new Error('description field is required');
  }
  if (!data.prompt) {
    throw new Error('prompt field is required');
  }

  // Validate field types
  if (typeof data.description !== 'string') {
    throw new Error('description must be a string');
  }
  if (typeof data.prompt !== 'string') {
    throw new Error('prompt must be a string');
  }

  return `description = ${JSON.stringify(data.description)}
prompt = """
${data.prompt}

{{args}}
"""
`;
};

/**
 * Main build function that orchestrates the entire build process.
 *
 * Process:
 * 1. Create output directories (prompts/, commands/)
 * 2. Find all .yaml files in src/
 * 3. Parse each YAML file and validate required fields
 * 4. Generate corresponding .md and .toml files
 * 5. Track errors and exit with appropriate code
 *
 * Exit codes:
 * - 0: Success
 * - 1: Fatal error or validation failures
 *
 * Error handling:
 * - Continues processing files even if one fails
 * - Reports all errors at the end
 * - Validates required fields (description, prompt)
 */
const build = () => {
  try {
    console.log(`${colors.blue}Building prompt files from src/*.yaml...${colors.reset}`);
    console.log('');

    // Read source files
    const srcDir = path.join(__dirname, '..', 'src');

    if (!fs.existsSync(srcDir)) {
      console.error(`${colors.yellow}Source directory not found: ${srcDir}${colors.reset}`);
      process.exit(1);
    }

    const sourceFiles = fs.readdirSync(srcDir).filter(f => f.endsWith('.yaml'));

    if (sourceFiles.length === 0) {
      console.log(`${colors.yellow}No YAML files found in src/${colors.reset}`);
      process.exit(0);
    }

    // Create output directories only after validating source exists
    ensureDir('prompts');
    ensureDir('commands');

    console.log(`${colors.blue}Processing ${sourceFiles.length} source file(s)...${colors.reset}`);
    console.log('');

    let hasErrors = false;

    sourceFiles.forEach(file => {
      const baseName = path.basename(file, '.yaml');
      const sourcePath = path.join(srcDir, file);

      try {
        console.log(`${colors.blue}Reading: src/${file}${colors.reset}`);

        // Parse YAML
        const data = yaml.load(fs.readFileSync(sourcePath, 'utf8'));

        // Generate outputs
        const mdPath = path.join(__dirname, '..', 'prompts', `${baseName}.md`);
        const tomlPath = path.join(__dirname, '..', 'commands', `${baseName}.toml`);

        const mdContent = generateMarkdown(data);
        const tomlContent = generateTOML(data);

        fs.writeFileSync(mdPath, mdContent);
        if (!fs.existsSync(mdPath)) {
          throw new Error(`Failed to write prompts/${baseName}.md`);
        }
        console.log(`  ${colors.green}✓${colors.reset} prompts/${baseName}.md`);

        fs.writeFileSync(tomlPath, tomlContent);
        if (!fs.existsSync(tomlPath)) {
          throw new Error(`Failed to write commands/${baseName}.toml`);
        }
        console.log(`  ${colors.green}✓${colors.reset} commands/${baseName}.toml`);

        console.log('');
      } catch (err) {
        console.error(`  ${colors.yellow}✗ Error processing ${file}: ${err.message}${colors.reset}`);
        console.log('');
        hasErrors = true;
      }
    });

    if (hasErrors) {
      console.error(`${colors.yellow}Build completed with errors.${colors.reset}`);
      process.exit(1);
    }

    console.log(`${colors.green}Done.${colors.reset}`);
    process.exit(0);
  } catch (err) {
    console.error(`${colors.yellow}Fatal error: ${err.message}${colors.reset}`);
    process.exit(1);
  }
};

build();
