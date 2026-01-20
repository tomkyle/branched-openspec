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

.DEFAULT_GOAL := help

.PHONY: install uninstall help

# ---------------------------------------------------------------------------
# help
# Prints a concise, colorized overview of available Make targets.
# ---------------------------------------------------------------------------
help:
	@echo -e "$(BLUE)$(REPO_NAME)$(RESET)"
	@echo -e "  $(GREEN)make codex$(RESET)     Link prompts from $(CODEX_PROMPTS_DIR) into $(CODEX_TARGET_DIR)"
	@echo -e "  $(GREEN)make gemini$(RESET)    Install to Gemini extensions using Gemini CLI"
	@echo -e "  $(GREEN)make uninstall$(RESET) Remove symlinks that point to files in $(CODEX_PROMPTS_DIR)"
	@echo -e "  $(GREEN)make help$(RESET)      Show this overview"
	@echo ""


# ---------------------------------------------------------------------------
# codex
# Ensures the target directory exists and symlinks each prompt
# into Codex's prompts directory.
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
# Ensures the target directory exists and symlinks each prompt
# into Codex's prompts directory.
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


install: codex gemini


# ---------------------------------------------------------------------------
# uninstall
# Removes symlinks in the target directory that point to local prompt files.
# ---------------------------------------------------------------------------
uninstall:
	@if command -v gemini >/dev/null 2>&1; then \
		echo -e "$(BLUE)Removing prompt for Gemini...$(RESET)"; \
		gemini extensions uninstall $(PROMPT_NAME); \
		echo -e "$(GREEN)Done.$(RESET)"; \
	else \
		echo -e "$(YELLOW)Gemini CLI not found. Skipping Gemini uninstall.$(RESET)"; \
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
