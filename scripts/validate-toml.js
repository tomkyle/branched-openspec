#!/usr/bin/env node
/**
 * Validate TOML files for parseability.
 */

const fs = require('fs');
const path = require('path');
const TOML = require('@iarna/toml');
const glob = require('glob');

function validateToml() {
  const tomlFiles = glob.sync('commands/*.toml');

  if (tomlFiles.length === 0) {
    console.error('No commands/*.toml files found');
    process.exit(1);
  }

  let errors = 0;

  for (const filePath of tomlFiles) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      TOML.parse(content);
    } catch (error) {
      console.error(`Error parsing ${filePath}:`);
      console.error(error.message);
      errors++;
    }
  }

  if (errors > 0) {
    console.error(`\nFailed to validate ${errors} TOML file(s)`);
    process.exit(1);
  }

  console.log(`Validated ${tomlFiles.length} TOML files`);
}

validateToml();
