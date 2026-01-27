# ============================================================================
# tomkyle/branched-openspec Makefile
# ---------------------------------------------------------------------------
# Installs and uninstalls custom prompts for Codex and Gemini.
# ============================================================================

REPO_NAME := tomkyle/branched-openspec
PROMPT_NAME := branched-openspec

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:

BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

CODEX_PROMPTS_DIR := $(abspath prompts)
CODEX_TARGET_DIR := $(HOME)/.codex/prompts
CODEX_PROMPT_FILES := $(wildcard $(CODEX_PROMPTS_DIR)/*)

OPENCODE_PROMPTS_DIR := $(abspath prompts)
OPENCODE_TARGET_DIR := $(HOME)/.config/opencode/commands/
OPENCODE_PROMPT_FILES := $(wildcard $(OPENCODE_PROMPTS_DIR)/*)

.DEFAULT_GOAL := help

.PHONY: opencode codex gemini install uninstall build help

# ---------------------------------------------------------------------------
# help
# Prints a concise, colorized overview of available Make targets.
# This is the default target when running 'make' without arguments.
# ---------------------------------------------------------------------------
help:
	@echo -e "$(BLUE)$(REPO_NAME)$(RESET)"
	@echo -e "  $(GREEN)make codex$(RESET)     Link prompts from $(CODEX_PROMPTS_DIR) into $(CODEX_TARGET_DIR)"
	@echo -e "  $(GREEN)make gemini$(RESET)    Install to Gemini extensions using Gemini CLI"
	@echo -e "  $(GREEN)make uninstall$(RESET) Remove symlinks that point to files in $(CODEX_PROMPTS_DIR)"
	@echo -e "  $(GREEN)make help$(RESET)      Show this overview"
	@echo ""


# ---------------------------------------------------------------------------
# opencode
# Installs prompts for OpenCode CLI by creating symlinks.
# - Checks if OpenCode CLI is installed
# - Creates ~/.config/opencode/commands/ if needed
# - Symlinks all files from prompts/ into OpenCode's commands directory
# - Skips gracefully if OpenCode CLI is not found
# ---------------------------------------------------------------------------
opencode:
	@if command -v opencode >/dev/null 2>&1; then \
		echo -e "$(BLUE)Installing custom prompt for Opencode...$(RESET)"; \
		if [ -z "$(OPENCODE_PROMPT_FILES)" ]; then \
			echo -e "$(YELLOW)No prompt files found in $(OPENCODE_PROMPTS_DIR).$(RESET)"; \
			exit 0; \
		fi; \
		mkdir -p "$(OPENCODE_TARGET_DIR)"; \
		for src in $(OPENCODE_PROMPT_FILES); do \
			PROMPT_NAME=$$(basename "$$src"); \
			dest="$(OPENCODE_TARGET_DIR)/$$PROMPT_NAME"; \
			ln -snf "$$src" "$$dest"; \
			echo -e "  $(GREEN)✓$(RESET) $$PROMPT_NAME"; \
		done; \
		echo -e "$(GREEN)Done.$(RESET)"; \
		echo ""; \
	else \
		echo -e "$(YELLOW)Opencode CLI not found. Skipping Opencode prompt installation.$(RESET)"; \
	fi

# ---------------------------------------------------------------------------
# codex
# Installs prompts for Codex CLI by creating symlinks.
# - Checks if Codex CLI is installed
# - Creates ~/.codex/prompts/ if needed
# - Symlinks all files from prompts/ into Codex's prompts directory
# - Skips gracefully if Codex CLI is not found
# ---------------------------------------------------------------------------
codex:
	@if command -v codex >/dev/null 2>&1; then \
		echo -e "$(BLUE)Installing custom prompt for Codex...$(RESET)"; \
		if [ -z "$(CODEX_PROMPT_FILES)" ]; then \
			echo -e "$(YELLOW)No prompt files found in $(CODEX_PROMPTS_DIR).$(RESET)"; \
			exit 0; \
		fi; \
		mkdir -p "$(CODEX_TARGET_DIR)"; \
		for src in $(CODEX_PROMPT_FILES); do \
			PROMPT_NAME=$$(basename "$$src"); \
			dest="$(CODEX_TARGET_DIR)/$$PROMPT_NAME"; \
			ln -snf "$$src" "$$dest"; \
			echo -e "  $(GREEN)✓$(RESET) $$PROMPT_NAME"; \
		done; \
		echo -e "$(GREEN)Done.$(RESET)"; \
		echo ""; \
	else \
		echo -e "$(YELLOW)Codex CLI not found. Skipping Codex prompt installation.$(RESET)"; \
	fi

# ---------------------------------------------------------------------------
# gemini
# Installs this repository as a Gemini CLI extension.
# - Checks if Gemini CLI is installed
# - Runs 'gemini extensions install .' to install from current directory
# - Uses gemini-extension.json manifest for extension metadata
# - Skips gracefully if Gemini CLI is not found
# ---------------------------------------------------------------------------
gemini:
	@if command -v gemini >/dev/null 2>&1; then \
		echo -e "$(BLUE)Installing custom prompt for Gemini...$(RESET)"; \
		gemini extensions install .; \
		echo -e "$(GREEN)Done.$(RESET)"; \
		echo ""; \
	else \
		echo -e "$(YELLOW)Gemini CLI not found. Skipping Gemini prompt installation.$(RESET)"; \
	fi


# ---------------------------------------------------------------------------
# install
# Convenience target that runs both codex and gemini installation.
# Use this to set up prompts for all supported CLIs at once.
# ---------------------------------------------------------------------------
install: codex gemini


# ---------------------------------------------------------------------------
# uninstall
# Removes all installed prompts and extensions.
# - Uninstalls Gemini extension using 'gemini extensions uninstall'
# - Removes OpenCode symlinks that point to this repo's prompts
# - Removes Codex symlinks that point to this repo's prompts
# - Only removes symlinks that actually target this repository
# - Skips any CLI that is not installed
# ---------------------------------------------------------------------------
uninstall:
	@if command -v gemini >/dev/null 2>&1; then \
		echo -e "$(BLUE)Removing prompt for Gemini...$(RESET)"; \
		gemini extensions uninstall $(PROMPT_NAME); \
		echo -e "$(GREEN)Done.$(RESET)"; \
	else \
		echo -e "$(YELLOW)Gemini CLI not found. Skipping Gemini uninstall.$(RESET)"; \
	fi

	@if command -v opencode >/dev/null 2>&1; then \
		echo -e "$(BLUE)Removing prompt for Opencode...$(RESET)"; \
		if [ -z "$(OPENCODE_PROMPT_FILES)" ]; then \
			echo -e "$(YELLOW)No prompt files defined locally.$(RESET)"; \
			exit 0; \
		fi; \
		removed=0; \
		for src in $(OPENCODE_PROMPT_FILES); do \
			PROMPT_NAME=$$(basename "$$src"); \
			dest="$(OPENCODE_TARGET_DIR)/$$PROMPT_NAME"; \
			if [ -L "$$dest" ]; then \
				target=$$(readlink "$$dest"); \
				if [ "$$src" = "$$target" ]; then \
					rm "$$dest"; \
					echo -e "  $(GREEN)✓$(RESET) $$PROMPT_NAME"; \
					removed=$$((removed + 1)); \
				fi; \
			fi; \
		done; \
		if [ $$removed -eq 0 ]; then \
			echo -e "$(YELLOW)No matching symlinks to remove.$(RESET)"; \
		else \
			echo -e "$(GREEN)Done.$(RESET)"; \
		fi; \
	else \
		echo -e "$(YELLOW)Opencode CLI not found. Skipping Opencode uninstall.$(RESET)"; \
	fi

	@if command -v codex >/dev/null 2>&1; then \
		echo -e "$(BLUE)Removing prompt for Codex...$(RESET)"; \
		if [ -z "$(CODEX_PROMPT_FILES)" ]; then \
			echo -e "$(YELLOW)No prompt files defined locally.$(RESET)"; \
			exit 0; \
		fi; \
		removed=0; \
		for src in $(CODEX_PROMPT_FILES); do \
			PROMPT_NAME=$$(basename "$$src"); \
			dest="$(CODEX_TARGET_DIR)/$$PROMPT_NAME"; \
			if [ -L "$$dest" ]; then \
				target=$$(readlink "$$dest"); \
				if [ "$$src" = "$$target" ]; then \
					rm "$$dest"; \
					echo -e "  $(GREEN)✓$(RESET) $$PROMPT_NAME"; \
					removed=$$((removed + 1)); \
				fi; \
			fi; \
		done; \
		if [ $$removed -eq 0 ]; then \
			echo -e "$(YELLOW)No matching symlinks to remove.$(RESET)"; \
		else \
			echo -e "$(GREEN)Done.$(RESET)"; \
		fi; \
	else \
		echo -e "$(YELLOW)Codex CLI not found. Skipping Codex uninstall.$(RESET)"; \
	fi


# ---------------------------------------------------------------------------
# build
# Generates distribution files from source YAML.
# - Reads source files from src/*.yaml
# - Generates prompts/*.md files with YAML frontmatter
# - Generates commands/*.toml files for Gemini CLI
# - Uses Node.js build script (scripts/build.js)
# - Creates output directories if they don't exist
# ---------------------------------------------------------------------------

build:
	@./scripts/build.js
