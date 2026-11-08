# claude-setup

A starter setup for Claude Code: a few skills that help in most projects, a status line, and sensible startup defaults.

## Install

Pick your system. The order is the same everywhere: GitHub, then Claude Code, then this setup.

### macOS

In Terminal:

```sh
# 1. Homebrew (skip if `brew --version` already works)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. GitHub: git, the GitHub CLI, and a login so Claude can create and push repos
brew install git gh
gh auth login

# 3. Claude Code, then log in once (type /exit to leave)
curl -fsSL https://claude.ai/install.sh | bash
claude

# 4. This setup
brew install jq node
git clone https://github.com/anpawo/claude-setup.git
cd claude-setup
./install.sh

# 5. Optional: the browser tool used by the playwright-cli skill
npm install -g @playwright/cli@latest
```

### Linux (Ubuntu, Debian)

In a terminal (on Fedora, use `dnf` instead of `apt`):

```sh
# 1. GitHub: git, the GitHub CLI, and a login so Claude can create and push repos
sudo apt update
sudo apt install -y git gh curl
gh auth login

# 2. Claude Code, then log in once (type /exit to leave)
curl -fsSL https://claude.ai/install.sh | bash
claude

# 3. This setup
sudo apt install -y jq nodejs npm
git clone https://github.com/anpawo/claude-setup.git
cd claude-setup
./install.sh

# 4. Optional: the browser tool used by the playwright-cli skill
sudo npm install -g @playwright/cli@latest
```

### Windows

In PowerShell:

```powershell
# 1. GitHub: Git (it brings Git Bash, which Claude Code needs), the GitHub CLI, and a login
winget install --id Git.Git -e
winget install --id GitHub.cli -e
# close and reopen PowerShell, then:
gh auth login

# 2. Claude Code, then log in once (type /exit to leave)
irm https://claude.ai/install.ps1 | iex
# close and reopen PowerShell, then:
claude

# 3. Tools for this setup
winget install --id jqlang.jq -e
winget install --id OpenJS.NodeJS.LTS -e
```

Then open **Git Bash** (from the Start menu) and run:

```sh
# 4. This setup
git clone https://github.com/anpawo/claude-setup.git
cd claude-setup
./install.sh

# 5. Optional: the browser tool used by the playwright-cli skill
npm install -g @playwright/cli@latest
```

### After installing

Start a new `claude` session. Run `./install.sh` again any time to update.

## What it installs

- Skills into `~/.claude/skills/` (list below).
- `~/.claude/statusline.sh`: model and effort, context use, `uncommitted` / `unpushed` warnings, and the branch's pull request.
- Startup defaults in `~/.claude/settings.json`: Opus, high effort, no permission prompts.
- Rules appended to `~/.claude/CLAUDE.md`: work inside the project folder, commit and push each working change.
- The `ponytail` plugin: pushes Claude toward the simplest code that works.

## Skills

Call one by typing its name (`/grill`) or just asking for what it does.

| Skill | What it does | Say |
|-------|--------------|-----|
| `grill` | Questions you on a plan, round by round, before anything gets built | "grill me on this" |
| `diagnosing-bugs` | A step-by-step loop for hard bugs and slowdowns | "debug this", "diagnose" |
| `ui-tweak` | Makes a visual change and checks it with a headless screenshot | "make the header smaller" |
| `playwright-cli` | Drives a browser to test or read web pages (needs the optional last step) | "open the page and check the form" |
| `santa` | Three independent reviewers check a deliverable before it is sent | "santa", "review before sending" |
| `ram` | Shows what eats memory, per app and per Claude session, and stops leftover MCP servers and browsers | "what's eating my RAM", "/ram" |
| `sm` | Shortens the last answer as much as possible | "/sm" |
| `llm-council` | Five advisors answer a hard decision on their own, then review each other | "council this", "should I X or Y" |
| `design-council` | A team of specialist agents debates a cross-domain technical design | "convene the council" |

`llm-council` and `design-council` start many agents at once, so they use a lot of tokens: keep them for decisions that matter. `design-council` also needs agent teams turned on: add `"env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}` to `~/.claude/settings.json`.
