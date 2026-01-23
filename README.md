# OpenSpec in Git Work Branch

**This repository ships custom prompts for [Codex](https://openai.com/codex/)/[OpenCode](https://opencode.ai/) and a matching [Gemini CLI](https://geminicli.com/) extension that drive the [OpenSpec](https://openspec.dev/) workflow inside an isolated Git work branch while enforcing [Conventional Commits](https://www.conventionalcommits.org) after each phase.**

## Rationale

Traceability and Compliance are critical when applying automated changes to codebases.
Using Conventional Commits after every OpenSpec phase and user refinement produces a consistent change log, simplifies auditing, and keeps the main branches clean. Teams can review or adjust the work branch between phases without losing visibility into either manual edits or the automated OpenSpec run. 


## Overview
- Spins up a feature branch for every OpenSpec proposal so experiments stay isolated
- Walks through the *proposal → apply → archive* flow with [Conventional Commits](https://www.conventionalcommits.org) after each stage
- Leaves room for your refinement or review commits between phases
- Merges successful work back into the base branch and removes the temporary branch when the cycle ends

## Prompt files

- [prompts/branched-openspec.md](./prompts/branched-openspec.md) — Codex and Opencode Custom Command 
- [commands/branched-openspec.toml](./commands/branched-openspec.toml) — Gemini CLI extension

Open these files in your editor to review or adapt the instructions before wiring it into your automation.


## Installation

**Gemini CLI**  
allows direct installation from GitHub repositories, see their [docs](https://geminicli.com/docs/extensions/#installing-an-extension). Run this command to install the Gemini extension from this repository: 

```sh
$ gemini extensions install https://github.com/tomkyle/branched-openspec
$ gemini extensions install https://github.com/tomkyle/branched-openspec --auto-update
```

**Codex CLI and OpenCode**   
Clone the repository locally and use the provided _Makefile_ to install the prompts for Codex and Opencode as well as the Gemini extension. Run `make install` to set up all of them when their CLIs are available. — You may also install them separately using `make codex` and `make opencode`.

```sh
$ git clone https://github.com/tomkyle/branched-openspec
$ cd branched-openspec
$ make install
```

**Uninstallation:**  
Use `make uninstall` to remove the Gemini extension and Codex extensions. Each step runs only when its CLI is available and falls back to a skip message otherwise.

```sh
$ make uninstall
```



## Usage

Open Codex, OpenCode, or Gemini CLI and run the `/prompts:branched-openspec` prompt with the project requirements. Just typing `/branched-openspec ...` in the prompt selector should also work.

```text
/branched-openspec "Add hello-world feature"
```

**N.B.** Sometimes Codex hallucinates a `.git/index.lock` file being present or missing write permissions. If that happens, grant Codex additional write access to the `.git` directory:

```bash
$ codex --add-dir .git
```

### Git Log Example

After completing the OpenSpec cycle, the Git log should show four commits: one each for proposal, apply, archive, and the final merge back into the base branch. Note how each carries the `OpenSpec phase: <phase>` footer in the commit message.


Run this command to see the last four commits in reverse order:

```bash
$ git log -n 4  --reverse
```

Output will look similar to this:

```yaml
 commit 879ca0dfa804d2adc42cfca184be9d9639b82ad5
  Author: tomkyle <user@example.com>
  Date:   Wed Jan 21 19:39:48 2026 +0100
   
      chore(spec): propose hello-command
      
      - add proposal, tasks, and hello-command spec delta
      
      OpenSpec phase: proposal


  commit 48b50b5e10bcf258b4049b39e303a611804a79d2
  Author: tomkyle <user@example.com>
  Date:   Wed Jan 21 19:46:04 2026 +0100
   
      feat(cli): implement hello command
      
      - add hello command definition and implementation
      - cover greetings in integration and functional tests
      - regenerate CLI and docs
      - note E2E suite absence in tasks
      
      OpenSpec phase: apply
   

  commit aae81cb7288709d03a63f2329991b6771a240426
  Author: tomkyle <user@example.com>
  Date:   Wed Jan 21 19:47:23 2026 +0100
   
      chore(spec): archive hello-command
      
      - archive add-hello-command and update hello-command spec
      
      OpenSpec phase: archive
   

  commit d7f44df014e301cc2bac421d11273f7c45996f3c (HEAD -> main)
  Merge:  aab12429 d312e09
  Author: tomkyle <user@example.com>
  Date:   Wed Jan 21 19:48:29 2026 +0100
   
      chore(spec): merge feature-hello-command
```
	  


## Mileage will vary

Codex and Gemini receive a checklist of allowed Git operations and should respect it, but the agents can still deviate due to sandbox permissions or other environmental factors. Tuning sandbox permissions or adding guard rails may help, yet those adjustments live outside this repository.



