# Claude CC Multi-Instance Manual Statusline

> **Manage multiple Claude Code CLI sessions on Windows with manual identifiers and custom statusline**

> **⚠️ Important:** This repository contains exported configurations from my personal setup with redactions and placeholders added. Please review all files carefully and adapt them to your specific environment and workflow before use. Consider running the configuration through an AI assistant to verify compatibility with your setup.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/powershell/)

A lightweight toolkit for Windows developers running multiple Claude Code CLI instances simultaneously. Adds manual session identifiers and a custom statusline for instant context awareness.

## The Problem

Running multiple Claude Code CLI instances (3, 4, 5+) simultaneously causes:

- **Context Loss**: Which CLI is handling what task?
- **Cognitive Overhead**: Constant scrolling to find the right terminal pane
- **Windows-Specific**: No tmux/multiplexer - just native PowerShell terminals
- **Unreliable Automation**: Hooking implementation plans breaks with internal tools (ExitPlanMode, TodoWrite)

### Real-World Scenario

You're working on:
- **Terminal 1**: Main branch - Fixing auth bug
- **Terminal 2**: Feature worktree - Testing OAuth refactor
- **Terminal 3**: Different project - Refactoring API layer

You get Slack notification about the auth bug. Which terminal was that? You scroll through 3 terminals, read conversation histories, lose 30 seconds.

**Repeat this 20 times a day = 10 minutes wasted.**

## The Solution

Two-part toolkit providing **manual, reliable session identification**:

### 1. CC PowerShell Alias

Wraps Claude CLI with automatic session tracking:

```powershell
cd C:\apps\MyProject
cc                  # Launch Claude Code with PANE_NAME=CC-20251106-143022

# Inside Claude Code:
!sl FixingAuthBug   # Set manual identifier
# Output: ✓ Set statusline for pane: CC-20251106-143022
```

**Benefits:**
- Unique timestamped session IDs (no collisions)
- Manual `!sl` command for readable labels inside Claude Code
- Directory preservation (Push/Pop-Location)
- Works with any terminal (no tmux required)

### 2. Claude Code Statusline

Custom statusline that displays session context:

```
\apps\MyProject | [M] CC-20251106-143022 | Sonnet 4.5 | Plan >> Active task
```

**Shows:**
- **Project folder** - Know which worktree/project you're in
- **Manual label** - Your custom identifier from `!sl` command
- **AI model** - Current model (optional - requires ccusage)
- **Active work** - Auto-extracted from TodoWrite/Task tools

## Quick Start

### Install PowerShell Functions

```powershell
cd C:\path\to\claude-cc-multiinstance-manual-statusline\powershell
.\install.ps1
```

Restart PowerShell, then test:

```powershell
cd C:\your\project
cc

# Inside Claude Code:
!sl TestSession
# Output: ✓ Set statusline for pane: CC-...
```

### Setup Statusline (Per Project)

```powershell
# Copy .claude folder to your project
cp -r C:\path\to\claude-cc-multiinstance-manual-statusline\claude-code\.claude C:\your\project\.claude

# Launch Claude Code
cd C:\your\project
claude
```

The statusline should appear automatically.

See [INSTALLATION.md](docs/INSTALLATION.md) for detailed setup instructions.

## Usage

### Basic Workflow

**The correct workflow is:**

1. Navigate to project and launch `cc`
2. Inside Claude Code, use `!sl` to set identifier

```powershell
# Terminal 1: Main branch
cd C:\apps\MyProject
cc

# Inside Claude Code:
!sl FixingAuthBug
# Output: ✓ Set statusline for pane: CC-20251106-145238
# Statusline shows: \apps\MyProject | [M] CC-20251106-145238 | Idle
```

```powershell
# Terminal 2: Feature worktree
cd C:\apps\MyProject-oauth-refactor
cc

# Inside Claude Code:
!sl TestingOAuth
# Output: ✓ Set statusline for pane: CC-20251106-145312
# Statusline shows: \apps\MyProject-oauth-refactor | [M] CC-20251106-145312 | Idle
```

Each terminal shows its unique context. **No more confusion.**

### Multi-Worktree Development

Perfect for parallel feature development:

```powershell
# Main repo
cd C:\apps\MyProject
cc
# Inside: !sl MainBranch

# Feature 1 worktree
cd C:\apps\MyProject-feature1
cc
# Inside: !sl FeatureOne

# Feature 2 worktree
cd C:\apps\MyProject-feature2
cc
# Inside: !sl FeatureTwo
```

