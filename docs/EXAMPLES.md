# Usage Examples

Real-world workflows for managing multiple Claude Code CLI instances with the CC toolkit.

## Table of Contents

- [Basic Workflows](#basic-workflows)
- [Multi-Worktree Development](#multi-worktree-development)
- [Cross-Project Work](#cross-project-work)
- [Team Collaboration](#team-collaboration)
- [Advanced Techniques](#advanced-techniques)

## Basic Workflows

### Single Project, Multiple Tasks

Working on one project with different focus areas.

```powershell
# Terminal 1: Main feature development
cd C:\apps\MyProject
cc
# Inside Claude Code: !sl FeatureWork
# Output: ✓ Set statusline for pane: CC-20251106-145238

# Terminal 2: Bug fixing
cd C:\apps\MyProject
cc
# Inside Claude Code: !sl BugFixes
# Output: ✓ Set statusline for pane: CC-20251106-145312

# Terminal 3: Documentation
cd C:\apps\MyProject
cc
# Inside Claude Code: !sl DocsUpdate
# Output: ✓ Set statusline for pane: CC-20251106-145425
```

**Statuslines show:**
```
Terminal 1: \apps\MyProject | [M] CC-20251106-145238 | ...
Terminal 2: \apps\MyProject | [M] CC-20251106-145312 | ...
Terminal 3: \apps\MyProject | [M] CC-20251106-145425 | ...
```

**Benefit:** Same project, clear task separation

### Quick Context Switching

The `!sl` command inside Claude Code updates your session identifier:

```powershell
# Start session
cd C:\apps\MyProject
cc

# Inside Claude Code - set initial identifier
!sl RefactoringAuth
# Output: ✓ Set statusline for pane: CC-20251106-145238

# ... work for a while ...

# Update identifier as you switch tasks
!sl TestingAPIs
# Output: ✓ Set statusline for pane: CC-20251106-145238

# ... work for a while ...

!sl WritingTests
# Output: ✓ Set statusline for pane: CC-20251106-145238

# Note: PANE_NAME stays CC-20251106-145238 (timestamped at launch)
# The !sl command updates what you see in the statusline
```

## Multi-Worktree Development

### Parallel Feature Development

Perfect for git worktree workflows.

```powershell
# Main repository
cd C:\apps\MyProject
cc
# Inside: !sl MainBranch

# Feature 1 worktree
cd C:\apps\MyProject-oauth-feature
cc
# Inside: !sl OAuthFeature

# Feature 2 worktree
cd C:\apps\MyProject-api-refactor
cc
# Inside: !sl APIRefactor

# Experimental worktree
cd C:\apps\MyProject-experiment
cc
# Inside: !sl Experiment
```

**Statuslines show:**
```
\apps\MyProject           | [M] CC-20251106-145238 | ...
\apps\...-oauth-feature   | [M] CC-20251106-145312 | ...
\apps\...-api-refactor    | [M] CC-20251106-145425 | ...
\apps\...-experiment      | [M] CC-20251106-145538 | ...
```

**Benefit:** Each worktree gets unique identifier, easy to find

### Bug Investigation Across Branches

```powershell
# Production branch (investigating bug)
cd C:\apps\MyProject
git checkout production
sl BugInvestigation
cc
/statuslineupdate Reproducing bug in production

# Main branch (testing fix)
cd C:\apps\MyProject-main-worktree
sl TestingFix
cc
/statuslineupdate Testing potential fix

# Feature branch (checking if bug exists there)
cd C:\apps\MyProject-feature-worktree
sl FeatureCheck
cc
/statuslineupdate Checking if bug affects feature
```

## Cross-Project Work

### Multiple Projects Simultaneously

```powershell
# Project A: Main SaaS product
cd C:\apps\ProjectA
cc
# Inside: !sl ProjectAMain

# Project B: Internal tool
cd C:\apps\InternalTool
cc
# Inside: !sl InternalTool

# Project C: Client work
cd C:\apps\ClientProject
cc
# Inside: !sl ClientWork
```

**Statuslines show:**
```
\apps\ProjectA        | [M] CC-20251106-145238 | ...
\apps\InternalTool    | [M] CC-20251106-145312 | ...
\apps\ClientProject   | [M] Implementing dashboard UI | ...
```

### Frontend + Backend Split

```powershell
# Frontend repo
cd C:\apps\MyApp-Frontend
sl Frontend
cc
/statuslineupdate Building React components

# Backend repo
cd C:\apps\MyApp-Backend
sl Backend
cc
/statuslineupdate Implementing API endpoints

# Shared library
cd C:\apps\MyApp-Shared
sl SharedLib
cc
/statuslineupdate Updating type definitions
```

## Team Collaboration

### Code Review Workflow

```powershell
# Your feature branch
cd C:\apps\MyProject
sl MyFeature
cc
/statuslineupdate Addressing review comments

# Teammate's PR (checked out locally)
cd C:\apps\MyProject-teammate-pr
sl ReviewingPR
cc
/statuslineupdate Reviewing teammate's auth changes

# Main branch (testing integration)
cd C:\apps\MyProject-main
sl Integration
cc
/statuslineupdate Testing merged features
```

### Pair Programming Setup

```powershell
# Driver: Main implementation
cd C:\apps\SharedProject
sl Driver-FeatureX
cc
/statuslineupdate Implementing core logic

# Navigator: Research and documentation
cd C:\apps\SharedProject
sl Navigator-Research
cc
/statuslineupdate Researching best practices
```

## Advanced Techniques

### Custom PANE_NAME for Persistent Sessions

Set PANE_NAME in your PowerShell profile for consistent naming:

```powershell
# Add to $PROFILE
$env:PANE_NAME = "Terminal1"

# Now every cc session uses "Terminal1"
cd C:\apps\AnyProject
cc
# PANE_NAME is automatically "TERMINAL1"
```

**Use case:** You always work in 3 terminals with fixed purposes

### Project-Specific Identifiers

Create project-specific launchers:

```powershell
# Save as launch-zwoofi.ps1
function Start-ZwoofiMain {
    cd C:\apps\Zwoofi
    sl ZwoofiMain
    cc
}

function Start-ZwoofiFeature {
    param([string]$FeatureName)
    cd "C:\apps\Zwoofi-$FeatureName"
    sl "Zwoofi-$FeatureName"
    cc
}

# Usage
Start-ZwoofiMain
Start-ZwoofiFeature "oauth"
```

### Time-Boxed Sessions

Combine with manual status for time tracking:

```powershell
sl DeepWork
cc

# Start task
/statuslineupdate [9:00-10:00] Implementing auth

# ... work for an hour ...

# Next task
/statuslineupdate [10:00-11:00] Code review

# ... work for an hour ...

# Break
/statuslineupdate [11:00-11:15] Break
```

### Debugging Multiple Services

Microservices architecture with multiple services:

```powershell
# Service A (API Gateway)
cd C:\apps\Services\gateway
sl Gateway
cc
/statuslineupdate Debugging request routing

# Service B (Auth Service)
cd C:\apps\Services\auth
sl AuthService
cc
/statuslineupdate Investigating token validation

# Service C (Database)
cd C:\apps\Services\database
sl Database
cc
/statuslineupdate Optimizing queries

# Service D (Frontend)
cd C:\apps\Services\frontend
sl Frontend
cc
/statuslineupdate Testing API integration
```

### Integration Testing Workflow

```powershell
# Unit tests
cd C:\apps\MyProject
sl UnitTests
cc
/statuslineupdate Writing unit tests for auth

# Integration tests
cd C:\apps\MyProject
sl IntegrationTests
cc
/statuslineupdate Testing API integration

# E2E tests
cd C:\apps\MyProject
sl E2ETests
cc
/statuslineupdate Running Playwright tests

# Test infrastructure
cd C:\apps\MyProject
sl TestInfra
cc
/statuslineupdate Setting up test database
```

## Productivity Tips

### 1. Use Short, Meaningful Identifiers

**Good:**
- `sl Auth` → Clear purpose
- `sl BugFix` → Obvious task
- `sl Review` → Reviewing code

**Avoid:**
- `sl WorkStuff` → Too vague
- `sl abc123` → Hard to remember
- `sl ThisIsAVeryLongIdentifierThatWillGetTruncated` → Too long

### 2. Update Manual Status Frequently

Don't set it once and forget. Update as your focus changes:

```powershell
/statuslineupdate Reading codebase
# ... 30 minutes later ...
/statuslineupdate Planning implementation
# ... 1 hour later ...
/statuslineupdate Writing code
# ... 2 hours later ...
/statuslineupdate Testing and debugging
```

### 3. Clear Status When Taking Breaks

```powershell
/statuslineupdate [Break 15min]
# or
/statuslineclear
```

Helps you remember where you left off.

### 4. Combine with Windows Terminal Tabs

Name your terminal tabs to match PANE_NAME:

```
Tab 1: MainWork
Tab 2: BugFixes
Tab 3: Testing
Tab 4: Docs
```

### 5. Use Consistent Naming Schemes

Develop a personal convention:

```powershell
# By type
sl Feature-X
sl Bug-Login
sl Refactor-API
sl Docs-README

# By priority
sl P0-Critical
sl P1-Important
sl P2-Nice

# By time
sl Morning-Focus
sl Afternoon-Review
sl Evening-Cleanup
```

## Common Patterns

### Pattern: Daily Workflow

```powershell
# Morning: Planning and email
sl MorningReview
cc
/statuslineupdate Reviewing PRs and issues

# Mid-morning: Deep work
sl DeepWork
cc
/statuslineupdate Implementing feature X

# Afternoon: Code review
sl CodeReview
cc
/statuslineupdate Reviewing team's code

# Late afternoon: Bug fixes
sl BugBash
cc
/statuslineupdate Fixing reported bugs
```

### Pattern: Sprint Workflow

```powershell
# Sprint planning
sl SprintPlanning
cc
/statuslineupdate Planning sprint 24

# Development
sl SprintDev
cc
/statuslineupdate Working on sprint 24 tasks

# Testing
sl SprintTest
cc
/statuslineupdate Testing sprint 24 features

# Retrospective
sl SprintRetro
cc
/statuslineupdate Documenting sprint learnings
```

## Troubleshooting in Examples

### Problem: Too many terminals open

**Solution:** Limit to 3-4 concurrent sessions. Close finished ones.

```powershell
# When done with a task, exit Claude Code
# Start new session for next task
```

### Problem: Forgot which terminal is which

**Solution:** Check statusline! That's what it's for.

```
\apps\MyProject | [M] Implementing auth | ...
```

### Problem: Manual status out of date

**Solution:** Update it or clear it:

```powershell
/statuslineupdate Current actual task
# or
/statuslineclear
```

## See Also

- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Statusline Documentation](../claude-code/STATUSLINE.md) - Statusline reference
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues
- [Main README](../README.md) - Project overview

---

[← Back to README](../README.md)