See [EXAMPLES.md](docs/EXAMPLES.md) for more workflows.

## Features

### CC PowerShell Functions

**`cc`** - Launch Claude Code with tracking
- Auto-generates timestamped session ID (PANE_NAME)
- Preserves directory with Push/Pop-Location
- Forwards all arguments to Claude CLI

**`!sl <name>`** - Set manual identifier (inside Claude Code)
- Updates PANE_NAME environment variable
- Visible in statusline as `[M] CC-<timestamp>`
- Use this inside Claude Code CLI, not in PowerShell

**`sl <name>`** - Set identifier before launching (optional)
- Can be used in PowerShell before `cc` command
- Sets PANE_NAME for current session
- Less common - most users just use `!sl` inside Claude Code

### Claude Code Statusline

**Project Path** - Last 2 directory segments
- Example: `C:\Users\YourName\apps\MyProject` → `\apps\MyProject`
- Helps identify worktrees/projects at a glance

**Manual Status** - Auto-set via `!sl` command
- Shows PANE_NAME value
- Updates when you use `!sl` inside Claude Code

**AI Model** - Current model name (optional)
- Requires: `npm install -g ccusage`
- Shows: Sonnet 4.5, Opus, Haiku, etc.

**Task Tracking** - Auto-extracted from transcript
- TodoWrite: `Plan name >> Active task`
- Task tool: `[A] Task description`
- Working: `[Working...]`
- Fallback: `Idle`

## Why This Approach?

### Manual > Automatic (for this use case)

**Tried automatic solutions:**
- Statusline hooks for implementation plans → Breaks with ExitPlanMode/TodoWrite
- Parsing conversation history → Too slow, unreliable
- Auto-generated IDs → Hard to remember (which terminal is "abc123"?)

**Manual identifiers work because:**
- **You control the label** - Use meaningful names
- **Environment-based** - Reliable, no hook fragility
- **One-time setup** - Set `!sl` once per session
- **Instant recognition** - Session IDs are timestamped and readable

### Windows-First Design

**No tmux/multiplexer needed:**
- Native PowerShell terminals
- Built-in Push/Pop-Location
- Standard environment variables
- Works with Windows Terminal, ConEmu, etc.

## Documentation

- [Installation Guide](docs/INSTALLATION.md) - Step-by-step setup
- [Examples](docs/EXAMPLES.md) - Real-world workflows
- [Statusline Documentation](claude-code/STATUSLINE.md) - Complete statusline reference
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Requirements

### Required

- **Windows** (PowerShell 5.1+ built-in)
- **Claude Code CLI** ([Download](https://claude.ai/download))

### Optional

- **ccusage** - For AI model display in statusline
  ```powershell
  npm install -g ccusage
  ```

## Project Structure

```
claude-cc-multiinstance-manual-statusline/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── powershell/
│   ├── install.ps1                    # Auto-installer
│   ├── uninstall.ps1                  # Removal script
│   └── cc-functions.ps1               # Core functions
├── claude-code/
│   ├── .claude/
│   │   ├── settings.json              # Statusline config
│   │   ├── statusline-simple.ps1      # Main script
│   │   └── commands/
│   │       ├── statuslineupdate.sh    # Advanced: Manual override
│   │       └── statuslineclear.sh     # Advanced: Clear override
│   └── STATUSLINE.md                  # Statusline docs
└── docs/
    ├── INSTALLATION.md                # Setup guide
    ├── EXAMPLES.md                    # Usage examples
    └── TROUBLESHOOTING.md             # Common issues
```

## Contributing

Contributions welcome! This toolkit was born from real pain points in daily development.

**Ideas for contributions:**
- Cross-platform support (bash/zsh versions)
- Additional statusline components
- Integration with other terminal multiplexers
- Performance optimizations

## License

MIT License - See [LICENSE](LICENSE)

## Author

**Dennis**

This toolkit grew from managing 5+ Claude Code instances daily while working on multiple projects with worktrees.

## Acknowledgments

- **Claude Code Team** - For the excellent CLI and statusline feature
- **ccusage** - For model extraction functionality
- **Windows Terminal Team** - For modern terminal experience

## See Also

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Windows Terminal](https://github.com/microsoft/terminal)

---

**Star this repo if it saves you time!** ⭐

Every saved context switch adds up. Happy coding!
